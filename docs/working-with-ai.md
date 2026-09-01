# Working with AI on this project

I used AI throughout this project for research support, code drafts, data preparation,
verification, and document production. The arrangement saved time, but it also created
errors that looked credible until I checked the underlying files and sources.

This is a record of those failures and the practices I kept. Each example comes from this
repository and includes the relevant number, file, or artifact.

## Errors found in the output

### Four high-confidence CIP matches were wrong

A word-overlap script suggested CIP codes for Vanderbilt's 15 online programs. Eleven
suggestions were marked high confidence and initially accepted. Vanderbilt's official
Registrar CIP list later showed that only 7 of the 11 were correct.

The low-confidence matches were already waiting for review. The larger risk came from the
four plausible answers that the script labeled with confidence. I now treat a fuzzy match
as a candidate list. When an authoritative source exists, every proposed match must be
checked against it. The warning is also recorded in
[`scripts/suggest_cip_codes_generic.py`](../scripts/suggest_cip_codes_generic.py).

### One clustering rule connected 94 of 126 titles

The first attempt to group similar program titles required a shared significant word and
a high `SequenceMatcher.ratio()` score. The string-similarity rule connected 94 of the
126 Go-band titles into one cluster.

Short, generic program names can receive high similarity scores even when they describe
different fields. Connected-component clustering made the problem worse because one bad
edge joined every group it touched. Removing that rule left 10 edges under the stricter
test, and inspection confirmed that all 10 represented genuine duplicates.

This changed how I review grouping methods. A very large cluster is now a reason to
inspect the individual edges and the matching rule before interpreting the group.

### The Tableau check examined icons instead of values

A review of Tableau field types was reported as complete after checking the icons beside
the field names. The displayed values still contained two errors. A Year field formatted
as a number showed a date serial, and a numeric CIP field shortened 11.0104 to 11.01.

The lesson was specific: a field-type review must include the values rendered in the
worksheet. Verifying that a check occurred is not enough if the check examined the wrong
part of the artifact.

### A dashboard mockup contained unverified numbers

A generated wireframe showed 128 Go candidates out of 1,268. The verified result was 126
out of a 1,254-candidate population. The mockup was used only to evaluate layout, so the
incorrect values did not enter the analysis or final dashboard.

I now treat every number in a layout mockup as placeholder text until it is connected to
the pipeline or copied from a verified result.

### Report research stopped at methodology pages

Early research on report structure cited methodology pages from two consulting firms. A
later review found that no finished client report had been examined. Neither firm made
those reports public, but the research summary did not make that limitation clear.

When reviewing research now, I check the underlying material that was actually read. A
page describing how reports are written is different from a completed report showing the
result.

## Process failures

### Repository status was reported incorrectly

An instruction to commit and push was passed to another session and then reported as
complete. A direct `git status` check showed three SQL files and all resulting CSV files
still uncommitted.

A similar problem left an exported CSV one column behind the database because the export
script had not been rerun after the schema changed. Reading the repository state and the
file itself caught both problems.

For this project, completion claims involving Git were checked against `git status` and
the commit history. Generated outputs were also reopened after the pipeline ran.

### Three analyses existed only in chat

Three pieces of analysis that informed decisions were calculated inside a sandbox and
returned as prose. No notebook, query, or output file was created. The numbers may have
been correct, but there was no way to rerun or inspect them.

After that, decision-relevant calculations had to produce a file in the repository and
run locally. The independent scoring check in
[`notebooks/phase3_ai_report_verification.ipynb`](../notebooks/phase3_ai_report_verification.ipynb)
is one result of that change.

### Stale documentation redirected later work

The method changed from a hand-selected list of 12 fields to a candidate universe derived
from national completions data. The earlier list remained in the README and scoping notes.
A later session read those files and continued with the obsolete list.

The public README also continued to name two sources that had been removed from the
analysis. From then on, a methodology change included a search for every document that
described the old decision.

### Concurrent sessions edited the same file

Two sessions rewrote the same prompt-log section without knowing about each other. The
conflict had to be reconciled manually. It was caught because the file was read again
immediately before editing.

The practical rule for this repository became one active editing session per file. Before
changing a file, the session rereads it and checks `git status` for work produced elsewhere.

## Practices that held up

### Review the design before implementation

A fresh review of the proposed join plan found three problems before any SQL ran:

- Vanderbilt's 15 listed programs represented 14 distinct CIP codes.
- The float join key needed a structural fix.
- Suppressed completions years required an explicit trend rule.

The first two could have silently changed the analysis mart. Resolving them in the design
spec was cheaper than tracing them after the join.

### Recompute results independently

Every number in the Phase 3 scoring report was recomputed from the mart CSV in
[`notebooks/phase3_ai_report_verification.ipynb`](../notebooks/phase3_ai_report_verification.ipynb).
That established whether the reported figures matched the data.

The notebook could not decide whether percentile ranking, the composite weights, or the
NULL-handling rule were appropriate. Those were methodology choices. Separating arithmetic
verification from judgment prevented additional calculations from being mistaken for a
decision.

### Write the design before generating the code

The SQL analysis mart implements
[`docs/planning/phase2-mart-design-spec.md`](planning/phase2-mart-design-spec.md), which was
written before the query. The implementation prompt instructed the coding session to
verify the specification against the data and raise proposed changes for review.

This gave the join logic a record separate from the generated SQL and made later changes
easier to evaluate.

### Use a second review when the design choice is subjective

The dashboard structure was researched twice. One pass used AI research; the other used
NotebookLM to review two data-visualization books. Both suggested a similar layout. Their
agreement did not prove that the design was correct, but it provided useful corroboration
before the plans were reconciled.

### Create exploratory charts while the analysis is active

The first analysis pass derived the Go, Test, and Pass cutoffs from percentile tables. No
histogram was saved, even though a notebook was already open for verification. By the time
dashboard work began, the project had no chart showing the score distribution.

For later work, I would create a chart when it helps test a distribution, relationship,
or anomaly during analysis. It can remain rough. The point is to inspect the pattern while
the analytical context is still fresh.

## Division of labor

I owned the framing, methodology choices, interpretation, and final recommendation. AI
handled much of the scraping, parsing, cleaning, SQL drafting, and document production.

Two controls made that division visible in the repository. Design specifications record
the intended logic before implementation, and independent notebooks recompute material
AI-produced results before they are accepted.

The methodology decisions are in [`decisions-log.md`](decisions-log.md). The starter
prompts used in each phase are in [`ai-prompts-log.md`](ai-prompts-log.md).
