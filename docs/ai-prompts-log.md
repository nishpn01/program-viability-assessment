# AI prompts log

This is a library of starter prompts, one for each phase of this project's build. Each
one already works: copy it, fill in the placeholders in curly braces, and adjust
anything specific to your own project. They're numbered by phase (0, then 1.1, 1.2, and
so on) in the order they actually ran, so the sequence is easy to follow top to bottom.

A short note sits above each prompt explaining what it does. Where the response isn't
obvious from the prompt text alone, that note also describes what kind of answer to
expect. A "How to adapt" note after some prompts spells out exactly what to change for
a different project. Any specific number or filename from this project is an example
of the output.

---

## Phase 0: Kickoff

### 0.1: Kickoff a new data project (reusable)
Seeds a project's problem statement, in one of two ways: from a real job description in
a role you're targeting, or from a self-defined business question. The AI asks
clarifying questions before drafting anything.
> Starting a new data-analysis portfolio project. {CONTEXT}: for example, "modeled on
> this job description: {paste or describe the role}, which does {what the role
> actually does}" or "the business question is {QUESTION}."
>
> Before proposing anything (problem statement, scope, or folder structure), ask me the
> clarifying questions you actually need to set this up properly. At minimum I'd expect
> questions covering: what decision or question this should answer; what data sources I
> already have in mind versus want you to help discover; any deadline or time budget;
> which tools I want practice with (SQL warehouse, visualization tool); whether this repo
> is public/real-identity (changes what stays private, e.g. in a git-ignored `planning/`
> folder); and how hands-on I want to be (execute autonomously vs. walk me through each
> step and wait for my approval before continuing).
>
> Once we've talked through those, propose: (1) a one- or two-sentence problem statement,
> stated as a real, answerable question; (2) a realistic phase plan (collect, clean,
> analyze/SQL, visualize, recommend, or whatever phases actually fit this project); and
> (3) a starting folder structure. Create the actual folders once I approve the plan;
> don't just describe them. Adjust the structure to what this project actually needs
> instead of copying another project's folders wholesale.
>
> *(On this project, the seed was a real Vanderbilt Office of the Deputy Provost Data
> Analyst job posting: a market-research role assessing which new online/professional
> programs the university should launch. That framed the problem statement below; it
> wasn't copied verbatim as the project's own goal.)*

---

### 0.2: Create the project orientation doc (reusable)
Produces the file every future AI session reads first. A project run across many sessions
and more than one AI tool has no shared memory: each new session starts cold, re-derives
context from whatever it happens to read, and that is where wrong assumptions get in. The
orientation doc is the fix. It is what makes a project portable between agents instead of
dependent on one tool's chat history. Expect a filled-in document, not an empty skeleton,
opening with a paragraph written directly to whichever agent picks the project up next.
> Create an orientation doc for this project at `{PATH}` (suggested:
> `docs/ORIENTATION.md`). Its job is to let any AI agent, in any tool, pick this project
> up cold and work on it correctly without asking me to re-explain the project.
>
> Before writing anything, read the repo and establish what is actually true right now:
> the folder structure, what has been built, what the conventions are, what is in git and
> what is deliberately ignored. Discover this from the files rather than asking me, and
> tell me anything you could not determine.
>
> Write it as a filled-in document with real content in every section, not a template
> with placeholders for me to complete. Structure:
>
> 1. **Recalibration paragraph, first thing on the page, addressed to an incoming AI
>    agent.** What this project is, what question it answers, what phase it is in right
>    now, and what to read next before touching anything. Someone should be able to read
>    only this paragraph and not make a beginner's mistake.
> 2. **Current state.** What is done, what is in progress, what has not started.
> 3. **Locked decisions.** Choices already made, with a one-line reason each, and an
>    explicit note that these are settled and should not be reopened without my say-so.
>    This section exists because agents re-litigate settled decisions when they cannot
>    see why they were made.
> 4. **Conventions.** File naming, folder purposes, doc structure, commit style, and
>    anything else a new agent would otherwise guess at and guess wrong.
> 5. **Environment.** What runs where, and why. Note anything that cannot run in a
>    sandboxed session, such as a local database, an API key, or a tool that needs
>    network access, so an agent does not silently fake a step it cannot actually
>    perform.
> 6. **Known traps.** Mistakes already made on this project, so they are not repeated.
>    Be specific about what went wrong, not just what to do.
> 7. **Out of scope.** What was deliberately not done, so an agent does not helpfully
>    build it.
>
> Then add a short maintenance note at the end covering when this doc gets updated, and
> stating the standing rule that an agent re-reads it and checks `git status` before
> editing anything, since more than one session can be open on this repo at once.
>
> Keep it scannable. An agent reading it should reach working knowledge in a couple of
> minutes.

*How to adapt: nothing to swap, since the prompt discovers the project's actual facts at
run time. On a brand-new project with little history, sections 3 and 6 will be thin, and
that is correct; they fill in as the project accumulates decisions and mistakes. Pair
this with 0.3 below. The orientation doc holds what is settled; the handoff doc holds
what happens next.*

---

