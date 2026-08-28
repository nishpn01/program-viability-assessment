# Data sources and provenance

Where each table's data comes from, so every number is auditable.

| Table | Source | URL | Pulled on | Notes |
|-------|--------|-----|-----------|-------|
| `vanderbilt_current_programs.csv` | Vanderbilt Online Learning catalog (degrees + certificates archive) | vanderbilt.edu/online-learning/program-type/degrees · /certificates | 2026-07-23 | 15 degrees + 12 certificates; ~90 free Coursera courses excluded; featured-vs-archive listing discrepancy flagged for re-verify |
| `bls_labor_demand.csv` | BLS Occupational Outlook Handbook (via Firecrawl scrape, `scripts/scrape_labor_demand.sh`) | www.bls.gov/ooh/... (12 pages, one per candidate; the intermediate scrape files are not published) | 2026-07-23 | 2024 median pay, entry-level education, number of jobs (2024), 2024–34 job outlook growth %, 2024–34 employment change; one closest-match BLS occupation per candidate (proxy, not exact program match). Superseded first-pass sample, not an analysis input; the broad BLS Employment Projections tables replaced it. |
| `competitors_pricing.csv` | Competitor program pages (Firecrawl) + IPEDS | | **Cut 2026-08-01** | Cut entirely from this project's scope. No raw file exists and none is planned. Carried forward as future scope in `README.md`. |
| `student_demand.csv` | Google Trends + IPEDS completions | | **Cut 2026-08-01** | Cut entirely, same reasoning as above. Google Trends also failed a live reachability test (HTTP 429), and IPEDS multi-year completions covers the demand-trend signal on its own. |
| `docs/planning/CIP_Codes.pdf` | Vanderbilt Registrar's official CIP code list ("Reviewed August 2025") | Tracked and public in `docs/planning/`. Deliberate (Pranish, 2026-08-08): it's not treated as sensitive, so it goes in the public planning folder like everything else there. (This row previously said "not tracked in git, university-internal PDF," reflecting an earlier, since-superseded assumption.) | 2026-08-01 | Used to assign/verify `cip2020_code` for 13 of Vanderbilt's 15 online Master's/Doctorate programs; sourced directly rather than scraped. The remaining 2 of 15 came from the algorithmic shortlist (`scripts/suggest_vanderbilt_cip_codes.py`), used only where the official list has no entry. |
| `bls_occupational_openings.csv` | BLS Employment Projections, Table 1.10 (via Firecrawl scrape, `scripts/parse_bls_projections.py`; raw scrape in `data/raw/bls_projections_raw/table_1_10_openings.md`) | bls.gov/emp/tables/occupational-separations-and-openings.htm | 2026-07-24 | 1,113 rows (832 "Line item" detail occupations, rest are category-summary rollups; filter `Occupation type == Line item` before use); SOC-keyed; 2024–34 annual-average occupational openings, employment 2024/2034, separations/transfer rates |
| `bls_fastest_growing.csv` | BLS Employment Projections, Table 1.3 | bls.gov/emp/tables/fastest-growing-occupations.htm | 2026-07-24 | 31 rows (pre-ranked list, includes "Total, all occupations" header row); SOC-keyed |
| `bls_most_new_jobs.csv` | BLS Employment Projections, Table 1.4 | bls.gov/emp/tables/occupations-most-job-growth.htm | 2026-07-24 | 31 rows (pre-ranked list, includes "Total, all occupations" header row); SOC-keyed |
| `cip_soc_crosswalk.xlsx` | NCES official CIP2020↔SOC2018 crosswalk (direct download, unparsed) | nces.ed.gov/ipeds/cipcode/Files/CIP2020_SOC2018_Crosswalk.xlsx | 2026-07-24 | 429 KB xlsx; confirmed many-to-many CIP↔SOC. Join rule locked 2026-08-01: top 3 matched SOCs per CIP by 2024 employment, combined via employment-weighted average (see `decisions-log.md`) |
| `ipeds_completions_masters.csv` | IPEDS completions via datausa.io API (`ipeds_completions` cube, `scripts/parse_ipeds_completions.py`; raw pull in `data/raw/ipeds_completions_masters_raw.json`) | api.datausa.io/tesseract/data.jsonrecords?cube=ipeds_completions&drilldowns=CIP6,Year&measures=Completions&Degree=7 | 2026-07-24 | 14,493 rows; 1,290 distinct CIP6 codes × years 2012–2024; CIP6-keyed, Masters degree level only; IPEDS suppresses low-count cells for privacy, so expect missing years for thin CIP6 programs |

## Why BLS and IPEDS need a crosswalk

BLS tables are keyed on SOC occupation codes. IPEDS is keyed on CIP program codes. The
two systems don't share a code space, so nothing joins them directly. NCES publishes the
official CIP2020 to SOC2018 crosswalk for exactly this purpose, which is why it sits in
the table above as a source in its own right rather than as a lookup detail. Without it,
connecting labor demand to student demand would come down to matching field names by
hand.

## TAM assumption (not used)

Considered in early scoping. The scoring method that shipped (percentile-rank composite,
locked 2026-08-05) reads IPEDS completions straight off as the market-size metric, with
no capture rate to assume, so a TAM calculation was never filled in. Recorded here as an
approach that was considered and dropped.
