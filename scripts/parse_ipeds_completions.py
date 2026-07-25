#!/usr/bin/env python3
"""Convert the raw datausa.io ipeds_completions JSON pull (CIP6 x Year, Degree=Masters)
into a tidy CSV."""
import csv
import json
from pathlib import Path

RAW_JSON = Path("data/raw/ipeds_completions_masters_raw.json")
OUT_CSV = Path("data/raw/ipeds_completions_masters.csv")


def main():
    payload = json.loads(RAW_JSON.read_text())
    rows = payload["data"]
    fieldnames = ["CIP6 ID", "CIP6", "Year", "Completions"]

    with OUT_CSV.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"Wrote {len(rows)} rows -> {OUT_CSV}")
    print(f"Distinct CIP6 codes: {len({r['CIP6 ID'] for r in rows})}")
    years = sorted({r['Year'] for r in rows})
    print(f"Year range: {years[0]}–{years[-1]}")


if __name__ == "__main__":
    main()
