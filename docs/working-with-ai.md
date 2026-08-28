# Working with AI on this project

This project was built with heavy AI assistance across five phases. It also produced a
running record of where that assistance failed, what the failures cost, and which
habits caught them. Those notes are collected here.

Every entry below is a real incident from this build, with the numbers and files
attached. Nothing here is general advice about prompting.

---

## Where the output was wrong

### Confidence and correctness are unrelated

A word-overlap script was used to suggest CIP codes for Vanderbilt's 15 online programs.
Eleven of those suggestions were rated high confidence and accepted before Vanderbilt's
official Registrar CIP list was found. Checking them against that list afterward: 7 of
11 correct, 4 of 11 wrong. Each of the four had a plausible top-scoring candidate that
was simply the wrong code.

An error rate of 36% on the picks the script was most sure about is the useful number.
The low-confidence cases were already flagged for review; the damage was concentrated in
the ones nobody thought needed checking.

**Rule now:** a fuzzy match is a shortlist, never an answer. When an authoritative source
exists, find it and check every row against it, including the ones that look settled.
`scripts/suggest_cip_codes_generic.py` says this in its own header.

### A reasonable-looking threshold collapsed the whole result

The first clustering pass grouped near-duplicate program titles using two rules: share at
least one significant word, and score a high whole-string similarity ratio. That second
rule chained 94 of 126 titles into a single false cluster.

`SequenceMatcher.ratio()` runs high on short, generically worded titles even when they
are unrelated, and clustering by connected components means one bad edge transitively
merges every group it touches. Isolating the stricter rule showed 10 edges, every one a
genuine duplicate.

**Rule now:** when a grouping step produces one enormous cluster, the threshold is the
suspect, not the data. Inspect the edges directly instead of tuning the number.

### "I checked" and "I checked the right thing" are different claims

A question about Tableau field types came back confirmed as fine. The check had looked at
the type icons beside the field names rather than the values rendered on screen. Two real
problems were sitting in plain view: a Year field toggled to Number was showing a date
serial count, and a CIP code under a numeric format was truncating 11.0104 to 11.01.

**Rule now:** ask what was actually inspected, not whether it was inspected. The answer
distinguishes a real check from a plausible one.

### A mockup is not a data source

A generated dashboard wireframe displayed a Go-band count of 128 out of 1,268. The
verified figures are 126 out of a 1,254-candidate population. The image was only ever a
layout study, so the wrong numbers went nowhere, but they were presented with the same
confidence as the layout.

**Rule now:** anything generated for layout gets treated as layout. Numbers inside a
mockup are placeholder text until they come from the pipeline.

### Research can be shallower than its summary suggests

Earlier work on report structure cited two consulting firms' methodologies. Asked
directly whether an actual finished report had been read or only pages describing the
approach, the answer was the second one. Neither firm publishes client deliverables, so
the gap was structural rather than careless.

**Rule now:** ask what was read, not what was concluded. "Find real examples" and "find
pages about real examples" produce very different work.

---

## Where the process was wrong

### Being told to do something is not evidence it happened

An instruction to commit and push was relayed onward and reported as complete. Checking
`git status` directly showed nothing committed: three SQL files and every CSV they
produced were still sitting as uncommitted changes.

A related version of the same failure: an export script was not rerun after a later
script added a column, so the CSV in the repo was one column behind the database. Found
by reading the file rather than trusting the log entry that described it.

**Rule now:** verify state against the repo, never against a summary of the repo. A
status claim is a claim.

### Work computed invisibly cannot be reviewed

Analysis that fed a real decision was built inside a sandbox and reported back as prose
figures, with no file produced. It happened three times before the rule changed.

The output may well have been correct. The problem is that correctness was unverifiable,
and the artifact could not be rerun, inspected, or committed.

**Rule now:** anything informing a decision gets built as a real file in the repo,
matching the project's conventions, and gets run locally. A number in a chat is not a
result.

### Stale docs are instructions to the next agent

After the method changed from a hand-picked list of 12 fields to a fully data-derived
candidate set, the old list stayed in the README and the scoping notes. A later session
read those files, took the 12 as fixed, and proceeded on the wrong basis.

The public cost was separate and larger: the README sat on a public repo describing two
data sources that had been cut, misrepresenting the project's actual scope to anyone
reading it.

**Rule now:** a changed decision is not done until every document reflecting it is
updated. When documents are what the next agent reads, a stale one actively misinforms
it.

### Two sessions on one repo will collide

Two chats were open on this repository at once and both rewrote the same section of the
prompt log without knowing about the other. The conflict had to be reconciled by hand. It
was caught only because the file was re-read fresh before editing rather than assumed
unchanged.

**Rule now:** re-read a file and check `git status` before editing it, every time. Memory
of a file's contents from earlier in a session is not the file.

---

## What actually worked

### Verify the plan before executing it

A join plan drafted in one session was checked against the repo in a fresh pass before
any of it ran. Every factual claim held, and three real gaps surfaced: Vanderbilt's 15
programs map to 14 distinct CIP codes rather than 15, the float join-key risk needed a
structural fix rather than a warning comment, and the suppressed-year completions data
needed an actual rule for computing a trend.

All three were cheap to fix at plan stage. Two of them would have silently corrupted the
mart.

### Verification has a boundary, and it is worth knowing where

Every number in the Phase 3 scoring report was independently recomputed from the mart CSV
in `notebooks/phase3_ai_report_verification.ipynb`. That settled whether the report's
facts were right.

It settled nothing about the normalization method, the composite weights, or the
NULL-handling approach, because those are judgment calls with no number to check them
against. Recomputing more figures would not have helped. Recognizing that boundary is
what stopped the verification pass from becoming an excuse to avoid deciding.

### Write the design first, then have it implemented

The SQL that builds the analysis mart is AI-assisted code implementing a design written
beforehand as a separate spec, `docs/planning/phase2-mart-design-spec.md`. The spec
exists so the provenance is checkable rather than merely asserted.

The prompt that implements it is explicit about the collaboration: implement the
documented design, verify its factual claims against the real data, and propose
improvements for approval. No silent deviation, and no rubber-stamping either.

### Two independent reads converging is real evidence

Dashboard design was researched twice in parallel and without coordination, once through
AI research and once by reading two data visualization books through NotebookLM. Both
arrived at close to the same structure. That agreement was treated as a signal worth
trusting, and the two plans were reconciled rather than one being picked over the other.

### Charts belong in the analysis phase

Every chart in this project was deferred to the dashboard phase by default. The
Go/Test/Pass cutoffs were derived by reading percentile numbers off a table, never by
looking at a histogram, even though a notebook was already open at that moment for
independent verification.

By the time the visualization phase started, zero chart artifacts existed, when several
were a few lines of code away during analysis that had already happened.

**Rule now:** any EDA or verification step produces and saves at least one chart as a
matter of course. It does not need to be presentation quality. It needs to exist.

---

## The division of labor

The framing, the decisions, the judgment calls, and the recommendation are the analyst's.
AI did the mechanical work: scraping, parsing, cleaning, drafting SQL, and generating
documents.

Two things kept that boundary real rather than stated. Design specs were written before
the code that implements them, so the logic has a separate paper trail. And AI-produced
analysis was recomputed independently before it was accepted, so a claim about the data
could be defended by pointing at a notebook instead of at a chat.

Related reading: [`decisions-log.md`](decisions-log.md) for the methodology decisions
themselves, and [`ai-prompts-log.md`](ai-prompts-log.md) for the starter prompts each
phase ran on.
