#!/usr/bin/env python3
"""Suggest candidate CIP codes for a university's program catalog, for a human to
manually review and pick from — NOT an automated fuzzy-match assignment.

Generated with AI assistance; starter prompt in docs/ai-prompts-log.md (2.2b).

Generic / reusable version of `scripts/suggest_vanderbilt_cip_codes.py` (that file is
the worked example this was generalized from — same method, run on Vanderbilt's 15
online Master's/Doctorate programs). See `docs/ai-prompts-log.md`, entry 2.2b, for the
full 3-stage prompt this script is Stage 1 of (algorithmic shortlist -> tiering ->
official-source verification -> fallback to human judgment if no official source
exists).

HOW TO ADAPT — edit the CONFIG block below, nothing else needs to change:
1. INPUT_PATH        -> your cleaned program-catalog CSV (must have a program-name
                         column).
2. CROSSWALK_PATH     -> any CSV with a CIP-code column + CIP-title column. The
                         CIP-SOC crosswalk's cleaned CIP-SOC sheet works (it has every
                         CIP2020 code at least once), but a plain CIP-code reference
                         list works just as well — this script only reads those two
                         columns.
3. PROGRAM_NAME_COL, CIP_CODE_COL, CIP_TITLE_COL -> match your actual column names.
4. STOPWORDS          -> optional; strip whatever generic words (degree types,
                         "program," "studies," etc.) would otherwise inflate the word-
                         overlap score without reflecting the actual subject matter.

Method (unchanged from the Vanderbilt version): score every (program name, CIP title)
pair by (a) count of shared significant words and (b) a character-level similarity
ratio as a tiebreak, then print the top N CIP candidates per program. This is a
SHORTLISTING aid only — it narrows thousands of possible codes down to a handful worth
a human look. The human (or an official university CIP source, if one exists) picks
the final match; on the project this was built for, 4 of 11 "confident" algorithmic
picks turned out to be wrong once checked against an official source, so treat every
result here as provisional, not final.
"""
import re
from difflib import SequenceMatcher
from pathlib import Path

import pandas as pd

# ---- CONFIG: edit these four things for your project, nothing else ----
INPUT_PATH = Path("data/clean/{PROGRAM_CATALOG}_clean.csv")
CROSSWALK_PATH = Path("data/clean/{CIP_REFERENCE_LIST}_clean.csv")
PROGRAM_NAME_COL = "program_name"
CIP_CODE_COL = "cip2020_code"
CIP_TITLE_COL = "cip2020_title"
TOP_N = 5
# -------------------------------------------------------------------------

STOPWORDS = {
    "of", "in", "and", "the", "for", "a", "an", "to", "master", "doctor",
    "science", "arts", "degree", "program", "studies", "general",
}


def normalize(text: str) -> set:
    text = re.sub(r"[^a-z\s]", " ", text.lower())
    return {w for w in text.split() if w not in STOPWORDS and len(w) > 2}


def score(program_name: str, cip_title: str):
    overlap = len(normalize(program_name) & normalize(cip_title))
    ratio = SequenceMatcher(None, program_name.lower(), cip_title.lower()).ratio()
    return overlap, ratio


def main():
    programs = pd.read_csv(INPUT_PATH)
    cw = pd.read_csv(CROSSWALK_PATH)
    cip_titles = cw[[CIP_CODE_COL, CIP_TITLE_COL]].drop_duplicates()
    print(
        f"Matching {len(programs)} programs against {len(cip_titles)} distinct "
        f"CIP titles\n"
    )

    for _, row in programs.iterrows():
        name = row[PROGRAM_NAME_COL]
        scored = [
            (score(name, t)[0], score(name, t)[1], code, t)
            for code, t in zip(cip_titles[CIP_CODE_COL], cip_titles[CIP_TITLE_COL])
        ]
        scored.sort(key=lambda x: (-x[0], -x[1]))
        top = scored[:TOP_N]

        print(f"=== {name} ===")
        for overlap, ratio, code, title in top:
            print(f"  {code!s:>10}  {title:<55}  (word overlap={overlap}, ratio={ratio:.2f})")
        print()


if __name__ == "__main__":
    main()
