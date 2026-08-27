# Decisions log

Key methodology decisions behind this analysis, and the data-quality issues found and
handled along the way — reported here so the reasoning behind each number is
checkable, not just the number itself.

## Method: candidates are derived from data, not hand-picked

The candidate universe isn't a curated shortlist. It's every CIP6 field of study in
IPEDS's national completions data — 1,268 fields — cross-referenced against national
labor-market demand (BLS Employment Projections) and Vanderbilt's own online catalog.
A field survives as a candidate only because the data places it there: real student
demand, real labor demand, and not already offered. Nothing is added or removed by
hand at this stage.

## Data cleaning and known gaps

Three source-data issues were found during cleaning and handled explicitly rather than
silently:

- **Suppressed years.** IPEDS withholds low-count cells rather than reporting a zero.
  319 of 1,290 CIP6 codes are missing at least one of the 13 years (2012–2024).
  Missing years are left missing, never filled with 0.
- **Unmatched CIP codes.** 22 of 1,290 IPEDS CIP6 codes have no match anywhere in the
  official CIP↔SOC crosswalk — all ultra-niche programs (e.g. Taxidermy, Talmudic
  Studies). Dropped from the candidate pool with a documented reason, not forced to a
  match that doesn't exist.
- **Unmatched SOC codes.** 12 of 832 BLS occupation codes have no crosswalk match. 7
  are broad occupational groups the crosswalk maps at a more detailed level instead
  (e.g. Home Health and Personal Care Aides maps to two more specific codes); the
  other 5 are genuine small gaps. Same treatment: dropped, not forced.

## Labor-demand matching: the CIP↔SOC join rule

Every field of study connects to multiple occupations, not one. The rule: for each
CIP code, take its top 3 matched occupations by 2024 employment, then combine each
labor-demand metric across those 3 using an employment-weighted average — the largest
occupation among the three counts most, but all three contribute. A field with fewer
than 3 matches uses however many it has rather than being forced to 3 or dropped.
This captures more of a field's real career breadth than picking a single primary
occupation would, while avoiding the distortion of exploding every match (some CIP
codes have over 100).

## Scoring methodology

Four continuous metrics feed the composite score — current completions, completions
trend, employment-weighted job openings, and employment-weighted job growth — plus one
flag (whether a matched occupation appears on BLS's own fastest-growing or
most-new-jobs lists). Three methodology choices:

- **Normalization: percentile rank, not min-max.** Two of the four metrics are
  extremely right-skewed — a handful of catch-all fields (e.g. Business
  Administration, with 97,150 national completions against a median of 64.5) are
  enormous compared to everything else. Min-max scaling would let that single outlier
  define the top of the scale and crush every other field's score toward zero.
  Percentile rank uses only relative position, so it isn't distorted by outlier
  magnitude.
- **Weights: 30% current completions, 30% job openings, 15% completions trend, 15%
  job growth, 10% the BLS top-30 flag.** Current size outweighs trend on purpose —
  given the skew above, a huge trend percentage is often a small-base artifact —
  one field goes from 1 completion to 331 over the period, a 33,000% increase — rather
  than real momentum.
- **Missing data: partial reweight, not exclusion or a placeholder value.** A
  candidate missing a metric (77 fields have no labor-market match at all, 126 have no
  usable completions trend) is scored on whatever it has, with the remaining weights
  rescaled to still sum to 100% for that field. A record of how many metrics backed
  each score travels with it, so a partial-data score stays visible rather than
  looking identical to a fully-supported one.

## Setting the Go / Test / Pass bands

Cutoffs were set from the real score distribution, not decided in advance. The scored
population is 1,254 fields (1,268 minus the 14 Vanderbilt already offers). The
distribution is smooth and roughly unimodal, with no natural break anywhere — so the
cutoffs use a named, pre-existing convention instead of an invented one: **Go** is the
top decile (score ≥ 75.3), **Test** is above the median (45.7–75.3), **Pass** is below
the median (< 45.7). Resulting counts: 126 Go, 502 Test, 626 Pass.

## Data-quality flags

Two limitations are carried forward as explicit flags rather than corrected, because
fixing either would mean redefining a rule that the entire pipeline depends on:

- **A generic occupation code inflates some labor-demand scores.** The top 5 fields
  by job-openings score all share SOC 11-1021, "General and Operations Managers" — a
  broad catch-all occupation, not evidence of field-specific demand. Excluding generic
  occupation codes from the join rule would require a defensible definition of
  "generic" that wasn't in scope to design here, so this is flagged per-candidate
  instead.
- **Wage data covers a small slice of occupations.** Median-pay figures exist for only
  60 of 832 occupations (BLS's two pre-ranked top-30 lists). Too sparse to blend into
  the scoring metrics honestly, so it's used only as the boolean flag noted above.

## The Vanderbilt Nursing-catalog gap

Vanderbilt's source catalog recorded its online Master of Science in Nursing as a
single row, rather than one row per specialty track the way its other multi-track
programs (e.g. Peabody's M.Ed. tracks) are recorded. That meant the "already offered"
exclusion logic couldn't catch that several Nursing-specialty fields were already
offered online. Found while reviewing the finalist candidates, and confirmed against
Vanderbilt's official Registrar CIP list: 7 of a 13-member candidate cluster matched a
named Vanderbilt Nursing specialty exactly.

Rather than trust the 6 unmatched members of that same cluster as genuinely new — the
underlying catalog data is demonstrably incomplete for this specific program family,
so absence of a match isn't proof of absence — the entire 13-member cluster was
excluded from the final ranking, not just the 7 confirmed matches. The full fix (
rebuilding the source catalog data at the correct grain) is logged as future scope,
not done as part of this analysis.

## Clustering near-duplicate programs

Within the Go-band candidates, many CIP codes describe near-identical program ideas
under different codes (e.g. multiple Nursing-specialty variants). These were grouped
using two signals: shared significant words in the program title, and matching
4-digit CIP prefixes (the government's own taxonomy grain). 126 Go-band candidates
reduced to 27 clusters of 2–13 members plus 34 unclustered singles — roughly 60
distinct real-world program ideas. Each cluster's rank is set by its single
highest-scoring member, not an average across the cluster, since the underlying
question is which one program to launch, and most clusters are genuinely different
credentials rather than one omnibus program.

## Deliverables

Five finalists cleared every check: MSc. in Data Science, MSc. in Applied Informatics,
MSc. in Quantitative Economics, MSc. in Business Analytics, and MSc. in Information
Science. A five-chart Tableau dashboard, a written feasibility report, and an
11-slide presentation deck are the final outputs, all in `deliverables/`.
