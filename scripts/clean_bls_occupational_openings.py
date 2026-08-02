#!/usr/bin/env python3
"""Clean data/raw/bls_occupational_openings.csv (BLS Table 1.10) into
data/clean/bls_occupational_openings_clean.csv.

Steps (see docs/decisions-log.md for the reasoning behind each):
1. Filter to Occupation type == "Line item" — drops the 281 category-rollup rows
   that would double-count the detail occupations under them.
2. Rename every column to snake_case, and strip the literal "<br>" that 5 column
   names inherited from the scraped HTML header — SQL doesn't like spaces/commas
   in column names, so this is fixed once here instead of again in Phase 3.
3. Strip commas from the numeric-but-text columns and cast to float. SOC code and
   title stay as text (SOC codes have a leading zero / dash that must be preserved).
4. Verification check: row count is exactly 832, and the comma-strip step didn't
   silently turn any real value into a missing one.
"""
import re
from pathlib import Path

import pandas as pd

RAW_PATH = Path("data/raw/bls_occupational_openings.csv")
CLEAN_PATH = Path("data/clean/bls_occupational_openings_clean.csv")

# Original column name -> clean snake_case name
COLUMN_RENAME = {
    "2024 National Employment Matrix title": "occupation_title",
    "2024 National Employment Matrix code": "soc_code",
    "Occupation type": "occupation_type",
    "Employment, 2024": "employment_2024",
    "Employment, 2034": "employment_2034",
    "Employment change, numeric,<br> 2024–34": "employment_change_numeric_2024_34",
    "Employment change, percent,<br> 2024–34": "employment_change_percent_2024_34",
    "Labor force exit rate,<br> 2024–34 annual average": "labor_force_exit_rate_2024_34",
    "Occupational transfer rate,<br> 2024–34 annual average": "occupational_transfer_rate_2024_34",
    "Total occupational separations rate,<br> 2024–34 annual average": "total_separations_rate_2024_34",
    "Labor force exits,<br> 2024–34 annual average": "labor_force_exits_2024_34",
    "Occupational transfers,<br> 2024–34 annual average": "occupational_transfers_2024_34",
    "Total occupational separations,<br> 2024–34 annual average": "total_separations_2024_34",
    "Occupational openings,<br> 2024–34 annual average": "occupational_openings_2024_34",
}

# Columns that are numbers stored as comma-formatted text (e.g. "169,956.1")
COMMA_NUMERIC_COLUMNS = [
    "employment_2024",
    "employment_2034",
    "employment_change_numeric_2024_34",
    "labor_force_exits_2024_34",
    "occupational_transfers_2024_34",
    "total_separations_2024_34",
    "occupational_openings_2024_34",
]

# Already-numeric percent/rate columns — no comma-stripping needed, just renamed
ALREADY_NUMERIC_COLUMNS = [
    "employment_change_percent_2024_34",
    "labor_force_exit_rate_2024_34",
    "occupational_transfer_rate_2024_34",
    "total_separations_rate_2024_34",
]


def main():
    df = pd.read_csv(RAW_PATH)
    raw_rows = len(df)

    # Step 1: filter to detail occupations only
    df = df[df["Occupation type"] == "Line item"].copy()
    print(f"Step 1 — filtered to 'Line item': {raw_rows} -> {len(df)} rows")
    assert len(df) == 832, f"expected 832 Line item rows, got {len(df)}"

    # Step 2: rename columns
    df = df.rename(columns=COLUMN_RENAME)
    print(f"Step 2 — renamed {len(COLUMN_RENAME)} columns to snake_case")

    # Step 3: strip commas + cast to float on the comma-formatted numeric columns
    before_na = df[COMMA_NUMERIC_COLUMNS].isna().sum().sum()
    for col in COMMA_NUMERIC_COLUMNS:
        df[col] = (
            df[col].astype(str).str.replace(",", "", regex=False).astype(float)
        )
    after_na = df[COMMA_NUMERIC_COLUMNS].isna().sum().sum()
    print(
        f"Step 3 — stripped commas + cast to float on {len(COMMA_NUMERIC_COLUMNS)} "
        f"columns (NaNs before: {before_na}, after: {after_na})"
    )
    assert after_na == before_na, "comma-strip introduced new NaNs — investigate"

    # occupation_type / occupation_title / soc_code stay as text (object) as-is

    # Step 4: verification check + save
    print(f"Step 4 — final shape: {df.shape}")
    print(df.head(3).to_string())

    CLEAN_PATH.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(CLEAN_PATH, index=False)
    print(f"\nWrote {len(df)} rows -> {CLEAN_PATH}")


if __name__ == "__main__":
    main()