### 0.3: Create and maintain the agent handoff doc (reusable)
The rolling companion to 0.2, and a different file from both the orientation doc and the
public README. The orientation doc answers "what has happened and what is settled." This
one answers "what is the next task, and what does the agent picking it up need to know."
Without it, every new session begins by asking the human to re-explain what comes next,
which makes the human the only memory in the system. Expect a short, current document
with an append-only log underneath it.
> Create a handoff doc for this project at `{PATH}` (suggested: `docs/HANDOFF.md`), and
> follow the protocol below on every session from now on.
>
> **What the file is for.** It is a baton passed between AI sessions. An agent starting
> work reads it and finds its task already written, with the context and constraints
> attached. Before finishing, that agent writes the next entry for whoever comes after.
>
> **Structure:**
>
> 1. **Current task**, at the top. What to do, why it matters now, the constraints, the
>    files involved, and what "done" looks like concretely enough to check.
> 2. **In flight.** Anything started and not finished, including anything left in a
>    broken or half-migrated state. Say so plainly here rather than leaving it to be
>    discovered.
> 3. **Handoff log**, append-only, newest entry first. Each entry records what was
>    completed, what changed in the repo, anything discovered that changes the next step,
>    what is still open, and a written prompt the next agent can act on directly.
>
> **Protocol, every session:**
>
> - Read this file first, then the orientation doc.
> - Run `git status` and `git log` before writing anything. More than one session can be
>   open on this repo at once, and two agents editing this file without seeing each other
>   produces a conflict that has to be untangled by hand.
> - Never write that a step is done without verifying it against the repo. A claim that
>   something was committed is not the same as a commit existing. Check, then write.
> - Never rewrite or tidy an old log entry. What a previous agent believed it was doing
>   is exactly what you need when something turns out to be wrong.
> - Keep the current-task block short. When a decision is settled for good, move it into
>   the orientation doc and out of here, so this file stays about what is next rather
>   than turning into a second history.
>
> Write the file now with the current task filled in from the actual state of the repo,
> and tell me if you are unsure what the next task should be rather than inventing one.

*How to adapt: nothing project-specific to swap. The one thing worth tuning is how much
detail each log entry carries. On a solo project with one agent at a time, two or three
lines per entry is enough. On a project where several sessions run in parallel, entries
need to be specific about which files were touched, since that is what makes a collision
visible before it becomes a conflict.*

---

## Phase 1: Data collection

### 1.1: Map the data landscape (report-first, do not pull full datasets yet)
Asks the AI to identify what categories of signal a decision actually needs and propose
real sources for each. Expect a short report per candidate source, live-tested for
reachability.
> Context: {PROBLEM_STATEMENT}. Read `{PROBLEM_STATEMENT_DOC}` (e.g. a landscape-scan or
> project-brief doc from Phase 0) for the full framing, and `{BASELINE_DATA}` (e.g. an
> existing-state catalog, if this project has one) for what's already known or already
> offered.
>
> Help me map the data landscape before pulling anything: what categories of signal does
> this decision actually need (demand-side, supply-side, competitive landscape, audience
> size, or whatever genuinely applies to this specific question), and for each category,
> what real, publicly available sources could provide it. I don't have a fixed list in
> mind. Use your judgment, and explain why each source actually fits the category, not
> just that it's topically related.
>
> For every source you recommend, confirm it's actually reachable with one small live
> test call before writing it into the report. Note which access method worked (a direct
> API, a scrape, a manual export), since that affects how much collection work each one
> will take. Return a short report per source (what data, format, how to pull it, how it
> would feed the analysis) and recommend the best 2 to 3 to build on.
>
> *(On this project, that process surfaced BLS Employment Projections, IPEDS completions
> via datausa.io, and program-ranking aggregators like US News as the three worth
> building on. This is a worked example of the output, not a list every project should
> assume.)*

### 1.2: Validate the recommendation against the decision
Stress-tests 1.1's recommended sources against the actual decision before any full pull:
does each source measure the right variable at the right granularity, and can the
resulting tables actually be joined once collected.
> Before pulling any full dataset, stress-test the sources recommended in 1.1 against
> the actual decision: not just whether each is topically related, but whether it
> measures the right variable at the right granularity for *this* decision, and whether
> the resulting tables can actually be joined once collected.
>
> Two concrete failure modes to check for, not just acknowledge in the abstract:
> - **Granularity/fit-for-purpose gaps.** A source can be directionally on-topic but
>   silently wrong for the decision. On this project, IPEDS grad tuition data is by CIP
>   code and university, but not broken out by delivery mode (online vs. in-person), so
>   it couldn't be the primary "online competitor pricing" source even though it looked
>   like a clean, scrape-free substitute for one.
> - **Fragile dependencies.** Anything with no official client, an unofficial or
>   reverse-engineered API, or known rate limits should be live-tested now. On this
>   project, Google Trends failed with a 429 the moment it was actually queried, despite
>   being the originally planned source (see 1.4 for how that got resolved).
>
> Also confirm the join path: name the bridge/crosswalk table (if one is needed) to
> connect the recommended sources on a shared key, and flag it as a pull item if it
> isn't already on the list. End by locking a single, final list of exactly what gets
> collected in the next step. A failure caught here is cheap; one discovered mid-pull
> means coming back for another table later.

