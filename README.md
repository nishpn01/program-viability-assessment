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
  student-demand trend and a labor-demand score). Detail: inline comments in `sql/01`–`05`.
- **Scoring and shortlisting** — done. A 0–100 composite score, Go/Test/Pass bands set
  from the real score distribution, and near-duplicate CIP codes within the Go band
  clustered into ~60 distinct candidate programs (e.g. 13 separate Nursing-specialty
  codes read as one cluster). Five finalists selected and named —
  `docs/planning/phase3-finalist-program-naming-recommendations.md`.
- **Dashboard** — done, published to Tableau Public.
- **Final written recommendation and presentation deck** — done. Both are in
  `deliverables/`, alongside the dashboard.

All five phases are now complete. This project was built openly as a learning
exercise — the docs in `docs/` capture the actual decisions, corrections, and dead
ends along the way, not just the final numbers.

## Repo structure

| Path | What lives here |
|------|-----------------|
| `data/raw/` | Source tables as collected, **never edited after collection** |
| `data/clean/` | Analysis-ready tables (typed, standardized) |
| `data/derived/` | The joined analysis table (`derived_candidates`) and every downstream scoring/shortlist export, all from SQL |
| `scripts/` | Collection, cleaning, and pipeline scripts (reproducible) |
| `sql/` | The staging DDL, load, verification, scoring, and shortlisting queries |
| `notebooks/` | Independent verification of AI-generated analysis (e.g. re-deriving a findings report's numbers from source data, cell by cell) and the Phase 5 report figures |
| `deliverables/` | The final, shareable outputs: the Tableau workbook, the feasibility report PDF, and the presentation deck |
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
- **Thin wage coverage.** Median-pay data only exists for 60 of 832 occupations, so
  it's used as a flag, not blended into the demand score.
- **A generic occupation code inflates some labor-demand scores.** The CIP↔SOC join
  rule (top-3 matched occupations by employment size) is applied uniformly, but SOC
  11-1021 ("General and Operations Managers") is large enough to dominate that average
  for several thematically unrelated management-adjacent fields. Flagged per-candidate
  rather than fixed — excluding a generic occupation code would need a defined,
  defensible rule that wasn't in scope to design here.
- **Vanderbilt's own catalog data is incomplete for at least one program family.**
  The source catalog recorded Vanderbilt's "Master of Science in Nursing" as one row,
  not one row per specialty track, so the exclusion logic couldn't catch that several
  Nursing-specialty CIP codes are already offered online. Found and patched at the
  shortlist stage (the whole Nursing cluster excluded, not just the confirmed matches);
  the real fix is a source-data rebuild, logged as future scope below.
- **No primary research.** Every signal here is public, secondary data — no surveys or
  interviews.

## Future scope (deliberately deferred, not abandoned)

- **Rebuild Vanderbilt's catalog data at full granularity** — add Vanderbilt's Nursing
  (and possibly other umbrella-program) specialty tracks as individual CIP-coded rows,
  then rerun the full pipeline. The most concrete item here, found late in Phase 3.
- **Competitor pricing** — tuition/format benchmarking against peer online programs.
- **A search-interest / demand-trend signal** (e.g. Google Trends) — IPEDS already
  gives a completions trend, so this would be an enrichment, not a blocker.
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
