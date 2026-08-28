# Phase 3: scoring findings report

*Superseded. The method proposed here was approved and implemented; see
`decisions-log.md` and `sql/06` through `sql/08` for what actually shipped.*

*Written 2026-08-04. Analysis of `derived_candidates` (1,268 rows, one per candidate CIP
program, see `docs/data-dictionary.md`'s Analysis Marts section for the mart's full
column reference) and a proposed method for turning it into a 0 to 100 Go/Test/Pass
score. This is a findings report, not a locked decision: every number below is
independently reproducible from `data/derived/derived_candidates.csv`, and it was
verified in a separate Python notebook before any of this was implemented in SQL.*

## 1. Distribution profile

| Metric | n (non-null) | min | p10 | p25 | median | p75 | p90 | p95 | p99 | max | skew |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `completions_latest_year` | 1,268 | 0 | 0.7 | 10 | 64.5 | 326.3 | 1,227.5 | 3,309.8 | 12,572.0 | 97,150 | 17.5 |
| `completions_trend_pct` | 1,142 | -100 | -77.4 | -40.9 | 12.2 | 121.5 | 445.5 | 966.5 | 5,818.2 | 33,000 | 13.9 |
| `employment_weighted_openings` | 1,191 | 0.1 | 2.8 | 7.1 | 16.9 | 61.1 | 99.0 | 113.6 | 228.4 | 305.2 | 2.0 |
| `employment_weighted_growth_pct` | 1,191 | -25.9 | -1.2 | 1.4 | 3.7 | 6.4 | 14.2 | 16.6 | 21.4 | 26.9 | 0.8 |

`in_bls_top30_flag`: 363 TRUE / 905 FALSE (28.6% true). `already_offered_by_vanderbilt`:
14 TRUE / 1,254 FALSE. 1,254 is the actual pool being scored.

**Skew** measures lopsidedness: 0 is a symmetric distribution, and the bigger the
number, the more one extreme value is dragging the tail. `completions_latest_year` and
`completions_trend_pct` are extremely skewed (17.5 and 13.9); the other two metrics are
much closer to normal (2.0 and 0.8).

**What's driving the skew:**
- Business Administration and Management, General (CIP 52.0201) has 97,150 completions,
  nearly 3x the #2 program (Social Work, 44.0701, at 34,458) and about 1,500x the median
  (64.5). Confirmed real, not a data error; this is a legitimately huge, catch-all
  field.
- 127 of 1,268 candidates show 0 completions in their latest available IPEDS year (87 of
  those in 2024 itself, a genuine recorded zero, not a missing row). 78 of the 127 show
  exactly -100% trend, meaning they had real completions once and dropped to zero, a
  real decline signal. The trend metric's max (+33,000%) and min (-100%) both come from
  this same small-base sensitivity: percent change from a near-zero starting point
  produces extreme numbers that are technically correct but not "explosive growth" in
  the way the raw percentage implies.

**Correlation between the four continuous metrics** (pairwise, complete observations
only): all six pairwise correlations fall between 0.04 and 0.20, essentially
independent. This matters for scoring: none of the four metrics is redundant with
another, so combining all four is additive signal, not double-counting.

**Data-quality flag worth knowing before trusting the rankings at face value:** the top
5 candidates by `employment_weighted_openings`, Parks/Rec Facilities Management
(31.0399, 305.2), Parks/Rec Facilities Management General (31.0301, 293.9), Risk
Management (52.0215, 257.4), Retail Management (52.0212, 252.7), Management Science
(52.1301, 246.9), all include SOC 11-1021, "General and Operations Managers," among
their top-3 matched occupations. That's the already-locked employment-weighted top-3
join rule working as designed, not a bug, but it means several thematically unrelated
"management-adjacent" fields will score high on labor demand largely because they
crosswalk into the same enormous generic occupation, not because that specific field is
uniquely in demand.

## 2. Normalization method

The four continuous metrics are on incompatible scales (completions in the hundreds to
tens-of-thousands; growth in percent, bounded roughly -100% to +33,000%) and can't be
averaged directly. Three approaches considered:

**Min-max**: `(value − min) / (max − min) × 100`. Simplest and most literal
("0 = worst observed, 100 = best observed"), but breaks badly here: with Business
Administration's 97,150 completions defining the top of the scale, the median candidate
(64.5 completions) would score about 0.07/100. Nearly every program gets crushed near
zero by one outlier. **Rejected** for the two high-skew metrics.

