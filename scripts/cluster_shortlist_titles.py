#!/usr/bin/env python3
"""Group near-duplicate CIP program titles within one candidate list, for a human to
manually review and confirm — NOT an automated final grouping.

Sibling script to `scripts/suggest_cip_codes_generic.py` (same word-overlap + char-
similarity scoring method, reused here almost unchanged), but that script matches
PROGRAM NAMES against a CIP reference list; this one matches CIP TITLES against each
other, to find candidates in the same shortlist that are really the same program idea
under different codes (e.g. five nursing-specialty codes that Vanderbilt would launch
as one program, not five).

HOW TO ADAPT — edit the CONFIG block below, nothing else needs to change:
1. INPUT_PATH      -> your shortlist CSV (must have a CIP-code column + CIP-title
                       column; score/other columns are carried through if present).
2. CIP_CODE_COL, CIP_TITLE_COL, SCORE_COL -> match your actual column names.
3. STOPWORDS       -> optional; strip whatever generic words would otherwise link
                       titles that don't actually describe the same program.
4. WORD_OVERLAP_MIN -> titles link into the same cluster if they share at least this
   many significant words (default 3), OR if they share the same 4-digit code prefix
   (see below). Validate this against a sample of your own titles before trusting it --
   see the note in the loop below on why a softer, ratio-based rule was tried first and
   dropped.

Method: score every title pair by (a) count of shared significant words and (b) a
character-level similarity ratio (same two signals as the sibling script), link pairs
that clear the thresholds, then group linked titles into clusters via union-find
(connected components). Separately, flag pairs that share the same 4-digit CIP prefix
(e.g. 51.38xx = the whole Nursing Practice series) -- this is a much stronger signal
than text similarity, since it's the government's own taxonomy grain, not a guess, but
it only catches near-duplicates that happen to be coded in the same series (it would
NOT catch, say, "Data Science" and "Business Analytics" clustering under a broader
data/tech grouping if they sit in different CIP4 series -- text overlap is still needed
for that). This is a SHORTLISTING aid only: it narrows 126 titles down to clusters
worth a human look. Read every cluster before deciding whether it's a true near-
duplicate or just an adjacent-but-genuinely-different program.
"""
import re
from difflib import SequenceMatcher
from itertools import combinations
from pathlib import Path

import pandas as pd

# ---- CONFIG: edit these for your project, nothing else needs to change ----
INPUT_PATH = Path("data/derived/shortlist_review.csv")
CIP_CODE_COL = "cip2020_code"
CIP_TITLE_COL = "cip2020_title"
SCORE_COL = "score"
WORD_OVERLAP_MIN = 3
# -----------------------------------------------------------------------------

STOPWORDS = {
    "of", "in", "and", "the", "for", "a", "an", "to", "master", "doctor",
    "science", "arts", "degree", "program", "studies", "general", "other",
}


def normalize(text: str) -> set:
    text = re.sub(r"[^a-z\s]", " ", text.lower())
    return {w for w in text.split() if w not in STOPWORDS and len(w) > 2}


def score(title_a: str, title_b: str):
    overlap = len(normalize(title_a) & normalize(title_b))
    ratio = SequenceMatcher(None, title_a.lower(), title_b.lower()).ratio()
    return overlap, ratio


def cip4_prefix(code: str) -> str:
    # "51.3805" -> "51.38" -- the 4-digit CIP series, one level up from the CIP6 code.
    whole, _, frac = code.partition(".")
    return f"{whole}.{frac[:2]}"


class UnionFind:
    def __init__(self, items):
        self.parent = {i: i for i in items}

    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, a, b):
        ra, rb = self.find(a), self.find(b)
        if ra != rb:
            self.parent[ra] = rb


