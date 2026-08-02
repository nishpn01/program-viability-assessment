# Entity-Relationship Diagram

*Updated 2026-08-01. All 6 tables are now cleaned (`data/clean/`) and `vanderbilt_current_programs`
has its `cip2020_code` key assigned — this diagram reflects the post-cleaning keys and
grain, ahead of the join/derive step (Phase 2.2, still pending). For the original
raw-only diagram (before any cleaning), see `erd-raw-snapshot.md` — kept separately, not
overwritten.*

*Note on field types below: `string`/`int`/`float` are Mermaid's conceptual field labels
for diagram readability, not literal pandas dtypes. Actual profiled dtypes (e.g. pandas
reports every text column as `object`, not `string`) are in `data-dictionary.md`.*

## What a junction/bridge table is

A junction (or bridge) table exists to connect two tables whose real-world relationship
is many-to-many — where a plain foreign key can't express it, because each row on one
side can match many rows on the other side, and vice versa. Instead of a direct link, both
tables point *into* the junction table, which stores one row per valid pairing.

`cip_soc_crosswalk` plays exactly this role here: a CIP6 academic program (e.g.
"Cybersecurity") typically maps to several SOC occupations (avg 2.8 SOC codes per CIP,
max 180), and a SOC occupation is typically fed by several CIP programs (avg 7 CIP codes
per SOC, max 337). Without the crosswalk, there'd be no principled way to connect IPEDS
completions data (CIP-keyed) to BLS labor-demand data (SOC-keyed).

## Diagram

```mermaid
erDiagram
    ipeds_completions_masters {
        int CIP6_ID PK "bare integer, e.g. 10101 — needs decimal-insert normalization to join; join on the normalized string, not the raw float, since floats built via different paths (string-parsed vs. read natively from Excel) aren't guaranteed bit-identical even when mathematically equal"
        string CIP6 "CIP6 title"
        int Year PK
        float Completions "suppressed for thin CIP6/year cells — 319 of 1290 CIP6 codes have gaps"
    }

    cip_soc_crosswalk {
        string CIP2020Code FK "e.g. 01.0101 — decimal after first 2 digits"
        string CIP2020Title
        string SOC2018Code FK
        string SOC2018Title
    }

    bls_occupational_openings {
        string SOC_code PK "2024 National Employment Matrix code"
        string Occupation_title
        string Occupation_type "Line item (832) vs Summary (281) — filter to Line item before aggregating"
        float Employment_2024
        float Employment_2034
        float Occupational_openings_2024_34 "annual average"
    }

    bls_fastest_growing {
        string SOC_code PK
        string Occupation_title
        float Employment_change_percent "Table 1.3 — pre-ranked top 30 + Total row, 31 rows total"
    }

    bls_most_new_jobs {
        string SOC_code PK
        string Occupation_title
        float Employment_change_numeric "Table 1.4 — pre-ranked top 30 + Total row, 31 rows total"
    }

    vanderbilt_current_programs {
        string program_name "15 rows (Master's + Doctorate only — 12 certificates dropped, not standalone programs)"
        string school
        string level
        string format
        float total_price_estimated "parsed from price_raw; 4/15 missing (unparseable or NR)"
        float cip2020_code FK "13/15 from Vanderbilt's official Registrar CIP list, 2/15 from the algorithmic shortlist"
        string cip2020_code_source "official vs. algorithmic — see decisions-log.md"
    }

    bls_labor_demand {
        string program "candidate label, e.g. cybersecurity — legacy 12-row hand-picked interim table"
        string occupation_title "one manually-matched BLS occupation per candidate, not SOC-keyed"
        string median_pay
    }

    ipeds_completions_masters ||--o{ cip_soc_crosswalk : "CIP6 (normalize format first)"
    vanderbilt_current_programs ||--o{ cip_soc_crosswalk : "cip2020_code — subtracted out of the candidate universe, not a demand signal"
    cip_soc_crosswalk }o--|| bls_occupational_openings : "SOC2018Code"
    cip_soc_crosswalk }o--|| bls_fastest_growing : "SOC2018Code (ranked subset)"
    cip_soc_crosswalk }o--|| bls_most_new_jobs : "SOC2018Code (ranked subset)"
```

## Notes

- **`vanderbilt_current_programs`** now has its `cip2020_code` key (locked and assigned
  2026-08-01 — see [`decisions-log.md`](decisions-log.md)) and joins into
  `cip_soc_crosswalk` the same way `ipeds_completions_masters` does. Its role in the
  pipeline is to be *subtracted out* of the CIP universe (Vanderbilt already offers
  these — candidates are what's left). 13 of 15 codes came from Vanderbilt's own
  official Registrar CIP list (`planning/CIP_Codes.pdf`); the other 2 came from an
  algorithmic word-overlap shortlist (`scripts/suggest_vanderbilt_cip_codes.py`) since
  the official list doesn't cover them.
- **`bls_labor_demand`** is the original 12-candidate hand-picked table from before the
  pivot to a fully data-derived candidate set (2026-07-24 decisions-log entry). It's kept
  as-is for now as a first-pass sample to reconcile against the crosswalk-derived
  approach, not wired into the CIP↔SOC chain — its `program`/`occupation_title` values
  are free-text labels, not SOC/CIP codes.
- **`bls_fastest_growing`** and **`bls_most_new_jobs`** share the same SOC key space as
  `bls_occupational_openings` (all three come from the same BLS Employment Projections
  release) but are separate pre-ranked top-30 tables (Tables 1.3 and 1.4), not derived
  from `bls_occupational_openings` (Table 1.10) — hence three separate edges into
  `cip_soc_crosswalk` rather than one shared entity.
- **Cut, not just deferred**: `competitors_pricing.csv` and `student_demand.csv` were
  dropped entirely for this project's deadline (2026-08-01 decision in
  [`decisions-log.md`](decisions-log.md)), not merely postponed — no raw file exists for
  either, and none is planned before the screening call. Omitted from the diagram.
- **22 of 1,290 IPEDS CIP6 codes** have no match anywhere in the crosswalk (confirmed
  ultra-niche programs — Taxidermy, Talmudic Studies, etc.) — dropped with a documented
  note rather than forced.
- **12 of 832 BLS SOC codes** (the "Line item" detail occupations) also have no
  crosswalk match — 7 are "broad group" codes the crosswalk instead maps at a more
  detailed sub-code level (e.g. `31-1120` → `31-1121`/`31-1122`), the other 5 are
  genuine small gaps. Same treatment: dropped with a documented note.
