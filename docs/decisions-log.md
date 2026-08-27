# Decisions log

Key methodology decisions behind this analysis, and the data-quality issues found and
handled along the way, so the reasoning behind each number is checkable.

## Method: candidates are derived from data

The candidate universe is every CIP6 field of study in IPEDS's national completions
data — 1,268 fields — cross-referenced against national labor-market demand (BLS
Employment Projections) and Vanderbilt's own online catalog. A field survives as a
candidate because the data places it there: real student demand, real labor demand,
and not already offered by Vanderbilt.

## Data cleaning and known gaps

Three source-data issues came up during cleaning and got handled explicitly:

- **Suppressed years.** IPEDS withholds low-count cells for privacy. 319 of 1,290
  CIP6 codes are missing at least one of the 13 years (2012–2024). Missing years stay
  missing.
- **Unmatched CIP codes.** 22 of 1,290 IPEDS CIP6 codes have no match anywhere in the
  official CIP↔SOC crosswalk — all ultra-niche programs (Taxidermy, Talmudic Studies).
  These are dropped from the candidate pool, with the reason documented.
- **Unmatched SOC codes.** 12 of 832 BLS occupation codes have no crosswalk match. 7
  are broad occupational groups the crosswalk maps at a more detailed level instead
  (Home Health and Personal Care Aides maps to two more specific codes); the other 5
  are small genuine gaps. Same treatment: dropped, with the reason documented.

## Labor-demand matching: the CIP↔SOC join rule

Every field of study connects to multiple occupations. The rule: for each CIP code,
take its top 3 matched occupations by 2024 employment, then combine each labor-demand
metric across those 3 using an employment-weighted average — the largest occupation
among the three counts most, but all three contribute. A field with fewer than 3
matches uses however many it has. This captures more of a field's real career breadth
than a single primary occupation would, while avoiding the distortion of exploding
every match (some CIP codes have over 100).

## Scoring methodology

Four continuous metrics feed the composite score — current completions, completions
trend, employment-weighted job openings, and employment-weighted job growth — plus one
flag (whether a matched occupation appears on BLS's own fastest-growing or
most-new-jobs lists). Three methodology choices:

**Normalization: percentile rank.** Two of the four metrics are extremely
right-skewed — a handful of catch-all fields (Business Administration, with 97,150
national completions against a median of 64.5) dwarf everything else. Min-max scaling
would let that single outlier define the top of the scale and crush every other
field's score toward zero. Percentile rank uses relative position, so outlier
magnitude has no effect on it.

**Weights: 30% current completions, 30% job openings, 15% completions trend, 15% job
growth, 10% the BLS top-30 flag.** Current size outweighs trend on purpose. Given the
skew above, a huge trend percentage is often a small-base artifact — one field goes
from 1 completion to 331 over the period, a 33,000% increase — and current size is the
sturdier signal.

**Missing data: partial reweight.** A candidate missing a metric (77 fields have no
labor-market match at all, 126 have no usable completions trend) is scored on whatever
it has, with the remaining weights rescaled to still sum to 100% for that field. A
record of how many metrics backed each score travels with it, so a partial-data score
is visibly distinct from a fully-supported one.

## Setting the Go / Test / Pass bands

Cutoffs come from the real score distribution. The scored population is 1,254 fields
(1,268 minus the 14 Vanderbilt already offers). The distribution is smooth and roughly
unimodal, with no natural break anywhere, so the cutoffs use a named, pre-existing
convention: **Go** is the top decile (score ≥ 75.3), **Test** is above the median
(45.7–75.3), **Pass** is below the median (< 45.7). Resulting counts: 126 Go, 502 Test,
626 Pass.

## Data-quality flags

Two limitations are carried forward as explicit flags. Fixing either would mean
redefining a rule the entire pipeline depends on:

- **A generic occupation code inflates some labor-demand scores.** The top 5 fields by
  job-openings score all share SOC 11-1021, "General and Operations Managers" — a
  broad catch-all occupation that pulls the score up without reflecting demand
  specific to the field. Excluding generic occupation codes from the join rule would
  need a defensible definition of "generic," which wasn't in scope to design here, so
  this is flagged per-candidate instead.
- **Wage data covers a small slice of occupations.** Median-pay figures exist for only
  60 of 832 occupations (BLS's two pre-ranked top-30 lists) — too sparse to blend into
  the scoring metrics honestly, so it's used only as the boolean flag noted above.

## The Vanderbilt Nursing-catalog gap

Vanderbilt's source catalog recorded its online Master of Science in Nursing as a
single row. Its other multi-track programs, like Peabody's M.Ed. tracks, are recorded
one row per specialty. That gap meant the "already offered" exclusion logic couldn't
catch that several Nursing-specialty fields were already offered online. Found while
reviewing the finalist candidates, and confirmed against Vanderbilt's official
Registrar CIP list: 7 of a 13-member candidate cluster matched a named Vanderbilt
Nursing specialty exactly.

The underlying catalog data is demonstrably incomplete for this specific program
family, so all 13 members of the cluster were excluded from the final ranking as a
precaution, including the 6 without a confirmed match. The full fix, rebuilding the
source catalog data at the correct grain, is logged as future scope.

## Clustering near-duplicate programs

Within the Go-band candidates, many CIP codes describe near-identical program ideas
under different codes — multiple Nursing-specialty variants, for example. These were
grouped using two signals: shared significant words in the program title, and matching
4-digit CIP prefixes (the government's own taxonomy grain). 126 Go-band candidates
reduced to 27 clusters of 2–13 members plus 34 unclustered singles, roughly 60
distinct real-world program ideas. Each cluster's rank comes from its single
highest-scoring member. Most clusters are genuinely different credentials, and the
underlying question is which one program to launch, so an average across the cluster
would blur exactly the distinction that matters.

## Deliverables

Five finalists cleared every check: MSc. in Data Science, MSc. in Applied Informatics,
MSc. in Quantitative Economics, MSc. in Business Analytics, and MSc. in Information
Science. A five-chart Tableau dashboard, a written feasibility report, and an
11-slide presentation deck are the final outputs, all in `deliverables/`.