### 1.3: Data collection, broad pull (only after 1.2 locks the list)
Pulls exactly what 1.2 locked. Never re-litigates or expands the list at collection time.
> Read the whole repo for context first (`README.md`, then `docs/`, then `data/raw/` and
> `scripts/`).
>
> Candidates/units of analysis are DERIVED from the data, never hand-picked. Pull
> exactly the sources locked in 1.2 (no more, no fewer): save clean raw files to
> `data/raw/` and log each one in `docs/data-sources.md` with its provenance.
>
> Hold off on any source that depends on already knowing the candidates (e.g. a
> per-candidate pricing or ranking pull); that waits until the data itself derives the
> candidate set. Flag, don't pull, any other source you notice along the way that looks
> useful but wasn't part of the locked list. Deliver a short report: what you pulled,
> each table's schema and row counts, data-quality issues found, and exactly how the
> tables are meant to join to each other.
>
> *(On this project, the locked list was BLS Employment Projections, openings plus two
> pre-ranked tables, IPEDS completions via datausa.io, and the NCES CIP↔SOC crosswalk.
> This is a worked example of what "exactly what 1.2 locked" looked like here, not a
> fixed requirement.)*

*Lesson: when a report ends with a multi-item pull list, restate the proposed execution
order explicitly before running it. Sequencing across a multi-source pull is a judgment
call worth confirming explicitly.*

### 1.4: Handling a fragile or failed data source (a recurring pattern)
A recurring pattern for when a source recommended in 1.1/1.2 turns out to be
rate-limited, deprecated, or otherwise unreliable once actually tested. Returns a
primary and an optional secondary alternative, each live-tested.
> A planned source, `{SOURCE}`, is failing. Confirm it's still failing before assuming
> so: re-test it live. If it is, research and live-test real alternatives that could
> serve the same signal, one small test call per candidate, not a full pull. Compare
> them on cost/rate-limits, what signal each one actually measures (search interest vs.
> hiring volume vs. news attention are three different things even when they sound
> similar), and how cleanly each response converts into a tidy table. Recommend a
> primary and an optional secondary.
>
> If the replacement source is queried per-topic rather than pulled in bulk, hold the
> actual pull until the candidates/units of analysis are derived. Collecting data and
> choosing which source to use are two separate decisions.
>
> *(On this project, the failing source was Google Trends: a 429 on the first real
> test. IPEDS's own multi-year completions data ended up covering the same "demand
> trend" need well enough that no replacement was needed. Worth checking whether a
> failing source is still actually necessary before spending effort replacing it.)*

### 1.5: Inspect and explain a collected file
For a file whose purpose or structure isn't self-evident (a crosswalk, a lookup table,
an opaque ID scheme), before relying on it in the next phase.
> Open the file and report: its actual internal structure (sheets/columns, not just the
> filename), concrete numbers that reveal its shape (how many-to-many a join key really
> is: average and max fan-out, not just "it's many-to-many"), and a plain-language
> answer to "why do we need this, what does it let us do that we couldn't otherwise."
> Surface anything structurally surprising (format mismatches against files already
> collected, unexpected cardinality, unmatched or dropped codes) as soon as it's found;
> it changes the next phase's plan.

---

## Phase 2: Clean and join

### 2.1: EDA and plan (explore and discuss first, no cleaning yet)
Profiles the raw tables and proposes a cleaning plan before writing anything. The AI
reports findings, discusses the join/grain decisions, and waits for sign-off before
execution (2.2).
> Read these first for context: `{ORIENTATION_DOC}` and `{DECISIONS_LOG}` (whatever
> this project uses to track prior decisions), `README.md` (or wherever this project's
> problem-statement doc lives), and `docs/data-sources.md`.
>
> Do EDA before any cleaning. Profile the tables, report what you find in plain terms,
> and discuss the decisions before touching any file. Work with whatever raw tables
> currently exist in `data/raw/`; don't assume a fixed count.
>
> Step 1: Profile each table and report back: shape (rows × cols), columns and data
> types, a few sample rows, null/missing counts, and distinct-value counts for key
> columns. Cross-check against any data-quality issues already flagged in
> `docs/data-sources.md` or prior notes. Discover and confirm whatever actually applies
> to *this* project's sources (on this project, that turned out to be BLS
> rollup-vs-detail rows, IPEDS suppressed years, and a many-to-many crosswalk; a
> different project's sources will have their own version of this).
>
> Step 2: Propose a plan, don't execute it yet: what's messy in each table and what
> cleaning it needs; how to handle any many-to-many joins the data actually has, with
> the trade-offs stated; and what the final joined analysis table should look like,
> its columns and its grain (one row per what?).
>
> Flag any decision that needs sign-off before proceeding to execution (2.2).

