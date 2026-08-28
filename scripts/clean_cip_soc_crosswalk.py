#!/usr/bin/env python3
"""Clean data/raw/cip_soc_crosswalk.xlsx (CIP-SOC sheet only) into
data/clean/cip_soc_crosswalk_clean.csv.

Generated with AI assistance; starter prompt in docs/ai-prompts-log.md (2.2a).

The workbook has 8 sheets; only CIP-SOC is used going forward (see
docs/data-dictionary.md for what the other 7 contain and why they're unused).

Steps:
1. Load only the CIP-SOC sheet (6,097 rows).
2. Rename columns to snake_case.
3. Strip the trailing period every cip2020_title value has (scrape/export artifact,
   e.g. "Agriculture, General." -> "Agriculture, General").
4. Sanity-check: row count and distinct CIP/SOC counts unchanged from the raw profile.
"""
from pathlib import Path

import pandas as pd

RAW_PATH = Path("data/raw/cip_soc_crosswalk.xlsx")
CLEAN_PATH = Path("data/clean/cip_soc_crosswalk_clean.csv")

COLUMN_RENAME = {
    "CIP2020Code": "cip2020_code",
    "CIP2020Title": "cip2020_title",
    "SOC2018Code": "soc2018_code",
    "SOC2018Title": "soc2018_title",
}


def main():
    df = pd.read_excel(RAW_PATH, sheet_name="CIP-SOC")
    print(f"Step 1: loaded CIP-SOC sheet: {df.shape}")
    assert len(df) == 6097, f"expected 6,097 rows, got {len(df)}"

    df = df.rename(columns=COLUMN_RENAME)
    print(f"Step 2: renamed {len(COLUMN_RENAME)} columns to snake_case")

    df["cip2020_title"] = df["cip2020_title"].str.rstrip(".")
    print("Step 3: stripped trailing period from cip2020_title values")

    n_cip = df["cip2020_code"].nunique()
    n_soc = df["soc2018_code"].nunique()
    print(f"Step 4: sanity check: {len(df)} rows, {n_cip} distinct CIP codes, {n_soc} distinct SOC codes")
    assert (n_cip, n_soc) == (2143, 868), f"expected (2143, 868), got ({n_cip}, {n_soc})"

    CLEAN_PATH.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(CLEAN_PATH, index=False)
    print(f"\nWrote {len(df)} rows -> {CLEAN_PATH}")


if __name__ == "__main__":
    main()
