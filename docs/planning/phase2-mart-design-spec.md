# Phase 2: mart design spec for `derived_candidates` (join/derive logic)

*The design for the final step of Phase 2, the logic that `sql/01` through `sql/05`
implement. Drafted during Phase 2 planning (2026-08-01/02) and extracted into this
standalone file on 2026-08-04 so the mart's design is documented separately from the
code that implements it. Lives in `docs/planning/`, public alongside the rest of that
folder.*

## Objective

One analysis-ready table (a "mart"), `derived_candidates`: **one row per candidate
program** (CIP 2020 six-digit code), combining national student demand (IPEDS) with
labor-market demand (BLS, connected through the CIP↔SOC crosswalk), and flagging
overlap with Vanderbilt's current online catalog. This table is the scoring step's
input; it contains no scoring math.

## The design: five steps

**1. Base table from IPEDS.** Group the cleaned IPEDS completions table by
`cip2020_code` (1,268 distinct codes, the candidate universe). For each code, pull the
latest year's completions and a trend indicator (% change from earliest to latest
available year), the national student demand side. "Available" matters: IPEDS
suppresses low counts, so each CIP uses its own earliest/latest years, and a
single-year CIP gets an unknown (NULL) trend, not a fake 0%.

**2. Attach labor demand via the crosswalk.** For each CIP, look up all its matched SOC
codes in the cleaned crosswalk, join those to the BLS openings table for
`employment_2024` and `occupational_openings_2024_34`, take the **top 3 SOCs by 2024
employment** (locked rule, see `decisions-log.md`), and combine each metric via an
**employment-weighted average** (bigger occupations count more, deliberately). If a CIP
has fewer than 3 matched SOCs with data, use however many exist and record how many.
Don't force 3, and don't drop the row.

**3. Bring in the pre-ranked BLS lists as a bonus flag, not a metric.** The
comprehensive 832-row openings table has no wage data at all. Median pay exists only in
the fastest-growing / most-new-jobs tables, and those cover just 30 SOC codes each. Too
sparse to blend into the step-2 weighted metrics without pretending there's wage
coverage that isn't there. Use the two lists only as a lightweight boolean flag: does
this CIP's top-3 SOC list include an occupation from either BLS top-30 list?

**4. Flag what Vanderbilt already offers.** Compare each candidate's `cip2020_code`
against Vanderbilt's assigned codes, **exact CIP6 match only** (not a broader family
match): it reads "not offered by Vanderbilt" literally and stays checkable/auditable.
Keep it as a **flag column** rather than silently dropping rows, so it's always visible
which programs got excluded and why.

**5. Finalize `derived_candidates`.** One row per CIP2020 code, staying at fine CIP6
grain, no clustering, no scoring math yet. Target columns: the code and title,
latest-year completions plus the trend, the matched SOC list and how many back the
numbers, the two employment-weighted labor metrics, the BLS top-30 flag, and the
already-offered-by-Vanderbilt flag.

## Integrity rules the implementation must follow

- **NULL means "unknown"; zero means "checked, truly zero."** Never fill an unknown
  with 0. An uncomputable trend stays NULL, while a SOC-match count of 0 is a real zero.
- **No silent row loss.** Join direction must guarantee all 1,268 candidates survive,
  even those with no labor-market match (they keep NULL metrics).
- **Exact join keys.** Identifier codes are text or exact decimals, never floating
  point (the ERD documents why).
- **Verify before building.** Loaded data must be checked against the data
  dictionary's known counts, including the known gaps, before anything is built on top
  of it.

## Amendments found during build verification (kept, not hidden)

- Vanderbilt's 15 programs map to **14 distinct** CIP codes: two M.Ed. programs
  legitimately share 13.0401, confirmed against the Registrar's official PDF (in this
  folder). The flag matches on the 14.
- The float join-key risk flagged in the ERD got a structural fix (`NUMERIC(7,4)`),
  not just a warning comment.
- The suppressed-years trend rule (per-CIP year window; NULL for single-year CIPs) was
  made explicit rather than left implied.

## Out of scope by design

Scoring and Go/Test/Pass cutoffs (Phase 3; cutoffs wait for the real score
distribution); CIP clustering (shortlist stage only); BigQuery port (post-call
exercise).