### 2.1a: Glossary (documentation, no cleaning, reusable, re-run anytime)
Run in an isolated session so the main chat stays focused, then bring the result back
for review. Written to be re-run later in the project (new tables, new modeling terms,
a mart table) without editing the prompt each time.
> Read every file in `docs/` and skim `data/raw/` (and `data/clean/` if it exists) for
> the current state of the project; don't assume a fixed term list, since this prompt
> gets re-run as the project grows.
>
> If `docs/glossary.md` already exists, treat this as an update pass: keep entries that
> are still accurate, fix any that are now wrong, and add anything new since the last
> run. If it doesn't exist yet, create it.
>
> Define every domain term, acronym, and internal-jargon phrase that could stop a reader
> from any of these backgrounds: a technical hiring manager with no higher-ed or labor-
> market background, a fellow data/business analyst unfamiliar with this specific domain,
> a non-technical executive skimming the README, a student new to data work. Scan the
> actual docs and data for what needs defining rather than working off a fixed checklist
> (the list below is *this project's* actual domain vocabulary: CIP / CIP6, SOC, the
> CIP↔SOC crosswalk / junction (bridge) table, ODP, IPEDS, BLS, "Line item" vs "Summary",
> Go/Test/Pass, grain, join cardinality, staging vs. mart tables, TAM, ERD, Mermaid,
> CRISP-DM; a different project will have its own jargon instead).
>
> Each definition: 1 to 3 plain-English sentences, no jargon explaining jargon. Group or
> tag entries by likely audience if that helps readability. Documentation only; do not
> touch any files in `data/raw/` or `data/clean/`.

