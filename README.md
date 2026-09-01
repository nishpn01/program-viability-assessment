# Program Viability Assessment

**Which new online graduate program should Vanderbilt launch next?**

This scores every graduate field in the national completions data on student demand and
labor-market demand, then ranks the ones Vanderbilt does not already offer online.
1,254 fields in, five finalists out.

[![Online program viability dashboard: KPI row, ranked finalists, score distribution, and completions trend](deliverables/dashboard/dashboard-screenshot.png)](https://public.tableau.com/app/profile/pranish.p7454/viz/OnlineProgramViabilityAssessment/Program_Overview_Dashboard2)

[Open the interactive dashboard on Tableau Public](https://public.tableau.com/app/profile/pranish.p7454/viz/OnlineProgramViabilityAssessment/Program_Overview_Dashboard2)

## Deliverables

- [Feasibility report (PDF)](deliverables/phase5-feasibility-report.pdf), the full
  written recommendation with methodology and limitations
- [Presentation deck (PPTX)](deliverables/phase5-presentation-deck.pptx), 11 slides
- [Tableau workbook (TWBX)](deliverables/dashboard/OnlineProgramViabilityAssessment_v1.twbx),
  the packaged dashboard with its data extracts

## The result

Five programs cleared every check. Scores are 0 to 100 composites built from five
weighted signals.

| Proposed program               | CIP code | Score |
| ------------------------------ | -------- | ----- |
| MSc. in Data Science           | 30.7001  | 93.9  |
| MSc. in Applied Informatics    | 11.0104  | 92.3  |
| MSc. in Quantitative Economics | 45.0603  | 92.0  |
| MSc. in Business Analytics     | 30.7102  | 91.6  |
| MSc. in Information Science    | 11.0401  | 90.3  |

Program names are proposals. Federal CIP titles are a statistical classification for
reporting and would never appear on a diploma, so each finalist was renamed against
Vanderbilt's own catalog conventions and checked for collisions with existing programs.
That check caught a real problem: a residential Data Science master's exists under a
different CIP code than the one this analysis matched on, which a pure code join would
have missed. Full reasoning in
[`docs/planning/phase3-finalist-program-naming-recommendations.md`](docs/planning/phase3-finalist-program-naming-recommendations.md).

## Methodology

The candidate universe is every CIP6 field of study in IPEDS national completions, all
1,268 of them, cross-referenced against BLS Employment Projections. The 14 fields
Vanderbilt already offers online are flagged and held out, leaving 1,254 to score.
The initial candidate set and score bands were derived from the data. Manual review came
later, when the finalists were checked against Vanderbilt's catalog and naming conventions.

**Joining student demand to labor demand.** IPEDS is keyed on CIP program codes and BLS
on SOC occupation codes, and the two do not share a code space. The official NCES
crosswalk bridges them, but the relationship is many-to-many: one field averages 2.8
matched occupations and can reach 180. The rule locked here takes each field's top 3
occupations by 2024 employment and combines their metrics with an employment-weighted
average, so a field's career breadth counts without letting a long tail of loose matches
dominate.

**Scoring.** Four continuous metrics plus one corroborating flag, weighted 30% current
completions, 30% job openings, 15% completions trend, 15% job growth, 10% appearance on
a BLS top-30 list. Normalization is percentile rank rather than min-max, because two
metrics are heavily right-skewed: Business Administration alone reports 97,150
completions against a median of 64.5, and min-max scaling would let that single field
define the top of the scale and crush everything else toward zero. Fields missing a
metric are scored on what they have, with the remaining weights rescaled, and a count of
how many metrics backed each score travels with it.

**Banding and shortlisting.** Cutoffs come from the real score distribution once it
existed: Go is the top decile (score ≥ 75.3), Test runs from the median up to that cutoff
(45.7 to 75.2), Pass falls below the median. That produces 126 Go, 502 Test, 626 Pass.

Within the Go band, near-identical CIP codes were grouped by shared title words and
4-digit CIP prefix, reducing 126 codes to 61 distinct program ideas. 60 of those were
ranked once the Nursing cluster was excluded (see Limitations). Each group is ranked by
its strongest single member, since most clusters group genuinely different credentials
and averaging would blur the distinction the ranking exists to make.

Key decisions, tradeoffs, and the data-quality problems found along the way:
[`docs/decisions-log.md`](docs/decisions-log.md).

## Repository guide

| Path              | What lives here                                                                                    |
| ----------------- | -------------------------------------------------------------------------------------------------- |
| `data/raw/`     | Source tables as collected, never edited after collection                                          |
| `data/clean/`   | Analysis-ready tables, typed and standardized                                                      |
| `data/derived/` | The joined analysis mart and every downstream scoring and shortlist export                         |
| `scripts/`      | Collection, cleaning, and pipeline scripts                                                         |
| `sql/`          | Staging DDL, load, verification, scoring, banding, and shortlisting, numbered in run order         |
| `notebooks/`    | Independent verification of the scoring analysis, and the report figures                           |
| `deliverables/` | Tableau workbook, feasibility report PDF, presentation deck                                        |
| `docs/`         | Problem statement, provenance, decisions, data dictionary, ERD, glossary, and phase planning specs |

### Key files

If you only open a few things, open these.

| File                                                                                              | Why open it                                                                                              |
| ------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| [`docs/problem-statement.md`](docs/problem-statement.md)                                         | The question, what was in and out of scope, the role this models, and the independent-project disclaimer |
| [`docs/decisions-log.md`](docs/decisions-log.md)                                                 | Key methodology decisions, plus the data-quality problems found and what was done about each              |
| [`docs/erd.md`](docs/erd.md)                                                                     | The data model as a rendered diagram: 14 tables from raw source through dashboard extract                |
| [`docs/data-sources.md`](docs/data-sources.md)                                                   | Provenance for every table, with pull dates and URLs, so any number can be traced back                   |
| [`sql/04_build_derived_candidates.sql`](sql/04_build_derived_candidates.sql)                     | The join that produces the analysis mart, with the reasoning in inline comments                          |
| [`notebooks/phase3_ai_report_verification.ipynb`](notebooks/phase3_ai_report_verification.ipynb) | Every number in the scoring findings recomputed from source data before the method was approved          |
| [`docs/planning/phase2-mart-design-spec.md`](docs/planning/phase2-mart-design-spec.md)           | The mart design written before any SQL, which the SQL then implements                                    |
| [`docs/working-with-ai.md`](docs/working-with-ai.md)                                             | Where AI assistance failed on this build, what it cost, and the checks that caught it                    |

New to the domain? [`docs/glossary.md`](docs/glossary.md) defines CIP, SOC, and the rest
in plain language. [`docs/data-dictionary.md`](docs/data-dictionary.md) profiles every
column in every table.

## Data sources

All public, all free.

- **BLS Employment Projections**, occupational demand, growth, and annual openings
- **IPEDS** via the datausa.io API, national completions by field, 2012 to 2024
- **NCES CIP to SOC crosswalk**, the official mapping between fields of study and occupations
- **Vanderbilt's online program catalog** and its Registrar CIP code list

Full provenance with pull dates and URLs: [`docs/data-sources.md`](docs/data-sources.md).

## Tools

PostgreSQL 18 handles the joins, scoring, banding, and shortlisting. Python with pandas
collects and cleans the source data; matplotlib, NumPy, and SciPy support verification and
report figures. Tableau Public presents the final dashboard.

## Limitations

- The labor and completions signals are national. Vanderbilt-specific faculty capacity,
  curriculum fit, regional demand, pricing, and enrollment economics are not available.
- Median pay exists for only 60 of 832 occupations, so wage is a flag instead of a scored
  metric.
- SOC 11-1021, "General and Operations Managers," can inflate labor-demand scores for
  management-adjacent fields. The analysis flags affected candidates but does not remove
  the occupation without a defensible rule for doing so.
- Vanderbilt's source catalog records Nursing at a coarser level than its specialty
  offerings. The full Nursing cluster was excluded after manual review found seven direct
  specialty matches.
- Percentile scoring preserves rank but discards magnitude. Score bands are conventions
  applied to a smooth distribution, not natural breaks in the data.
- Missing and suppressed IPEDS observations leave candidates with unequal trend windows
  and, in some cases, fewer metrics supporting the composite score.

[`docs/decisions-log.md`](docs/decisions-log.md) documents these limitations, their effect
on the analysis, and the work needed to resolve them.

## Future scope

The next pass would rebuild Vanderbilt's catalog at specialty-level grain, define and
test a rule for generic occupation codes, and add competitor pricing and program format.
Those changes address the largest known weaknesses in the current recommendation.

The dashboard could then add filters for labor corroboration and data-quality flags. A
school or college filter depends on mapping each finalist to its likely academic owner.

## AI assistance and verification

AI assisted with scraping, parsing, cleaning, SQL drafts, and document production. The
analytical framing, methodology decisions, and recommendation remained the analyst's
responsibility. Design specifications were written before implementation, and material
AI-produced results were checked against the source data before acceptance.

[`docs/working-with-ai.md`](docs/working-with-ai.md) records the failures that shaped this
process, including incorrect high-confidence matches, false clustering, incomplete visual
checks, and unverified repository status. Starter prompts are preserved in
[`docs/ai-prompts-log.md`](docs/ai-prompts-log.md).

---

*Modeled on a Vanderbilt Office of the Deputy Provost Data Analyst posting,
using only public data.*
