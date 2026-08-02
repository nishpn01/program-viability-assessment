# Data Dictionary

Profiled directly from the files in `data/raw/` and `data/clean/` (pandas `shape`,
`dtype`, `nunique`, `isna().sum()` — re-derived each time this doc is regenerated,
not carried over from memory). See [data-sources.md](data-sources.md) for where each
file came from and [source-inventory.md](source-inventory.md) for the sourcing
rationale.

**Pipeline stage:** all 6 raw tables have been cleaned (see the **Clean** section
below); `data/clean/` holds the output. A **mart** section will be added once the
join/derive step produces `derived_candidates`.

---

## Raw

### Structured raw scrapes (parsed into CSV/JSON below)

`data/raw/labor_raw/*.md` (12 files: `accounting`, `business_analytics`,
`cybersecurity`, `data_science`, `finance`, `healthcare_admin`, `marketing`,
`project_management`, `public_administration`, `public_health`, `social_work`,
`supply_chain`) and `data/raw/bls_projections_raw/*.md` (3 files: `table_1_10_openings`,
`table_1_3_fastest_growing`, `table_1_4_most_new_jobs`) are full Firecrawl page-scrape
dumps of BLS.gov pages (site nav/boilerplate + the actual content table), one file per
occupation page or per BLS table. They are not tabular data themselves — each is the
unparsed source a downstream script (`scripts/scrape_labor_demand.sh`,
`scripts/parse_bls_projections.py`) reads to produce the corresponding CSV below —
so they're not pandas-profiled here. Grain: one file = one scraped web page.

---

### `bls_labor_demand.csv`
**Grain:** one row = one candidate program's closest-match BLS occupation (12 rows, one per program in `labor_raw/`).

| Column | dtype | Meaning | Nulls |
|---|---|---|---|
| `program` | object | Candidate program slug (matches a `labor_raw/*.md` filename) | 0/12 |
| `occupation_title` | object | Closest-match BLS occupation name (proxy, not exact) | 0/12 |
| `median_pay` | object | 2024 median annual wage, formatted as `"$124,910"` (string, not numeric — strip `$`/`,` before math) | 0/12 |
| `entry_level_education` | object | Typical entry education per BLS OOH; 3 distinct values incl. `"Varies by specialization (no single BLS answer)"` for occupations without one clean answer | 0/12 |
| `number_of_jobs_2024` | object | 2024 employment count, comma-formatted string (e.g. `"182,800"`) | 0/12 |
| `job_outlook_growth_pct` | int64 | BLS 2024–34 projected growth %, already numeric | 0/12 |
| `employment_change_2024_34` | object | Projected net employment change 2024–34, comma-formatted string | 0/12 |

---

### `bls_fastest_growing.csv`  (BLS Employment Projections Table 1.3)
**Grain:** one row = one occupation in BLS's pre-ranked fastest-growing list (31 rows: 30 ranked occupations + 1 `"Total, all occupations"` header/baseline row — filter it out for ranking math).

| Column | dtype | Meaning | Nulls |
|---|---|---|---|
| `2024 National Employment Matrix title` | object | Occupation name (SOC title) | 0/31 |
| `2024 National Employment Matrix code` | object | SOC code, e.g. `"49-9081"` | 0/31 |
| `Employment, 2024` | object | 2024 employment, thousands, comma-formatted string | 0/31 |
| `Employment, 2034` | object | Projected 2034 employment, thousands, comma-formatted string | 0/31 |
| `Employment change, numeric, 2024–34` | object | Net change, thousands, comma-formatted string | 0/31 |
| `Employment change, percent, 2024–34` | float64 | Net change %, already numeric | 0/31 |
| `Median annual wage, dollars, 2024` | object | Median wage, comma-formatted string | 0/31 |

---

### `bls_most_new_jobs.csv`  (BLS Employment Projections Table 1.4)
**Grain:** one row = one occupation in BLS's pre-ranked "most new jobs" list (31 rows: 30 ranked + 1 `"Total, all occupations"` header row, same convention as Table 1.3).

