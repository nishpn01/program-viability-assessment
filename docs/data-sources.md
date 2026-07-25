# Data Sources & Provenance

Where each table's data comes from, so every number is auditable.

| Table | Source | URL | Pulled on | Notes |
|-------|--------|-----|-----------|-------|
| `vanderbilt_current_programs.csv` | Vanderbilt Online Learning catalog (degrees + certificates archive) | vanderbilt.edu/online-learning/program-type/degrees · /certificates | 2026-07-23 | 15 degrees + 12 certificates; ~90 free Coursera courses excluded; featured-vs-archive listing discrepancy flagged for re-verify |
| `bls_labor_demand.csv` | BLS Occupational Outlook Handbook (via Firecrawl scrape, `scripts/scrape_labor_demand.sh`) | www.bls.gov/ooh/... (12 pages, one per candidate — see raw files in `data/raw/labor_raw/`) | 2026-07-23 | 2024 median pay, entry-level education, number of jobs (2024), 2024–34 job outlook growth %, 2024–34 employment change; one closest-match BLS occupation per candidate (proxy, not exact program match) |
| `competitors_pricing.csv` | Competitor program pages (Firecrawl) + IPEDS | | | tuition, credits, duration, format |
| `student_demand.csv` | Google Trends + IPEDS completions | | | 5-yr search interest; national completions as audience proxy — trend-signal source still pending (see `docs/source-inventory.md` §4) |
| `bls_occupational_openings.csv` | BLS Employment Projections, Table 1.10 (via Firecrawl scrape, `scripts/parse_bls_projections.py`; raw scrape in `data/raw/bls_projections_raw/table_1_10_openings.md`) | bls.gov/emp/tables/occupational-separations-and-openings.htm | 2026-07-24 | 1,113 rows (832 "Line item" detail occupations, rest are category-summary rollups — filter `Occupation type == Line item` before use); SOC-keyed; 2024–34 annual-average occupational openings, employment 2024/2034, separations/transfer rates |
| `bls_fastest_growing.csv` | BLS Employment Projections, Table 1.3 | bls.gov/emp/tables/fastest-growing-occupations.htm | 2026-07-24 | 31 rows (pre-ranked list, includes "Total, all occupations" header row); SOC-keyed |
| `bls_most_new_jobs.csv` | BLS Employment Projections, Table 1.4 | bls.gov/emp/tables/occupations-most-job-growth.htm | 2026-07-24 | 31 rows (pre-ranked list, includes "Total, all occupations" header row); SOC-keyed |
| `cip_soc_crosswalk.xlsx` | NCES official CIP2020↔SOC2018 crosswalk (direct download, unparsed) | nces.ed.gov/ipeds/cipcode/Files/CIP2020_SOC2018_Crosswalk.xlsx | 2026-07-24 | 429 KB xlsx; not yet inspected for join cardinality (expect many-to-many CIP↔SOC — decide join rule at cleaning) |
| `ipeds_completions_masters.csv` | IPEDS completions via datausa.io API (`ipeds_completions` cube, `scripts/parse_ipeds_completions.py`; raw pull in `data/raw/ipeds_completions_masters_raw.json`) | api.datausa.io/tesseract/data.jsonrecords?cube=ipeds_completions&drilldowns=CIP6,Year&measures=Completions&Degree=7 | 2026-07-24 | 14,493 rows; 1,290 distinct CIP6 codes × years 2012–2024; CIP6-keyed, Masters degree level only; IPEDS suppresses low-count cells for privacy — expect missing years for thin CIP6 programs |

## TAM assumption

Total addressable audience ≈ (students completing similar programs nationally per year)
× (realistic capture %). State the capture % used and the reason for it.
