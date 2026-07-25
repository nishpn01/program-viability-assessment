#!/usr/bin/env python3
"""Parse BLS Employment Projections tables 1.10, 1.3, 1.4 (scraped by Firecrawl as
markdown in data/raw/bls_projections_raw/) into tidy CSVs in data/raw/.

Each BLS page renders as one big markdown pipe-table plus site nav/footer noise.
Data rows are identified by a SOC code (NN-NNNN) in the second column — nav/footer
lines never match that pattern, so no manual line-number boundaries are needed.
"""
import csv
import re
from pathlib import Path

RAW_DIR = Path("data/raw/bls_projections_raw")
OUT_DIR = Path("data/raw")

SOC_RE = re.compile(r"^\d{2}-\d{4}$")


def parse_table(md_path: Path, expected_cols: int):
    rows = []
    header = None
    for line in md_path.read_text(errors="ignore").splitlines():
        if not line.startswith("|"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) != expected_cols:
            continue
        if header is None and "Matrix code" in line:
            header = cells
            continue
        if len(cells) > 1 and SOC_RE.match(cells[1]):
            rows.append(cells)
    return header, rows


FOOTNOTE_RE = re.compile(r"\s*\[\\?\[\d+\\?\]\]\([^)]*\)")


def write_csv(out_path: Path, header, rows):
    header = [FOOTNOTE_RE.sub("", h).strip() for h in header]
    with out_path.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(rows)
    print(f"Wrote {len(rows)} rows -> {out_path}")


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    # Table 1.10 — occupational openings (14 columns, includes Occupation type)
    header, rows = parse_table(RAW_DIR / "table_1_10_openings.md", expected_cols=14)
    line_items = [r for r in rows if r[2] == "Line item"]
    write_csv(OUT_DIR / "bls_occupational_openings.csv", header, rows)
    print(f"  of which {len(line_items)} are 'Line item' (non-summary) rows")

    # Table 1.3 — fastest growing (7 columns, no Occupation type column)
    header, rows = parse_table(RAW_DIR / "table_1_3_fastest_growing.md", expected_cols=7)
    write_csv(OUT_DIR / "bls_fastest_growing.csv", header, rows)

    # Table 1.4 — most new jobs (7 columns, same shape as 1.3)
    header, rows = parse_table(RAW_DIR / "table_1_4_most_new_jobs.md", expected_cols=7)
    write_csv(OUT_DIR / "bls_most_new_jobs.csv", header, rows)


if __name__ == "__main__":
    main()
