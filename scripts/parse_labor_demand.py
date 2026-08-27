#!/usr/bin/env python3
"""Parse BLS OOH Quick Facts tables (scraped by scripts/scrape_labor_demand.sh) into
labor_demand.csv.

Generated with AI assistance, as part of the Phase 1 data-collection pull
(docs/ai-prompts-log.md, 1.3).
"""
import csv
import re
from pathlib import Path

RAW_DIR = Path("data/raw/labor_raw")
OUT_CSV = Path("data/raw/bls_labor_demand.csv")

CANDIDATES = [
    "cybersecurity", "business_analytics", "data_science", "public_health",
    "healthcare_admin", "social_work", "finance", "accounting", "marketing",
    "supply_chain", "project_management", "public_administration",
]

FIELD_PATTERNS = {
    "occupation_title": re.compile(r"\|\s*Quick Facts:\s*(.+?)\s*\|"),
    "median_pay": re.compile(r"\|\s*\[2024 Median Pay\].*?\|\s*(\$[\d,]+) per year"),
    "entry_level_education": re.compile(r"\|\s*\[Typical Entry-Level Education\].*?\|\s*(.+?)\s*\|"),
    "number_of_jobs_2024": re.compile(r"\|\s*\[Number of Jobs, 2024\].*?\|\s*([\d,]+)\s*\|"),
    "job_outlook_growth_pct": re.compile(r"\|\s*\[Job Outlook, [\d–\-]+\].*?\|\s*(-?\d+)% "),
    "employment_change_2024_34": re.compile(r"\|\s*\[Employment Change, [\d–\-]+\].*?\|\s*([\-\d,]+)\s*\|"),
}

rows = []
for label in CANDIDATES:
    path = RAW_DIR / f"{label}.md"
    if not path.exists():
        print(f"MISSING: {label}")
        continue
    text = path.read_text(errors="ignore")
    row = {"program": label}
    for field, pattern in FIELD_PATTERNS.items():
        m = pattern.search(text)
        row[field] = m.group(1).strip() if m else ""
    if "See How to Become One" in row.get("entry_level_education", ""):
        row["entry_level_education"] = "Varies by specialization (no single BLS answer)"
    rows.append(row)

fieldnames = ["program", "occupation_title", "median_pay", "entry_level_education",
              "number_of_jobs_2024", "job_outlook_growth_pct", "employment_change_2024_34"]

OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
with OUT_CSV.open("w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)

print(f"Wrote {len(rows)} rows -> {OUT_CSV}")
for row in rows:
    missing = [k for k in fieldnames if not row[k]]
    if missing:
        print(f"  {row['program']}: missing {missing}")