**Percentile rank**: each candidate's percentile position in its own metric's
distribution (0 to 100), independent of magnitude. Robust to outliers by construction,
since it only uses rank order. **Recommended**, applied uniformly to all four
continuous metrics; one consistent method is simpler to defend than mixing methods per
metric. Tradeoff: it discards magnitude. Business Administration's real ~3x lead over
the #2 program collapses into "just the highest percentile," identical treatment to a
program that barely edged out its neighbor. For a project whose output is three bands
(Go/Test/Pass) rather than a precise market-size model, that tradeoff is reasonable,
but it is a real information loss, not a free simplification.

**Capping / winsorizing**: clip values above a chosen ceiling (e.g. the 99th
percentile) before min-max scaling. A legitimate, more intuitive alternative to
percentile rank. Tradeoff: requires picking a ceiling, and that choice is itself
arbitrary (why p99 and not p95, or half the max?); percentile rank avoids needing that
extra parameter. Logged as a considered alternative, not adopted, in
`docs/decisions-log.md`.

`in_bls_top30_flag` is binary and skips this step entirely; it becomes a straight 0/100
component in the weighted sum.

*(This is standard practice in multi-criteria decision analysis, or MCDA: combining
criteria on incompatible scales into one comparable basis before weighting them.)*

## 3. Composite weight proposal

| Component | Proposed weight | Reasoning |
|---|---|---|
| `completions_latest_year` (student demand, size) | 30% | Answers "is there already a real market," the single most defensible fact for a Go decision |
| `employment_weighted_openings` (labor demand, size) | 30% | Same logic on the career-outcome side |
| `completions_trend_pct` (student demand, direction) | 15% | Direction matters, weighted lighter than size on purpose; the skew analysis above shows this metric is noisy when the base is small |
| `employment_weighted_growth_pct` (labor demand, direction) | 15% | Same reasoning, labor side |
| `in_bls_top30_flag` (corroborating signal) | 10% | Binary and narrower in scope than the other four, a tie-breaker bonus, not a primary driver |

Net: 60% size / 30% trend / 10% flag. Logic: a field with a large, stable market beats a
tiny field with a large trend percentage, because section 1 shows large trend
percentages are often a small-base artifact rather than real momentum. Proposed here for
review, not locked; see the decisions log for how it was actually approved.

## 4. NULL handling

Two real NULL patterns exist in the mart. Overlap checked: 77 candidates have no
labor-market match (`employment_weighted_openings`/`growth_pct` NULL), 126 have no
completions trend (`completions_trend_pct` NULL), 11 candidates hit both, 192 total
(15.1%) are missing at least one metric, 1,076 (84.9%) are fully complete.

- **77 no-labor-match**: these CIPs matched no SOC occupation anywhere in the crosswalk
  (same family as the 22 unmatched IPEDS codes / 12 unmatched BLS codes documented in
  Phase 2), genuinely unknown, not zero demand.
- **126 no-trend**: only one year of IPEDS data exists, or the earliest year was 0
  completions (percent change from zero is undefined), genuinely unknowable, not 0%
  growth.

**Options considered:**
1. **Exclude** the 192 affected rows from scoring. Clean, but not neutral: the 77
   no-labor-match rows are systematically the most niche/undocumented fields, so
   excluding them removes a specific category of program for a data-completeness
   reason unrelated to merit. Also breaks the project's existing pattern of flagging
   exclusions rather than silently dropping rows.
2. **Partial reweight**: drop the missing metric(s) for that row and rescale the
   remaining weights to sum to 100% for that candidate. Keeps every candidate ranked,
   uses only real signal. Risk: a candidate scored on only 2 to 4 of 5 components could
   rank higher than its true position without ever being tested against what's
   missing.
3. **Neutral placeholder**: impute a middle value (e.g. the metric's median) for the
   missing metric. Asserts "average" for something with zero actual signal, which is
   less honest than option 2, and requires justifying what "neutral" means against
   distributions already shown to be heavily skewed.

**Recommended: option 2, partial reweight**, paired with a visible `n_metrics_used`
column in the scored output so any Go/Test/Pass call resting on partial data is visible
at a glance.

## 5. Not yet done

Go/Test/Pass band cutoffs are intentionally not proposed here. Per the plan agreed
before this analysis started, cutoffs get set from the real score distribution once the
score is actually computed. That's the next step after this report is verified and the
method above is approved.

Done: the cutoffs were set from the real distribution in `sql/06` (Go at the top
decile, score ≥ 75.3; Test above the median, 45.7 to 75.3; Pass below the median). See
`docs/decisions-log.md`.

## Status

Nothing in sections 2 through 4 is implemented in SQL. This is a findings report and
recommendation, written to be checked, not a locked decision. See
`docs/decisions-log.md` for what's been logged as considered-but-not-adopted. Every
number in this report was independently recomputed from
`data/derived/derived_candidates.csv` in `notebooks/phase3_ai_report_verification.ipynb`
before the method was approved.

Done: the method above was approved and implemented in `sql/06` through `sql/08`.
