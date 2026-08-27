#!/usr/bin/env python3
"""Clean data/raw/bls_most_new_jobs.csv (BLS Table 1.4) into
data/clean/bls_most_new_jobs_clean.csv.

Generated with AI assistance; starter prompt in docs/ai-prompts-log.md (2.2a).

Identical shape and treatment to bls_fastest_growing.csv (same 7 columns, same
"Total, all occupations" baseline row) — see docs/decisions-log.md.
"""
from pathlib import Path

import pandas as pd

RAW_PATH = Path("data/raw/bls_most_new_jobs.csv")
CLEAN_PATH = Path("data/clean/bls_most_new_jobs_clean.csv")

COLUMN_RENAME = {
    "2024 National Employment Matrix title": "occupation_title",
    "2024 National Employment Matrix code": "soc_code",
    "Employment, 2024": "employment_2024",
    "Employment, 2034": "employment_2034",
    "Employment change, numeric, 2024–34": "employment_change_numeric_2024_34",
    "Employment change, percent, 2024–34": "employment_change_percent_2024_34",
    "Median annual wage, dollars, 2024": "median_annual_wage_2024",
}

COMMA_NUMERIC_COLUMNS = [
    "employment_2024",
    "employment_2034",
    "employment_change_numeric_2024_34",
    "median_annual_wage_2024",
]


def main():
    df = pd.read_csv(RAW_PATH)
    before = len(df)

    df = df[df["2024 National Employment Matrix code"] != "00-0000"].copy()
    print(f"Step 1 — dropped 'Total, all occupations': {before} -> {len(df)} rows")
    assert len(df) == 30, f"expected 30 rows after dropping the total row, got {len(df)}"

    df = df.rename(columns=COLUMN_RENAME)
    print(f"Step 2 — renamed {len(COLUMN_RENAME)} columns to snake_case")

    before_na = df[COMMA_NUMERIC_COLUMNS].isna().sum().sum()
    for col in COMMA_NUMERIC_COLUMNS:
        df[col] = df[col].astype(str).str.replace(",", "", regex=False).astype(float)
    after_na = df[COMMA_NUMERIC_COLUMNS].isna().sum().sum()
    print(
        f"Step 3 — stripped commas + cast to float on {len(COMMA_NUMERIC_COLUMNS)} "
        f"columns (NaNs before: {before_na}, after: {after_na})"
    )
    assert after_na == before_na, "comma-strip introduced new NaNs — investigate"

    print(f"Step 4 — final shape: {df.shape}")
    print(df.head(3).to_string())

    CLEAN_PATH.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(CLEAN_PATH, index=False)
    print(f"\nWrote {len(df)} rows -> {CLEAN_PATH}")


if __name__ == "__main__":
    main()
