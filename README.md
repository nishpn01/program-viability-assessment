# Program Viability Assessment

**Which new online graduate program should Vanderbilt launch next?**

A market-research analysis that combines national labor-market demand (BLS) and
national student-demand data (IPEDS completions) to identify graduate fields Vanderbilt
doesn't currently offer online, then works toward a **Go / Test / Pass** recommendation
for which one to launch next.

Modeled on a real Vanderbilt Office of the Deputy Provost (ODP) Data Analyst job
posting — market research for new academic/professional programs. This is a
self-directed learning project, not client work: the goal is to practice that role's
actual day-to-day (data collection, cleaning, SQL, and a defensible recommendation)
end to end, and to document the real decisions and corrections along the way, not just
present a polished final answer.

## The question

Of the graduate fields Vanderbilt does **not** already offer online, which are the
strongest candidates for a new program? Vanderbilt's current online catalog is the
baseline it's measured against (provenance in `docs/data-sources.md`).

## Method — data-first, not pre-picked

Candidate programs are **derived from the data**, not hand-selected. National
labor-market demand (BLS Employment Projections) and national student demand (IPEDS
completions by field) are joined through the official CIP↔SOC crosswalk, then checked
against Vanderbilt's current catalog. Fields that are in demand, have a real student
market, and aren't already offered survive as candidates. Full reasoning trail:
`docs/decisions-log.md`.

## Where this stands today

- **Data collection and cleaning** — done. Six source tables, cleaned into `data/clean/`.
- **SQL join/derive** — done. A local Postgres database joins the cleaned tables into
  one analysis table, `derived_candidates` (1,268 candidate fields, each with a
  student-demand trend and a labor-demand score). Detail: `docs/sql-walkthrough.md`.
- **Scoring, dashboard, and final recommendation** — in progress.

This project is being built openly as a learning exercise — the docs in `docs/` capture
the actual decisions, corrections, and dead ends along the way, not just the final
numbers.

## Repo structure

| Path | What lives here |
|------|-----------------|
| `data/raw/` | Source tables as collected, **never edited after collection** |
| `data/clean/` | Analysis-ready tables (typed, standardized) |
| `data/derived/` | The joined analysis table (`derived_candidates`), exported from SQL |
| `scripts/` | Collection, cleaning, and pipeline scripts (reproducible) |
| `sql/` | The staging DDL, load, verification, and join/derive queries |
| `dashboard/` | Tableau workbook + exported chart images (Phase 4, pending) |
| `docs/` | Problem statement, provenance, decisions, glossary, and the final recommendation |

## Data sources (all public, all free)

- **BLS Employment Projections** — occupational demand, growth, and annual openings
- **IPEDS** (via the datausa.io API) — national program completions by field, 2012–2024
- **NCES CIP↔SOC crosswalk** — the official mapping linking BLS occupations (SOC) to
  IPEDS fields of study (CIP)
- **Vanderbilt's own online program catalog** and official CIP code list

Full provenance, pull dates, and access notes: `docs/data-sources.md`.

## Limitations (current build)

- **Single university case study.** The method generalizes, but the numbers are
  specific to Vanderbilt's catalog and wouldn't transfer to another school without
  re-pulling its program list.
- **Fine-grained candidates.** Each row is one raw 6-digit CIP code (1,268 of them) —
  some are near-duplicate specializations that a person would read as one "candidate
  program." Clustering related codes together is planned but not done yet.
- **Thin wage coverage.** Median-pay data only exists for 60 of 832 occupations, so
  it's used as a flag, not blended into the demand score.
- **No primary research.** Every signal here is public, secondary data — no surveys or
  interviews.

## Future scope (deliberately deferred, not abandoned)

These were part of the original plan and are coming back after the current deadline:

- **Competitor pricing** — tuition/format benchmarking against peer online programs.
- **A search-interest / demand-trend signal** (e.g. Google Trends) — IPEDS already
  gives a completions trend, so this would be an enrichment, not a blocker.
- **CIP clustering** at the shortlist stage, so the dashboard shows recognizable
  "candidate programs" instead of raw 6-digit codes.
- **Porting the SQL layer to BigQuery** (currently local Postgres) — a planned exercise
  once the deadline has passed.
- **Extending the method** to more than one university.

## Method note

Built with AI assistance (Claude) for the mechanical work — scraping, parsing,
cleaning, and SQL — while the framing, judgment calls, and final recommendation are my
own. Every source is logged in `docs/data-sources.md`, and every non-obvious decision
(including places where I corrected the AI, or it caught something I'd missed) is
logged in `docs/decisions-log.md` — the goal is a project that's fully reproducible and
auditable, not a black box.

---

*A learning-in-public portfolio project by Pranish Pakwan.*
