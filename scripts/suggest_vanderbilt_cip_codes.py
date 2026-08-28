#!/usr/bin/env python3
"""Suggest candidate CIP codes for each of Vanderbilt's 15 (cleaned) programs, for
manual review and pick from. NOT an automated fuzzy-match assignment.

Generated with AI assistance. This script came first; the approach here was later
generalized into the reusable prompt at docs/ai-prompts-log.md (2.2b).

Method: score every (Vanderbilt program name, CIP title) pair by (a) count of
shared significant words and (b) a character-level similarity ratio as a tiebreak,
then print the top 5 CIP candidates per program. The human picks the final match;
this script only narrows 2,143 possible codes down to 5 worth looking at.

Source of CIP codes/titles: data/clean/cip_soc_crosswalk_clean.csv (already on disk,
no new data pull needed).
"""
import re
from difflib import SequenceMatcher
from pathlib import Path

import pandas as pd

VU_PATH = Path("data/clean/vanderbilt_current_programs_clean.csv")
CROSSWALK_PATH = Path("data/clean/cip_soc_crosswalk_clean.csv")

STOPWORDS = {
    "of", "in", "and", "the", "for", "a", "an", "to", "master", "doctor",
    "science", "arts", "degree", "program", "studies", "general",
}


def normalize(text: str) -> set:
    text = re.sub(r"[^a-z\s]", " ", text.lower())
    return {w for w in text.split() if w not in STOPWORDS and len(w) > 2}


def score(vu_name: str, cip_title: str):
    overlap = len(normalize(vu_name) & normalize(cip_title))
    ratio = SequenceMatcher(None, vu_name.lower(), cip_title.lower()).ratio()
    return overlap, ratio


def main():
    vu = pd.read_csv(VU_PATH)
    cw = pd.read_csv(CROSSWALK_PATH)
    cip_titles = cw[["cip2020_code", "cip2020_title"]].drop_duplicates()
    print(f"Matching {len(vu)} Vanderbilt programs against {len(cip_titles)} distinct CIP titles\n")

    for _, row in vu.iterrows():
        name = row["program_name"]
        scored = [
            (score(name, t)[0], score(name, t)[1], code, t)
            for code, t in zip(cip_titles["cip2020_code"], cip_titles["cip2020_title"])
        ]
        scored.sort(key=lambda x: (-x[0], -x[1]))
        top5 = scored[:5]

        print(f"=== {name} ({row['level']}) ===")
        for overlap, ratio, code, title in top5:
            print(f"  {code:>10}  {title:<55}  (word overlap={overlap}, ratio={ratio:.2f})")
        print()


if __name__ == "__main__":
    main()
