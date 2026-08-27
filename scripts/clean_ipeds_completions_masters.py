#!/usr/bin/env python3
"""Clean data/raw/ipeds_completions_masters.csv into
data/clean/ipeds_completions_masters_clean.csv.

Generated with AI assistance; starter prompt in docs/ai-prompts-log.md (2.2a).

Depends on data/clean/cip_soc_crosswalk_clean.csv already existing (run
clean_cip_soc_crosswalk.py first) — used to determine which CIP6 codes actually
have a crosswalk match, rather than hardcoding a fixed list of codes to drop.

Steps:
1. Rename columns to snake_case.
2. Derive cip2020_code from cip6_id: zero-pad to 6 digits, insert a decimal after
   the first 2 (e.g. 10101 -> 01.0101 -> 1.0101), matching the crosswalk's format.
3. Drop rows whose cip2020_code has no match anywhere in the cleaned crosswalk
   (confirmed during EDA to be ~22 ultra-niche CIP6 codes with no crosswalk entry
   at all — see docs/decisions-log.md).
4. Leave missing years as missing (IPEDS suppression) — do not fill with 0.
5. Sanity-check distinct CIP6 count before/after the drop.
"""
from pathlib import Path

import pandas as pd

RAW_PATH = Path("data/raw/ipeds_completions_masters.csv")
CROSSWALK_CLEAN_PATH = Path("data/clean/cip_soc_crosswalk_clean.csv")
CLEAN_PATH = Path("data/clean/ipeds_completions_masters_clean.csv")

COLUMN_RENAME = {
    "CIP6 ID": "cip6_id",
    "CIP6": "cip6_title",
    "Year": "year",
    "Completions": "completions",
}


def to_cip2020_code(cip6_id: int) -> float:
    # Matches the crosswalk's CIP2020Code format: zero-pad to 6 digits, decimal
    # after the first 2 (10101 -> 1.0101). Same code, different representation.
    s = str(cip6_id).zfill(6)
    return float(f"{s[:2]}.{s[2:]}")


def main():
    df = pd.read_csv(RAW_PATH)
    df = df.rename(columns=COLUMN_RENAME)
    print(f"Step 1 — loaded + renamed {len(COLUMN_RENAME)} columns: {df.shape}")

    df["cip2020_code"] = df["cip6_id"].apply(to_cip2020_code)
    print("Step 2 — derived cip2020_code join key from cip6_id")

    crosswalk = pd.read_csv(CROSSWALK_CLEAN_PATH)
    valid_codes = set(crosswalk["cip2020_code"].unique())

    before_codes = df["cip6_id"].nunique()
    before_rows = len(df)
    # Codes with no crosswalk match can't join to anything downstream anyway.
    df = df[df["cip2020_code"].isin(valid_codes)].copy()
    after_codes = df["cip6_id"].nunique()
    dropped = before_codes - after_codes
    print(
        f"Step 3 — dropped CIP6 codes with no crosswalk match: "
        f"{before_codes} -> {after_codes} distinct codes ({dropped} dropped, "
        f"{before_rows} -> {len(df)} rows)"
    )

    # IPEDS suppresses low counts rather than reporting 0 — filling these with
    # 0 would misrepresent suppressed data as a real zero.
    n_missing = df["completions"].isna().sum()
    print(f"Step 4 — missing-year rows left as-is (not filled): {n_missing}")

    print(f"Step 5 — final shape: {df.shape}, {df['cip6_id'].nunique()} distinct CIP6 codes")

    CLEAN_PATH.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(CLEAN_PATH, index=False)
    print(f"\nWrote {len(df)} rows -> {CLEAN_PATH}")


if __name__ == "__main__":
    main()
