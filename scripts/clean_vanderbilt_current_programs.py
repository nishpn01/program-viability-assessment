#!/usr/bin/env python3
"""Clean data/raw/vanderbilt_current_programs.csv into
data/clean/vanderbilt_current_programs_clean.csv.

Generated with AI assistance; starter prompt in docs/ai-prompts-log.md (2.2a).

Steps (see docs/decisions-log.md for the reasoning behind each):
1. Filter to level in {Master's, Doctorate} — certificates are add-on credentials
   that require existing Vanderbilt enrollment, not standalone programs comparable
   to the Masters-level IPEDS completions data driving the rest of this project.
   27 -> 15 rows.
2. Fix the one dual-affiliation `school` value ("School of Nursing | Graduate
   School") by keeping the first-listed school.
3. Parse `price_raw` into a single `total_price_estimated` column:
   - "X/total"      -> strip formatting, use directly.
   - "X/credit"      -> multiply by the credit count parsed from
                        `credits_or_duration` when it's expressed as "NN Credits";
                        left blank when duration is Semesters/Years/"Varies"
                        (no reliable multiplier — not guessed).
   - "Fully Funded"  -> 0 (real zero net cost, not missing).
   - "NR"            -> left missing (genuinely not reported).
   Original `price_raw` and `credits_or_duration` are kept unchanged alongside the
   new column so every estimate is traceable back to its source value.
4. Assign a `cip2020_code` (+ `cip2020_code_source`) to every row — this is what
   lets this table join into the rest of the pipeline and be subtracted out of the
   candidate universe. 13 of 15 codes come from Vanderbilt's own official CIP list
   (`docs/planning/CIP_Codes.pdf`); 2 come from the algorithmic shortlist
   (`scripts/suggest_vanderbilt_cip_codes.py`) because the official list doesn't
   cover them (one program is newer than the list's review date, one has no exact
   name match). See docs/decisions-log.md for the full mapping and reasoning.
"""
import re
from pathlib import Path

import pandas as pd

RAW_PATH = Path("data/raw/vanderbilt_current_programs.csv")
CLEAN_PATH = Path("data/clean/vanderbilt_current_programs_clean.csv")

CREDITS_RE = re.compile(r"(\d+)\s*Credits?", re.IGNORECASE)

# CIP2020 codes assigned per program. Source is either (a) Vanderbilt's official
# Registrar CIP list (docs/planning/CIP_Codes.pdf, reviewed August 2025 and tracked in
# this repo — see decisions-log-detailed.md, Step 17, on why keeping it public is deliberate),
# matched by exact or near-exact program name, or (b) the algorithmic shortlist
# (scripts/suggest_vanderbilt_cip_codes.py), used only where the official list has no
# entry. See docs/decisions-log.md for the full reasoning and match-rate against the
# official source.
CIP_CODE_ASSIGNMENTS = {
    "Master of Science in Applied Clinical Informatics": ("51.2706", "official"),
    "Doctor of Nursing Practice": ("51.3818", "official"),
    "PhD in Nursing Science": ("51.3808", "official"),
    "Master of Science in Nursing": ("51.3801", "official (matched via plain \"Nursing\" entry)"),
    "Master of Legal Studies": ("22.0000", "official"),
    "Master of Engineering in Engineering Management": ("14.0101", "official"),
    "Master of Science in Computer Science": ("11.0701", "official"),
    "Master of Science in Artificial Intelligence": ("11.0102", "algorithmic shortlist (program launched after the official list's Aug 2025 review — not yet covered by it)"),
    "Doctor of Ministry in Integrative Chaplaincy": ("39.0602", "official"),
    "Doctor of Education in Leadership and Learning in Organizations": ("52.0213", "official"),
    "Master of Education in Independent School Leadership": ("13.0401", "official"),
    "Master of Education in Multilingual Education": ("13.1401", "official (matched via \"Multilingual Learner Education\" entry)"),
    "Master of Education in Innovative Design and Technology in Education": ("13.0501", "official (listed as IDeaTE)"),
    "Master of Education in Applied Behavior Analysis": ("42.2814", "official"),
    "Master of Education in Educational Leadership and Organizational Effectiveness": ("13.0401", "algorithmic/inferred (no exact name match in official list; closest is \"Educational Leadership and Policy\")"),
}


