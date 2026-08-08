# Lessons learned — process notes for the next project

*Running list of process mistakes and fixes from this project, kept separate from
`decisions-log.md` (which is about *this* project's decisions) so it's easy to skim
before starting the next one. Add to this whenever a mistake is worth not repeating.*

## Generate charts during EDA, don't defer all visualization to a dedicated phase

**What happened:** every chart in this project got pushed to Phase 4 (Tableau) by
default, including quick verification/distribution charts that would have been useful
much earlier — e.g. the Go/Test/Pass band cutoffs (Phase 3) were derived by reading
percentile numbers off a table, never by looking at a histogram, even though a notebook
was already open at that point for independent verification of an AI-generated report.

**Why it's a real weakness, not just a nice-to-have:** by the time Phase 4 started,
there were zero chart artifacts on hand for the dashboard/report, when several were a
few lines of code away during analysis that had *already happened*. A quick
`df['score'].hist()` during the band-cutoff work would have cost almost nothing and
paid for itself twice — once as a sanity check in the moment, once as a reusable asset
later.

**Rule for next time:** any notebook-based EDA or verification step should produce and
save at least one quick chart as a matter of course — treat it as part of *doing* the
analysis, not a separate task to schedule later. Doesn't need to be publication-quality;
it needs to exist. If a phase plan doesn't mention charts until "the viz phase," that's
the signal to add them earlier, not proof they belong only there.

## (add the next lesson here)
