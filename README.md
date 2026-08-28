# Program Viability Assessment

**Which new online graduate program should Vanderbilt launch next?**

Every graduate field in the national completions data gets scored against student demand
and labor-market demand, checked against what Vanderbilt already offers online, and
sorted into a Go / Test / Pass verdict. 1,254 candidate fields in, five finalists out.

[![Online program viability dashboard: KPI row, ranked finalists, score distribution, and completions trend](deliverables/dashboard/dashboard-screenshot.png)](https://public.tableau.com/app/profile/pranish.p7454/viz/OnlineProgramViabilityAssessment/Program_Overview_Dashboard2)

[Open the interactive dashboard on Tableau Public](https://public.tableau.com/app/profile/pranish.p7454/viz/OnlineProgramViabilityAssessment/Program_Overview_Dashboard2)

## The result

Five programs cleared every check. Scores are 0 to 100 composites built from five
weighted signals.

| Proposed program | CIP code | Score |
|---|---|---|
| MSc. in Data Science | 30.7001 | 93.9 |
| MSc. in Applied Informatics | 11.0104 | 92.3 |
| MSc. in Quantitative Economics | 45.0603 | 92.0 |
| MSc. in Business Analytics | 30.7102 | 91.6 |
| MSc. in Information Science | 11.0401 | 90.3 |

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
Nothing was shortlisted by hand at any point.

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
(45.7 to 75.2), Pass falls below the median. That produces 126 Go, 502 Test, 626 Pass. Within the Go band, near-identical
CIP codes were grouped by shared title words and 4-digit CIP prefix, reducing 126 codes
to 61 distinct program ideas, 60 of which were ranked once the Nursing cluster was
excluded (see Limitations). Each group is ranked by its strongest single member, since
most clusters group genuinely different credentials and averaging would blur the
distinction the ranking exists to make.

Decisions, tradeoffs, and the data-quality problems found along the way:
[`docs/decisions-log.md`](docs/decisions-log.md).

## What's in this repo

| Path | What lives here |
|------|-----------------|
| `data/raw/` | Source tables as collected, never edited after collection |
| `data/clean/` | Analysis-ready tables, typed and standardized |
| `data/derived/` | The joined analysis mart and every downstream scoring and shortlist export |
| `scripts/` | Collection, cleaning, and pipeline scripts |
| `sql/` | Staging DDL, load, verification, scoring, banding, and shortlisting, numbered in run order |
| `notebooks/` | Independent verification of the scoring analysis, and the report figures |
| `deliverables/` | Tableau workbook, feasibility report PDF, presentation deck |
| `docs/` | Provenance, decisions, data dictionary, ERD, glossary, and phase planning specs |

## Where to look

If you only open a few things, open these.

| File | Why open it |
|---|---|
| [`docs/decisions-log.md`](docs/decisions-log.md) | Every methodology decision, plus the data-quality problems found and what was done about each |
| [`docs/erd.md`](docs/erd.md) | The data model as a rendered diagram: 14 tables from raw source through dashboard extract |
| [`docs/data-sources.md`](docs/data-sources.md) | Provenance for every table, with pull dates and URLs, so any number can be traced back |
| [`sql/04_build_derived_candidates.sql`](sql/04_build_derived_candidates.sql) | The join that produces the analysis mart, with the reasoning in inline comments |
| [`notebooks/phase3_ai_report_verification.ipynb`](notebooks/phase3_ai_report_verification.ipynb) | Every number in the scoring findings recomputed from source data before the method was approved |
| [`docs/planning/phase2-mart-design-spec.md`](docs/planning/phase2-mart-design-spec.md) | The mart design written before any SQL, which the SQL then implements |

New to the domain? [`docs/glossary.md`](docs/glossary.md) defines CIP, SOC, and the rest
in plain language. [`docs/data-dictionary.md`](docs/data-dictionary.md) profiles every
column in every table.

## Data sources

All public, all free.

- **BLS Employment Projections**, occupational demand, growth, and annual openings
- **IPEDS** via the datausa.io API, national completions by field, 2012 to 2024
- **NCES CIP to SOC crosswalk**, the official mapping between fields of study and occupations
- **Vanderbilt's online program catalog** and its Registrar CIP code list

## Limitations

- **Single university.** The method transfers; the numbers do not, without re-pulling another school's catalog.
- **Thin wage coverage.** Median pay exists for 60 of 832 occupations, too sparse to blend into the score, so it is used as a flag.
- **One generic occupation code inflates some scores.** SOC 11-1021, "General and Operations Managers," is large enough to lift several unrelated management-adjacent fields. Flagged per candidate, since excluding generic codes would need a defensible definition of "generic."
- **Vanderbilt's catalog data is incomplete for one program family.** Nursing was recorded as a single row instead of one row per specialty track, so the exclusion logic missed specialties already offered online. Caught at the shortlist stage and patched by excluding the whole cluster.
- **No primary research.** Every signal is public secondary data.

Each of these is worked through in full in
[`docs/decisions-log.md`](docs/decisions-log.md), including what it would take to fix
the two that were flagged instead of solved.

## Future scope

- **Rebuild the Vanderbilt catalog at full granularity**, adding specialty tracks as individual CIP-coded rows, then rerun the pipeline. The most concrete item here.
- **Competitor pricing**, benchmarking tuition and format against peer online programs.
- **A search-interest signal** such as Google Trends, as enrichment on the existing completions trend.
- **Port the SQL layer to BigQuery**, currently local Postgres.
- **Extend the method** beyond one university.

## Method note

AI assistance was used for the mechanical work: scraping, parsing, cleaning, and drafting
SQL. Each script and query names the starter prompt behind it, and those prompts are
collected in [`docs/ai-prompts-log.md`](docs/ai-prompts-log.md). The design specs the SQL
implements were written first, and live in `docs/planning/`. Where AI-produced analysis
fed a decision, the numbers were recomputed from source data before the method was
accepted; `notebooks/phase3_ai_report_verification.ipynb` is that check for the scoring
model.

---

*Built by Pranish Pakwan. Modeled on a Vanderbilt Office of the Deputy Provost Data
Analyst posting, using only public data.*