def main():
    df = pd.read_csv(INPUT_PATH, dtype={CIP_CODE_COL: str})
    codes = df[CIP_CODE_COL].tolist()
    titles = dict(zip(df[CIP_CODE_COL], df[CIP_TITLE_COL]))
    scores = dict(zip(df[CIP_CODE_COL], df[SCORE_COL])) if SCORE_COL in df.columns else {}

    uf = UnionFind(codes)
    edge_reason = {}  # (code_a, code_b) -> reason string, for the printed evidence

    for a, b in combinations(codes, 2):
        overlap, ratio = score(titles[a], titles[b])
        same_cip4 = cip4_prefix(a) == cip4_prefix(b)
        linked, reason = False, None
        if overlap >= WORD_OVERLAP_MIN:
            linked, reason = True, f"word overlap={overlap}"
        # NOTE: an earlier version also linked on (overlap==1 AND ratio>=0.55) as a
        # softer rule. Dropped it after finding it was the sole cause of a 94/126
        # mega-cluster: SequenceMatcher.ratio() on full title strings runs high for
        # short, generically-worded titles even when unrelated, and just one such
        # false edge is enough to transitively chain the whole list together via
        # connected components. Diagnostic: of all overlap>=3 pairs (the strongest
        # tier), all 10 were genuine near-duplicates -- so overlap alone, at a high
        # enough bar, is the reliable signal here; ratio is not, at this string length.
        if same_cip4:
            linked = True
            reason = (reason + ", " if reason else "") + "same CIP4 series"
        if linked:
            uf.union(a, b)
            edge_reason[(a, b)] = reason

    clusters = {}
    for c in codes:
        clusters.setdefault(uf.find(c), []).append(c)

    multi = {root: members for root, members in clusters.items() if len(members) > 1}
    singles = [m[0] for m in clusters.values() if len(m) == 1]

    multi_sorted = sorted(multi.values(), key=len, reverse=True)
    print(f"{len(codes)} titles -> {len(multi_sorted)} clusters (size >= 2), "
          f"{len(singles)} singles\n")

    for i, members in enumerate(multi_sorted, 1):
        members_sorted = sorted(members, key=lambda c: -scores.get(c, 0))
        member_scores = [scores[c] for c in members if c in scores]
        stats = ""
        if member_scores:
            stats = (f"  (mean={sum(member_scores) / len(member_scores):.1f}, "
                     f"max={max(member_scores):.1f}, min={min(member_scores):.1f})")
        print(f"=== Cluster {i} ({len(members)} programs){stats} ===")
        for c in members_sorted:
            s = scores.get(c)
            score_str = f"score={s:.1f}" if s is not None else ""
            print(f"  {c:>10}  {titles[c]:<65} {score_str}")
        print()

    print(f"=== Singles ({len(singles)}) — no near-duplicate found in this list ===")
    for c in sorted(singles, key=lambda c: -scores.get(c, 0)):
        s = scores.get(c)
        score_str = f"score={s:.1f}" if s is not None else ""
        print(f"  {c:>10}  {titles[c]:<65} {score_str}")

    # Write the shortlist back out with an algo_cluster_id column added, for manual
    # review (e.g. in Data Wrangler) -- singles get their own unique id (prefixed
    # "single-") so every row has a value and the column can be sorted/grouped on.
    cluster_id_of = {}
    for i, members in enumerate(multi_sorted, 1):
        for c in members:
            cluster_id_of[c] = f"cluster-{i}"
    for c in singles:
        cluster_id_of[c] = f"single-{c}"

    out = df.copy()
    out["algo_cluster_id"] = out[CIP_CODE_COL].map(cluster_id_of)
    out["algo_cluster_size"] = out.groupby("algo_cluster_id")[CIP_CODE_COL].transform("count")
    out = out.sort_values(["algo_cluster_size", "algo_cluster_id", SCORE_COL], ascending=[False, True, False])
    out_path = INPUT_PATH.parent / "shortlist_review_clustered.csv"
    out.to_csv(out_path, index=False)
    print(f"\nWrote {out_path} ({len(out)} rows, sorted by cluster size then id then score)")


if __name__ == "__main__":
    main()