Same 7 columns, dtypes, and per-column meaning as `bls_fastest_growing.csv` above (same source table structure, ranked by numeric job growth instead of percent growth). No nulls in any column (0/31).

---

### `bls_occupational_openings.csv`  (BLS Employment Projections Table 1.10)
**Grain:** one row = one SOC occupation (or occupation-group rollup) with its 2024–34 separations/openings projections. 1,113 rows — 832 `"Line item"` (detail occupation) rows plus category-summary (`"Summary"`) rollup rows; filter `Occupation type == "Line item"` before treating rows as independent detail occupations, per the source-note in `data-sources.md`.

| Column | dtype | Meaning | Nulls |
|---|---|---|---|
| `2024 National Employment Matrix title` | object | Occupation or category title (1,110 unique of 1,113 — a few titles repeat across summary levels) | 0/1113 |
| `2024 National Employment Matrix code` | object | SOC code, unique per row | 0/1113 |
| `Occupation type` | object | `"Line item"` (detail occupation, 832 rows) or `"Summary"` (category rollup) | 0/1113 |
| `Employment, 2024` | object | 2024 employment, thousands, comma-formatted string | 0/1113 |
| `Employment, 2034` | object | Projected 2034 employment, thousands, comma-formatted string | 0/1113 |
| `Employment change, numeric,<br> 2024–34` | object | Net change, thousands, comma-formatted string (column name carries a literal `<br>` from the scraped HTML header) | 0/1113 |
| `Employment change, percent,<br> 2024–34` | float64 | Net change %, already numeric | 0/1113 |
| `Labor force exit rate,<br> 2024–34 annual average` | float64 | Annual % of workers permanently leaving the labor force | 0/1113 |
| `Occupational transfer rate,<br> 2024–34 annual average` | float64 | Annual % of workers transferring to a different occupation | 0/1113 |
| `Total occupational separations rate,<br> 2024–34 annual average` | float64 | Exit rate + transfer rate combined | 0/1113 |
| `Labor force exits,<br> 2024–34 annual average` | object | Annual-average count (thousands) of labor-force exits, comma-formatted string | 0/1113 |
| `Occupational transfers,<br> 2024–34 annual average` | object | Annual-average count (thousands) of occupational transfers, comma-formatted string | 0/1113 |
| `Total occupational separations,<br> 2024–34 annual average` | object | Annual-average total separations, comma-formatted string | 0/1113 |
| `Occupational openings,<br> 2024–34 annual average` | object | **The key labor-demand metric**: annual-average total openings (growth + separations), comma-formatted string | 0/1113 |

Note: the literal `<br>` in five header names comes straight from the scraped HTML and will need cleanup (e.g. regex-stripping `<br>` and collapsing whitespace) during Phase 2 cleaning.

---

### `vanderbilt_current_programs.csv`
**Grain:** one row = one Vanderbilt Online Learning program (degree or certificate), 27 rows.

| Column | dtype | Meaning | Nulls |
|---|---|---|---|
| `program_name` | object | Full program title, unique per row | 0/27 |
| `school` | object | Owning school (11 distinct); one row has a dual-affiliation value `"School of Nursing \| Graduate School"` — pipe-delimited, not a true null but worth normalizing before grouping by school | 0/27 |
| `level` | object | Credential level: `Certificate` (12), `Master's` (11), `Doctorate` (4) | 0/27 |
| `format` | object | Delivery format — constant `"Online"` for all 27 rows (this file only covers the online catalog) | 0/27 |
| `credits_or_duration` | object | Mixed-unit program length, e.g. `"36 Credits"`, `"5 Semesters"`, `"4 Years"`, or `"Varies"` (11 distinct formats — not a single numeric unit) | 0/27 |
| `price_raw` | object | Unparsed price string, inconsistent units across rows: `"69,662/total"`, `"2,057/credit"`, `"Fully Funded"`, `"NR"` (not reported), and a few bare numbers with no stated unit (e.g. `"300"`, `"2,500"`, `"3,795"`) — needs a parsing rule (and a judgment call on the unit-less values) before use as numeric tuition | 0/27 |
| `program_url` | object | Program catalog page URL, unique per row | 0/27 |