def parse_price(price_raw: str, credits_or_duration: str):
    price_raw = price_raw.strip()
    if price_raw == "Fully Funded":
        return 0.0
    if price_raw == "NR":
        return float("nan")
    if price_raw.endswith("/total"):
        amount = price_raw.replace("/total", "").replace(",", "").strip()
        return float(amount)
    if price_raw.endswith("/credit"):
        rate = float(price_raw.replace("/credit", "").replace(",", "").strip())
        m = CREDITS_RE.search(str(credits_or_duration))
        if m:
            return rate * int(m.group(1))
        return float("nan")  # e.g. "5 Semesters", "4 Years", "Varies" — no multiplier
    # Not expected among Master's/Doctorate rows, but handle defensively
    digits = re.sub(r"[^\d.]", "", price_raw)
    return float(digits) if digits else float("nan")


def main():
    df = pd.read_csv(RAW_PATH)
    before = len(df)

    # Step 1: drop certificates
    df = df[df["level"].isin(["Master's", "Doctorate"])].copy()
    print(f"Step 1 — dropped certificates: {before} -> {len(df)} rows")
    assert len(df) == 15, f"expected 15 rows (11 Master's + 4 Doctorate), got {len(df)}"

    # Step 2: fix dual-affiliation school value
    n_fixed = df["school"].str.contains(r"\|").sum()
    df["school"] = df["school"].str.split(r"\s*\|\s*").str[0]
    print(f"Step 2 — normalized {n_fixed} dual-affiliation school value(s)")

    # Step 3: parse price into one total_price_estimated column
    df["total_price_estimated"] = df.apply(
        lambda r: parse_price(r["price_raw"], r["credits_or_duration"]), axis=1
    )
    n_total = df["price_raw"].str.endswith("/total").sum()
    n_credit_converted = df.apply(
        lambda r: r["price_raw"].endswith("/credit") and pd.notna(r["total_price_estimated"]),
        axis=1,
    ).sum()
    n_credit_unconverted = df.apply(
        lambda r: r["price_raw"].endswith("/credit") and pd.isna(r["total_price_estimated"]),
        axis=1,
    ).sum()
    n_funded = (df["price_raw"] == "Fully Funded").sum()
    n_nr = (df["price_raw"] == "NR").sum()
    print(
        f"Step 3 — priced {n_total} already-total, {n_credit_converted} converted "
        f"from per-credit, {n_credit_unconverted} left blank (no credit-count "
        f"multiplier available), {n_funded} fully-funded (-> 0), {n_nr} not-reported "
        f"(-> missing)"
    )

    # Step 4: assign CIP2020 codes (see CIP_CODE_ASSIGNMENTS above for provenance)
    df["cip2020_code"] = df["program_name"].map(lambda n: CIP_CODE_ASSIGNMENTS[n][0]).astype(float)
    df["cip2020_code_source"] = df["program_name"].map(lambda n: CIP_CODE_ASSIGNMENTS[n][1])
    n_official = df["cip2020_code_source"].str.startswith("official").sum()
    n_other = len(df) - n_official
    print(f"Step 4 — assigned cip2020_code to all {len(df)} rows ({n_official} from the official Vanderbilt CIP list, {n_other} from the algorithmic shortlist)")
    assert df["cip2020_code"].notna().all(), "every row must have a cip2020_code assigned"

    print(f"\nFinal shape: {df.shape}")
    print(df[["program_name", "level", "school", "price_raw", "credits_or_duration", "total_price_estimated", "cip2020_code", "cip2020_code_source"]].to_string())

    CLEAN_PATH.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(CLEAN_PATH, index=False)
    print(f"\nWrote {len(df)} rows -> {CLEAN_PATH}")


if __name__ == "__main__":
    main()