### 2.1b: Data dictionary (documentation, no cleaning, reusable, re-run anytime)
Run in an isolated session, then bring the result back for review. Written to be re-run
as tables are added, cleaned, or feature-engineered, without editing the prompt.
> Scan `data/raw/` and `data/clean/` (if it exists) for whatever tables/files actually
> exist right now; don't assume a fixed count, since this prompt gets re-run over the
> life of the project. Read `docs/data-sources.md` for provenance context.
>
> If `docs/data-dictionary.md` already exists, treat this as an update pass: keep
> sections still accurate, update any that changed (a raw table that's since been
> cleaned, or a new derived/mart table), and add a section for anything undocumented. If
> it doesn't exist yet, create it.
>
> For each table/file found, profile it directly with pandas (re-derive, don't assume)
> and document: file name/path, its grain (what one row represents, plain English), and a
> column table (name, dtype, plain-English meaning, null/missing notes). Organize by
> pipeline stage (raw / clean / analysis-mart) once more than one stage exists.
> Documentation only; do not modify or write anything inside `data/raw/` or `data/clean/`.

### 2.1c: ERD (documentation, no cleaning, reusable, re-run anytime)
Run in an isolated session, then bring the result back for review. Mermaid renders
natively on GitHub, so no separate design tool is needed. Written to be re-run as new
tables or keys are added.
> Scan `data/raw/` and `data/clean/` (if it exists), plus `docs/data-sources.md` and
> `docs/decisions-log.md`, for the current tables and how they actually relate; don't
> assume a fixed set, since this prompt gets re-run as the project grows.
>
> If `docs/erd.md` already exists, update it to reflect the current state. Otherwise
> create it, with a Mermaid `erDiagram` code block showing each table, its key
> column(s), and the relationship between tables (one-to-one, one-to-many, many-to-many).
> Base the diagram entirely on whatever tables and keys actually exist right now (the
> specific example below is this project's current shape at time of writing:
> `ipeds_completions_masters` (CIP6) links to `cip_soc_crosswalk` (the CIP-SOC
> junction/bridge table, many-to-many), which links to `bls_occupational_openings`
> (SOC), plus `vanderbilt_current_programs` as currently unkeyed pending a CIP-coding
> decision; a different project's diagram will look nothing like this). If the tables
> relate through a many-to-many junction/bridge table, add 2 to 3 plain-English
> sentences above the diagram on what that is and why it's needed here. Documentation
> only; do not modify any data files.

*Lesson: write documentation-generation prompts to scan and update automatically. A
rigid prompt ("these 6 tables," "at minimum these terms")
needs a rewrite every time the repo grows; a scan-and-update prompt gets reused all
project long unchanged.*

### 2.2: Execute clean and join (only after the 2.1 plan is agreed)
> Following the plan agreed in 2.1, clean the tables step by step, explaining each
> operation as it's applied rather than batching it silently. Then join and derive the
> analysis table agreed on. Write cleaned outputs to `data/clean/`, the joined/derived
> table wherever agreed, and log the cleaning and join decisions (especially any join
> rule locked in 2.1) in `docs/decisions-log.md`. Note explicitly anything deferred out
> of this pass, so it reads as a deliberate choice later, not a gap someone forgot.

*In practice on this project, the "join and derive" half of this prompt grew into its
own dedicated step and prompt, 2.3 below, once it moved into SQL against a real
database. Use 2.2 for the cleaning pass, 2.3 for the join/derive.*

### 2.2a: Reusable single-table cleaning prompt
Works pasted into a session with full repo context, or a fresh chat with repo access.
Not guaranteed self-contained in a single-table cleaning tool's own AI chat; see Stage 2
below, which some tables need and a single-table tool can't do.
> Clean `{TABLE_NAME}` from `data/raw/` into `data/clean/{TABLE_NAME}_clean.csv`. If
> `docs/decisions-log.md` or `docs/data-dictionary.md` already document known issues for
> this table (rollup/summary rows to filter, suppressed values, mixed-unit columns,
> known unmatched codes), follow those. If not, profile the table yourself first
> (dtypes, nulls, distinct-value counts, a few sample rows) and work out what needs
> fixing from what you actually find.
>
> **Stage 1, standard single-table checks:** rows that are category totals or header
> rows rather than real records (drop them, and report how many); numbers stored as text
> with commas or currency symbols (strip and cast to float); column names with spaces,
> HTML artifacts, or punctuation that SQL won't accept (rename to snake_case); stray
> punctuation in text values (e.g. a trailing period on every title).
>
> A column mixing units without saying so (some rows total, some per-credit, some
> "fully funded" or "not reported") needs more than a flag: propose a specific,
> documented conversion rule per case, and get it approved before applying it. State
> which rows the rule can't resolve, and why, rather than guessing a value for them.
>
> **Stage 2, cross-table join-key work (check if this table needs it):** some tables
> can't be fully cleaned in isolation, e.g. deriving a join key that has to match
> another already-cleaned table's format (zero-padding, decimal placement), or dropping
> rows that have no match in a reference table (a crosswalk, a code list). If this table
> needs that, read the other cleaned table(s) it must align with, derive/verify the key
> against them, and report exactly how many rows were dropped/changed and why. This
> stage requires full-repo access; a single-table tool that only sees this one file
> can't do it.
>
> **Not covered here:** assigning a code from an external classification system to a
> program/catalog table (e.g. CIP-coding a university's programs) has its own prompt,
> 2.2b, since it needs a different kind of source-verification step.
>
> Explain each cleaning step as it's applied: what changed, how many rows or values
> were affected. Before saving, run a verification check: does the row count make
> sense, and did any step silently introduce new missing values that weren't there
> before? Never modify or overwrite anything in `data/raw/`. After saving, note whether
> this table's cleaning involved a judgment call worth adding to `docs/decisions-log.md`,
> or was purely mechanical.

### 2.2b: CIP-coding a program catalog (reusable, algorithmic shortlist plus official-source verification)
Run whenever a table needs a CIP2020 code assigned per row (e.g., a university's own
program catalog) so it can join into a CIP-keyed pipeline. Works whether or not an
official CIP source exists for the institution; the prompt branches on what's found.
Uses `scripts/suggest_cip_codes_generic.py` (the parameterized version of
`scripts/suggest_vanderbilt_cip_codes.py`, the worked example this was built from) for
the algorithmic shortlisting stage.
> I need to assign a CIP2020 code to every row in `{PROGRAM_CATALOG_CSV}` so it can join
> into `{CIP_REFERENCE_CSV}` and the rest of the CIP-keyed pipeline. Do this in three
> stages; every code needs a documented source.
>
> **Stage 1, algorithmic shortlist and tiering.** Edit the CONFIG block at the top of
> `scripts/suggest_cip_codes_generic.py` to point at this project's program-catalog file
> and CIP reference list/crosswalk, then run it. It scores every (program name, CIP
> title) pair by word overlap and a character-similarity ratio, and prints the top 5 CIP
> candidates per program. Treat these as a shortlist, not answers; this step only
> narrows thousands of possible codes down to a handful worth a human look. Split the
> results into two tiers: programs where one candidate clearly scores ahead of the rest
> (a plausible pick), and programs where no candidate stands out (flag as low-confidence,
> no pick yet). Report both tiers back as a short triage summary, so review time goes
> where judgment is actually needed.
>
> **Stage 2, check for an official source before finalizing anything.** Ask whether the
> institution publishes its own official CIP code list (many university Registrars do:
> check their site, or ask to look). If one exists, use it to verify or correct every
> row from Stage 1, including the ones that already looked confident. On the project
> this prompt was built from, 4 of 11 "confident" algorithmic picks turned out to be
> wrong once checked against the official source. A clean word-overlap score and a
> correct answer are two different things.
>
> **Stage 3, fallback if no official source exists.** If the institution has no
> official list (or a specific program isn't covered by it, e.g. it launched after the
> list's last review date, or has no exact name match), fall back to judgment on the
> Stage 1 shortlist alone. State explicitly, per program, that this is what happened.
> An algorithmic "confident" pick stays provisional until a real source confirms it.
>
> For every row, record two things alongside the code itself: the code, and its source
> (`"official"`, `"official (matched via ...)"` if the match required interpretation, or
> `"algorithmic shortlist"` / `"algorithmic/inferred"` if no official source covered it).
> Log the full mapping, the match/mismatch count against any official source found, and
> the reasoning in `docs/decisions-log.md`.

*How to adapt: point `scripts/suggest_cip_codes_generic.py`'s CONFIG block at your own
cleaned program-catalog CSV and CIP-code source (crosswalk or plain CIP list), matching
column names. The three-stage structure stays the same project to project; only Stage
2's outcome (official source found or not) branches what the rest of the work looks
like.*

---

### 2.3: Join/derive, build the analysis mart in SQL (reusable, closes Phase 2)

Needs full repo context plus access to the machine where the database runs; a sandboxed
chat can plan this step but not execute it against a local database. Opens by verifying
a previous plan before acting on it: on this project that caught three real gaps in
an earlier session's otherwise-sound plan (a distinct-count discrepancy in the
catalog-overlap list, floating-point join keys, suppressed-year trend handling) before
any of them became bugs. The design itself lives in a standalone spec in the planning
folder, written as the analyst's logic with the SQL as its AI-assisted implementation,
so the design's provenance is checkable separately from the code.

> I'm completing the final step of the data-preparation phase of a project that scores
> and ranks candidate options (academic programs, products, market segments, whatever
> this repo's unit of analysis is) toward a decision recommendation: joining the
> cleaned source tables into a single analysis mart. Collection and per-table cleaning
> are already done. Read `{ORIENTATION_DOC}` first for orientation, then
> `docs/decisions-log.md` for which design rules are already locked, and the data
> dictionary's Clean section for each table's actual columns, grain, and known gaps.
> Discover table names, row counts, join keys, and coverage from the live files here,
> not from another project.
>
> The design for this step is mine, documented as a standalone spec in the planning
> folder ({DESIGN_SPEC}; on this project: `docs/planning/phase2-mart-design-spec.md`):
> the mart's construction steps, integrity rules, and target columns. Read it after the
> orientation docs and implement that design, but treat it the way you'd treat any plan
> written outside this session: re-check every factual claim in it (row counts,
> distinct-key counts, column names, documented coverage gaps) against the actual data,
> and assess the design independently. If you see a better construction or a real gap,
> propose the improvement with your reasoning for approval. Report what held, what
> didn't, and what it missed.
>
> Before building anything:
>
> 1. Separate this step's design decisions into already settled (cite the decision-log
>    entry or the design spec) and still open. For each open one (the mart's grain, any
>    rule for collapsing a many-to-many mapping into per-row metrics, whether
>    sparsely-covered reference data may enter the metrics at all, how the
>    catalog-overlap comparison matches), present the options with trade-offs and a
>    recommendation. These are mine to approve or reject.
> 2. Propose the mart's target schema: one row per unit of analysis, each column tied
>    to its source table(s) and the exact rule that computes it, including what a NULL
>    in that column will mean.
>
> Execute only after approval, in SQL against a real database rather than in the
> cleaning language, as numbered, versioned `.sql` files that run in order. The
> database itself is part of the plan: propose what to run this on (engine, local vs.
> hosted, how connection and authentication will work) based on what's actually
> installed on this machine and what the project's docs call for, and set it up only
> once that's agreed. Requirements, and for each, state the reasoning so the choice can
> be verified:
>
> - Column types that make joins exact: identifier codes stored as text or exact
>   decimals, never floating point. Declare each staging table's primary key so its
>   documented grain is enforced by the database.
> - After loading, a verification-check script comparing expected vs. actual: row
>   counts, distinct-key counts, and the known imperfections (unmatched codes,
>   documented gaps) pinned as numbers, reported PASS/FAIL, so neither the data nor its
>   flaws drift silently.
> - Build the mart from the base table outward with join directions that keep every
>   candidate row: a metric that can't be computed is NULL (unknown), a meaningful zero
>   stays zero, and a per-row count records how much source data backs the derived
>   metrics.
> - Independently re-verify at least one row: recompute its derived numbers from the
>   raw source values outside the pipeline and show both results side by side.
> - A deterministic export (stable ordering) so reruns diff cleanly; every mart column
>   documented in the data dictionary; every decision and its reasoning logged in the
>   decision log.
>
> For each technique used (window functions, weighted aggregation, join direction, type
> choices), state the concept and why it applies to this data, plainly enough to check
> the choice independently. Flag anywhere the data is ambiguous or the reasoning is
> uncertain.

*How to adapt: the prompt names no tables, counts, or institutions; the repo docs it
points at carry all of that, which is what makes it portable. The real dependencies are
(a) that the orientation doc, decision log, and data dictionary exist and are current
(a project without them needs those first, prompts 2.1a to 2.1c), and (b) the design
spec, per-project, written by the analyst before this prompt runs. The prompt
implements and stress-tests a documented design.
The SQL dialect and database engine are also unspecified (Postgres here), since
choosing them is part of the prompt's own plan step. Outcome on this project:
`derived_candidates`, 1,268 rows, built by `sql/04_build_derived_candidates.sql`.*

---

## Phase 3: SQL analysis and scoring

### 3.1: Score and rank the analysis mart (reusable)

Continues from 2.3's output, in a fresh chat, since this is genuinely new analysis
work. Every claim needs stated evidence, checkable independently. Expect a profiling
report and a proposed plan first; nothing gets built until the plan is approved. If the
mart lives
in a local database, a sandboxed chat can profile the exported CSV and draft the
queries, but running SQL against the live database happens on the machine that hosts it.

> I'm turning the analysis mart from a project that scores and ranks candidate options
> (academic programs, products, market segments, whatever this repo's unit of analysis
> is) into an actual composite score and a banded recommendation (Go/Test/Pass, or
> whatever categorical verdict this project uses). Data collection, cleaning, and the
> join/derive step are already done. Read `{ORIENTATION_DOC}` first for orientation,
> then the most recent relevant entries in `docs/decisions-log.md`, and the data
> dictionary's Analysis Marts section for the mart's actual columns and grain. Discover
> and verify this project's own column names, row counts, and metrics.
>
> Profile the mart first and present a plan before building anything. For every claim
> or recommendation, state the evidence behind it (the actual numbers found by
> querying/profiling), stated plainly enough to verify independently before moving to
> the next step.
>
> 1. Identify the mart's actual metric columns and report their real distributions
>    (min/max/median/percentiles) and null counts per column, with a plain-language
>    reason for each null pattern found (e.g. "no match in a reference table,"
>    "insufficient historical data"). Discover and report this project's real numbers.
> 2. Propose a normalization method for putting these metrics onto comparable scales,
>    given whatever mix of units they actually turn out to be. State the trade-offs of
>    each option considered and why one is recommended over the others.
> 3. Propose composite-score weights, with reasoning for each weight spelled out. This
>    is a decision to approve or reject, not a default to finalize independently.
> 4. State exactly how every null pattern found in step 1 is handled in the score, and
>    weigh that choice against at least one alternative (excluding affected rows,
>    scoring on partial data, a neutral placeholder).
> 5. Only after the score is computed, report its actual distribution and propose band
>    cutoffs from that real distribution.
>
> Flag explicitly anywhere the data is ambiguous or the reasoning is uncertain. Discuss
> and agree on the plan first; execute only after approval.

*How to adapt: the prompt names no columns, weights, or cutoffs; the data dictionary
and the mart itself carry all of that, discovered fresh each run. The real dependency
is that the mart already exists with documented columns (a project without one needs
2.3 first). Outcome on this project: method locked and scored in `sql/06`, with the
reasoning in `docs/planning/phase3-scoring-findings.md`. Cutoffs (step 5) needed their
own follow-up prompt, 3.3 below, once the score existed.*

### 3.2: Independently verify a scoring findings report (reusable)

Continues from 3.1's output, run in a separate notebook/session so the check stays
independent of the reasoning that produced the report. Recomputes from the raw
data, never from the report's own numbers, and reports MATCH/MISMATCH explicitly.
Outcome on this project: `notebooks/phase3_ai_report_verification.ipynb`, every claim
in `docs/planning/phase3-scoring-findings.md` matched on first run.

> Read {FINDINGS_REPORT} (the report to verify) and {DATA_FILE} (the underlying data it
> was computed from). Recompute every numeric claim in the report directly from
> {DATA_FILE}.
>
> Build a notebook, one claim per section, that: states the claim from the report in a
> markdown cell; computes it independently from {DATA_FILE} in the next cell; and
> reports MATCH or MISMATCH explicitly.
>
> Cover at minimum: every distribution statistic named in the report for each numeric
> column, null/missing counts per column including any overlap the report claims
> between them, and any other specific number stated as fact (row counts, correlation
> coefficients, category breakdowns). For a normalization or methodology recommendation
> specifically, demonstrate the trade-off empirically on a few real, representative rows
> so the claim is visible in actual output, on top of recomputing the summary statistic.
>
> Explain each technique in a short note the first time it's used, at whatever depth
> matches who's actually going to read this. End with a summary table built from the
> individual checks (claim, report's value, notebook's value, match) rather than
> retyped by hand, and flag anything that doesn't match.

*(Each verification-check section in the resulting notebook also carries its own small
starter prompt, a claim-scoped, adaptable version of this same idea, for anyone who
wants to regenerate or adjust a single check without touching the whole notebook. Those
live inline in the notebook itself.)*

### 3.3: Derive band cutoffs from a real score distribution (starter prompt)

Continues from 3.1/3.2, once a composite score exists on every row. A checklist-style
starting point: five standalone, checkable queries, each verified on its own before
being folded into a final script. Expect the AI to return one result at a time, in
order, building up to the final file gradually. Outcome
on this project: `sql/08_score_bands.sql`, cutoffs at the 90th percentile and the
median (the distribution had no natural break), band counts 126/502/626.

> Derive [Go/Test/Pass, or whatever categorical bands this project uses] cutoffs from
> the real score distribution on [the scored table]. Work through this as a sequence of
> standalone, checkable queries:
>
> 1. Define the population: which rows actually belong in this analysis, settled before
>    computing any statistic.
> 2. Five-number summary plus a spread of percentiles (10th/25th/75th/90th/95th/99th) on
>    the score column.
> 3. Sanity-check the extremes: pull the actual top and bottom rows by score, on top of
>    the summary numbers.
> 4. Look at the shape: bucket the score into ranges and count rows per bucket. Is
>    there a natural cliff/gap, or is the distribution smooth?
> 5. Set the cutoffs: cite a real break if one exists; if the distribution is smooth,
>    use a named, defensible convention (e.g. top-decile / median split), and say
>    plainly that's what's happening.
>
> Consolidate into one clean, well-commented SQL script once all five hold up
> individually, matching this repo's existing CTE-per-step style. Log the final cutoffs
> and the reasoning in the decision log, cited against the real numbers from steps 2 to 4.

*How to adapt: names no specific bands, table, or column; works for any categorical
banding decision once a continuous score exists. The core reusable part is the
four-step framework and the one-step-at-a-time pacing.*

### 3.4: Cluster near-duplicate titles within a shortlist (starter prompt)

Continues from 3.1 to 3.3, once a shortlist of scored candidates exists. Groups
near-duplicate entries (same real program, different code) as a first pass for human
review.

> Given a CSV of shortlisted candidates (code, title, score), write a script that
> groups titles likely to represent the same real program under different codes, as a
> first pass for human review.
>
> 1. Score every pair of titles by (a) count of shared significant words after removing
>    generic terms (degree types, "general," "other," etc.) and (b) a character-level
>    similarity ratio as a secondary signal.
> 2. Pick a conservative threshold for what counts as "linked," validated against a
>    sample before trusting it. A softer rule (fewer shared words plus a high similarity
>    ratio) is prone to false positives on short, generically worded titles, which can
>    chain unrelated items into one oversized cluster through transitive grouping.
>    Check for this failure mode specifically.
> 3. If the codes carry a hierarchical structure (e.g. a shared prefix), use it as an
>    independent, authoritative signal alongside text similarity; it catches
>    near-duplicates that text alone might miss or wrongly merge.
> 4. Group linked titles into clusters (e.g. via union-find / connected components).
> 5. Export the original data with a cluster ID column added, sorted by cluster, for
>    manual review.

*How to adapt: swap the CSV path and column names; adjust the "generic terms" stopword
list to your domain; tune the linking threshold against a sample of your own data.*

## Phase 4: Tableau dashboard

### 4.1: Build a dashboard's CSV extracts from a locked design spec (starter prompt)

Continues from the scoring/analysis phase, once a BI dashboard's content is already
designed and locked; this prompt only builds the data behind it. Same
pattern as 2.3: the design is the analyst's, documented separately, and this prompt
implements and stress-tests it. Tableau Public specifically can't connect live to a
database, so every dashboard needs its data pre-extracted to CSV regardless of how the
design decisions got made; a different tool (Power BI, Looker, a live Tableau Server
connection) might skip this step entirely.

> I'm building the CSV extract(s) a BI dashboard will read directly. The dashboard's
> content and structure are already locked in {DESIGN_SPEC}; read it first, along with
> {DECISION_LOG} for the reasoning behind it. Implement exactly what's specified rather
> than adjusting the design here, and treat every factual claim in the spec (column
> names, expected row counts, filter logic) the way you'd treat any plan from outside
> this session: verify it against the live database.
>
> Write one numbered SQL file (matching this repo's existing style: numbered steps, a
> preview `SELECT` before each export, comments explaining why each step exists) that
> produces every extract the spec calls for. For each extract:
>
> 1. State the expected row count and what population/filter defines it, before writing
>    the export, so there's something to check the actual result against.
> 2. If the extract needs a value that doesn't already exist on any table (a label, a
>    flag, a name mapped from a small fixed list), build it as its own small lookup
>    table joined in, so the mapping is visible and reusable in one place.
> 3. If the extract could plausibly have missing rows (a filtered date range, a category
>    that isn't guaranteed complete), check for gaps before exporting: build the full
>    expected combination set and compare it against what actually exists. If gaps are
>    found, work out whether the cause is a real, explainable pattern (e.g. a category
>    that didn't exist yet for part of the date range) or a genuine data-quality
>    problem, and say which it looks like and why.
>
> Run every export against the real database and report the actual row counts back
> against what step 1 predicted. Don't commit or push anything.

*How to adapt: names no tables, columns, or extract count; the design spec (written
per-project, before this prompt runs) supplies all of that. The gap-check step (3) only
applies when an extract could plausibly be incomplete; skip it where completeness isn't
in question. Outcome on this project: `sql/11_dashboard_extracts.sql`, two extracts, a
1,254-row scored population and a 49-row completions trend (16 of an expected 65 rows
missing, traced to two CIP codes with no completions data anywhere before 2020,
consistent with them being new codes added in the CIP2020 taxonomy revision).*

## Phase 5: Written recommendation (full report) and deck

### 5.1: Contribute your phase's findings to the shared Phase 5 report draft (reusable across all four phases)

Run this same prompt, unmodified, in any of the Phase 0 to 4 chats once a shared draft
skeleton exists. It's deliberately generic: it doesn't name a phase number or tell the
chat which section to write in, since each phase chat already knows its own history and
is better placed than a fresh Phase 5 session to judge what from its own work belongs
in the final report. Structure locked before this prompt runs: answer-first, grouped by
evidence pillar, with a first-class Methodology and Limitations section.

> We're assembling the final Phase 5 report. A shared draft skeleton exists for this
> purpose; read it first, along with this repo's `docs/decisions-log.md` and whatever
> working notes it keeps, for the reasoning needed.
>
> Before editing: check `git status` and `git log` on this repo. If the draft file has
> uncommitted changes from another session, read them first so nothing overwrites
> another phase's contribution.
>
> Using your own phase's actual work (its recap doc if one exists, its planning specs,
> its decisions-log and working-note entries, its real output files), add whatever
> findings, numbers, decisions, corrections, or honest caveats from your phase belong in
> the report, in whichever section(s) of the draft they actually fit. Use your own
> judgment about what's relevant; don't feel confined to one section, and leave a
> section alone if your phase has nothing to add to it.
>
> Ground rules:
> - Leave a visible inline comment on another phase's contribution rather than editing
>   or removing it directly, even if it looks wrong.
> - Leave the Executive Answer section for last, once every phase's findings are in.
> - Write it the way this repo's other docs are written: factual, specific numbers over
>   vague claims, decisions attributed to whoever actually made them.
> - If something is genuinely ambiguous or needs sign-off before it can be stated as
>   fact, say so directly in the draft.
>
> Leave the changes for review; don't commit or push.

*How to adapt: nothing project-specific to swap; the prompt is intentionally silent on
phase number, section names, and file paths beyond the one shared draft, since those
are either already known to whichever chat runs it or spelled out inside the draft
skeleton itself. Reusable as-is on a future project's own multi-phase report pass,
provided that project also keeps a decisions log, some form of running working notes,
and a shared draft skeleton to point at.*