---

### `ipeds_completions_masters.csv`
**Grain:** one row = one CIP6 program code × year (Masters degree level only), 14,493 rows across 1,290 distinct CIP6 codes and years 2012–2024 (13 possible years).

| Column | dtype | Meaning | Nulls |
|---|---|---|---|
| `CIP6 ID` | int64 | Numeric CIP6 code (e.g. `10000`, `10101`) | 0/14493 |
| `CIP6` | object | CIP6 program name (1,286 unique names for 1,290 IDs — a few names repeat across distinct codes) | 0/14493 |
| `Year` | int64 | Completion year, 2012–2024 | 0/14493 |
| `Completions` | float64 | National count of Masters completions for that CIP6/year | 0/14493 |

**Missing-data note:** no `NaN`s in any column, but coverage is **row-suppressed, not null-filled** — 319 of 1,290 CIP6 codes (25%) have fewer than the full 13 years of rows (min 1, mean ~11.2), consistent with the IPEDS privacy-suppression flagged in `data-sources.md`. Absence of a CIP6/Year row means suppressed or zero, not necessarily zero completions — don't assume 0 when reindexing to a full year range.

---

### `ipeds_completions_masters_raw.json`
**Grain:** the unparsed API response `ipeds_completions_masters.csv` was derived from — one JSON object with a `data` array of 14,493 records (same grain as the CSV: one record = one CIP6 × Year).

| Key | Type | Meaning |
|---|---|---|
| `annotations` | dict | API/source metadata (dataset link, source description) — not tabular |
| `page` | dict | Pagination info: `{"limit": 0, "offset": 0, "total": 14493}` | 
| `columns` | list[str] | The 4 field names, matching the CSV's columns (`CIP6 ID`, `CIP6`, `Year`, `Completions`) |
| `data` | list[dict] | The actual 14,493 records, e.g. `{"CIP6 ID": 10000, "CIP6": "General Agriculture", "Year": 2012, "Completions": 316.0}` — this is what `scripts/parse_ipeds_completions.py` flattens into the CSV above |

---

### `cip_soc_crosswalk.xlsx`
NCES's official CIP2020↔SOC2018 crosswalk, distributed as one workbook with 8 sheets serving different lookup directions. Not yet used in any pipeline script — profiled here for the first time since it was pulled unparsed per `data-sources.md`.

**`File Guide`** — 7 rows × 2 cols (`File Name`, `Description`): a human-readable index of the other 7 sheets. Not data itself.

**`CIP-SOC`** — grain: one row = one CIP2020×SOC2018 match, ordered by CIP code. 6,097 rows, 2,143 distinct CIP codes → 868 distinct SOC codes (many-to-many, as flagged in `source-inventory.md`).

**`SOC-CIP`** — same underlying matches as `CIP-SOC`, reordered/keyed by SOC code first. 6,093 rows (4 fewer than `CIP-SOC` — worth reconciling which 4 CIP-SOC pairs drop out before treating the two sheets as interchangeable).

**`New CIP`** — subset of `CIP-SOC` restricted to CIP codes new in the 2020 revision. 1,076 rows, 429 distinct new CIP codes.

**`New SOC`** — subset of `SOC-CIP` restricted to SOC codes new in the 2018 revision. 415 rows, 75 distinct new SOC codes.

**`Added Matches`** — supplementary matches added after the initial crosswalk build. 1,007 rows, 628 distinct CIP codes.

**`Unmatched CIP Codes`** — 194 CIP codes with no SOC match; `SOC2018Code`/`SOC2018Title` are sentinel values (`"99-9999"` / `"NO MATCH"`), not real nulls.

**`Unmatched SOC Codes`** — 180 SOC codes with no CIP match; `CIP2020Code`/`CIP2020Title` are sentinel values (`99.9999` / `"NO MATCH"`), same convention as above.

Common columns across the CIP-keyed sheets: `CIP2020Code` (float64 — e.g. `1.0101`; note the decimal encoding of what's conceptually a 6-digit code, so `1.0` ≠ `1.0000`, watch for float-precision join bugs), `CIP2020Title` (object, titles end in a trailing period, e.g. `"Agriculture, General."`). Common columns across the SOC-keyed sheets: `SOC2018Code` (object, e.g. `"19-1011"`), `SOC2018Title` (object). Zero true nulls in any sheet — "no match" is always represented by the sentinel code/title pair above, never a blank cell.

---

## Clean

All 6 raw tables cleaned as of 2026-08-01. Cleaning scripts (one per table, in
`scripts/clean_*.py`) are the source of truth for exactly what each step did — this
section documents the resulting shape, not the transformation logic itself. See
`decisions-log.md` (2026-08-01 entry) for the summary of what changed per table.

### `bls_fastest_growing_clean.csv`
**Grain:** one row = one occupation (30 rows — the "Total, all occupations" baseline row from the raw file was dropped).

| Column | dtype | Meaning | Nulls |
|---|---|---|---|
| `occupation_title` | object | Occupation name (renamed from raw's `2024 National Employment Matrix title`) | 0/30 |
| `soc_code` | object | SOC code (renamed from raw's `2024 National Employment Matrix code`) | 0/30 |
| `employment_2024` | float64 | 2024 employment, thousands (cast from comma-formatted string) | 0/30 |
| `employment_2034` | float64 | Projected 2034 employment, thousands | 0/30 |
| `employment_change_numeric_2024_34` | float64 | Net change, thousands | 0/30 |
| `employment_change_percent_2024_34` | float64 | Net change % | 0/30 |
| `median_annual_wage_2024` | float64 | Median wage, dollars (cast from comma-formatted string) | 0/30 |

### `bls_most_new_jobs_clean.csv`
**Grain:** one row = one occupation (30 rows, same baseline-row drop as above).

Same 7 columns, dtypes, and meanings as `bls_fastest_growing_clean.csv` (identical source-table structure, ranked by numeric growth instead of percent growth). No nulls in any column.

### `bls_occupational_openings_clean.csv`
**Grain:** one row = one detail SOC occupation (832 rows — filtered from the raw file's 1,113 to `Occupation type == "Line item"` only; the 281 category-rollup "Summary" rows were dropped).

| Column | dtype | Meaning | Nulls |
|---|---|---|---|
| `occupation_title` | object | Occupation title | 0/832 |
| `soc_code` | object | SOC code, unique per row | 0/832 |
| `occupation_type` | object | Constant `"Line item"` post-filter (kept for traceability) | 0/832 |
| `employment_2024` | float64 | 2024 employment, thousands | 0/832 |
| `employment_2034` | float64 | Projected 2034 employment, thousands | 0/832 |
| `employment_change_numeric_2024_34` | float64 | Net change, thousands | 0/832 |
| `employment_change_percent_2024_34` | float64 | Net change % | 0/832 |
| `labor_force_exit_rate_2024_34` | float64 | Annual % of workers permanently leaving the labor force | 0/832 |
| `occupational_transfer_rate_2024_34` | float64 | Annual % of workers transferring to a different occupation | 0/832 |
| `total_separations_rate_2024_34` | float64 | Exit rate + transfer rate combined | 0/832 |
| `labor_force_exits_2024_34` | float64 | Annual-average exit count, thousands | 0/832 |
| `occupational_transfers_2024_34` | float64 | Annual-average transfer count, thousands | 0/832 |
| `total_separations_2024_34` | float64 | Annual-average total separations, thousands | 0/832 |
| `occupational_openings_2024_34` | float64 | **The key labor-demand metric** — annual-average total openings (growth + separations) | 0/832 |

All 14 columns renamed to snake_case from raw (also fixes the literal `<br>` artifact in 5 header names); all comma-formatted numeric strings cast to float. 0 new NaNs introduced by cleaning.

### `cip_soc_crosswalk_clean.csv`
**Grain:** one row = one CIP2020×SOC2018 match (6,097 rows — the raw `CIP-SOC` sheet only; the other 7 sheets in the raw `.xlsx` were not used). 2,143 distinct CIP codes, 868 distinct SOC codes — confirmed unchanged from the raw profile.

| Column | dtype | Meaning | Nulls |
|---|---|---|---|
| `cip2020_code` | float64 | CIP2020 code, e.g. `1.0101` | 0/6097 |
| `cip2020_title` | object | CIP program title (trailing period stripped vs. raw) | 0/6097 |
| `soc2018_code` | object | SOC2018 code, e.g. `"19-1011"` | 0/6097 |
| `soc2018_title` | object | SOC occupation title | 0/6097 |

4 columns renamed to snake_case from raw; no row-level changes otherwise.

### `ipeds_completions_masters_clean.csv`
**Grain:** one row = one CIP6 program code × year, Masters level only (14,331 rows — down from the raw file's 14,493; the 22 CIP6 codes with no match anywhere in the cleaned crosswalk were dropped, taking distinct CIP6 codes from 1,290 to 1,268).

| Column | dtype | Meaning | Nulls |
|---|---|---|---|
| `cip6_id` | int64 | Numeric CIP6 code (e.g. `10000`), unchanged from raw | 0/14331 |
| `cip6_title` | object | CIP6 program name | 0/14331 |
| `year` | int64 | Completion year, 2012–2024 | 0/14331 |
| `completions` | float64 | National Masters completions count for that CIP6/year | 0/14331 |
| `cip2020_code` | float64 | Join key derived from `cip6_id` (zero-pad + decimal insert, e.g. `10000` → `1.0` — matches the crosswalk's `cip2020_code` format) | 0/14331 |

Missing years (IPEDS suppression) are left missing, not filled with 0 — see the raw-section note above; that same caveat still applies here since suppression isn't a cleaning step, it's a property of the source.

### `vanderbilt_current_programs_clean.csv`
**Grain:** one row = one Vanderbilt online Master's or Doctorate program (15 rows — filtered from the raw file's 27; all 12 Certificate-level rows were dropped, since certificates require existing Vanderbilt enrollment and aren't standalone programs comparable to the Masters-level IPEDS data driving the rest of this project).

| Column | dtype | Meaning | Nulls |
|---|---|---|---|
| `program_name` | object | Full program title, unchanged from raw | 0/15 |
| `school` | object | Owning school; the one dual-affiliation raw value (`"School of Nursing \| Graduate School"`) was normalized to its first-listed school | 0/15 |
| `level` | object | `Master's` (11) or `Doctorate` (4) | 0/15 |
| `format` | object | Constant `"Online"`, unchanged from raw | 0/15 |
| `credits_or_duration` | object | Unchanged from raw (kept for traceability into `total_price_estimated`) | 0/15 |
| `price_raw` | object | Unchanged from raw (kept for traceability) | 0/15 |
| `program_url` | object | Unchanged from raw | 0/15 |
| `total_price_estimated` | float64 | Parsed single-number price: already-total values used directly, per-credit rates × parsed credit count, `"Fully Funded"` → `0` (real zero cost), `"NR"` → missing. See `scripts/clean_vanderbilt_current_programs.py` for the exact per-row rule. | 4/15 (3 per-credit rows with no parseable credit count — "Semesters"/"Years"/"Varies" duration; 1 "NR" row) |
| `cip2020_code` | float64 | CIP2020 code assigned per program, joins this table into `cip_soc_crosswalk` the same way `ipeds_completions_masters_clean.csv` does | 0/15 |
| `cip2020_code_source` | object | Provenance of the `cip2020_code` value: `"official"` (13 rows — matched against Vanderbilt's own Registrar CIP list, `planning/CIP_Codes.pdf`) or `"algorithmic shortlist"` / `"algorithmic/inferred"` (2 rows — used only where the official list has no entry). Full per-row mapping and reasoning in `decisions-log.md`. | 0/15 |

## Analysis marts

*(not yet started — the join/derive step will produce `derived_candidates` here)*
