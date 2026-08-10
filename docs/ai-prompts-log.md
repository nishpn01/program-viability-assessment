# AI Prompts Log

The prompts used to build this project, in run order. Each entry is the cleaned-up
version that actually worked — not the messy first draft. Numbered by phase (0, then
1.1, 1.2 …) so the sequence is obvious; run them top to bottom.

> **⚠️ Before publishing (project-end polish — PARKED, do not forget):**
> 1. **Tone** — rewrite every prompt in a professional, "replicate this work" voice.
>    Remove any "teach me / I'm learning / walk me through" language. That's fine while
>    building, but the final artifact a hiring manager reads should read like a
>    methodology, not a lesson.
> 2. **Reusability — done for Phases 0–2, 2026-08-02.** Every Phase 0–2 prompt is now
>    templatized (placeholders like `{TABLE_NAME}`, `{PROBLEM_STATEMENT}`, `{SOURCE}`;
>    project-specific numbers/facts kept only as explicitly-labeled worked examples, never
>    stated as requirements) and carries a short "how to adapt" note where relevant.
>    Apply the same standard to each new phase's prompts as they're written, rather than
>    batching this at the very end — item 1 (tone) is still a genuine end-of-project pass,
>    since "teach me" language is fine mid-build and only needs stripping for the final
>    published voice.

---

## Phase 0 — Kickoff

### 0.1 — Kickoff a new data project (reusable)
*Two proven ways to seed the problem statement: from a real job description in a role
you're targeting (this project's actual origin — a legitimate way to practice a specific
role's real workflow, not just a narrative device), or from a self-defined business
question. Either way, the AI asks before assuming scope — it does not draft a problem
statement or folder structure unprompted.*
> Starting a new data-analysis portfolio project. {CONTEXT}: for example, "modeled on
> this job description — {paste or describe the role}, which does {what the role
> actually does}" or "the business question is {QUESTION}."
>
> Before proposing anything — problem statement, scope, or folder structure — ask me the
> clarifying questions you actually need to set this up properly. At minimum I'd expect
> questions covering: what decision or question this should answer; what data sources I
> already have in mind versus want you to help discover; any deadline or time budget;
> which tools I want practice with (SQL warehouse, visualization tool); whether this repo
> is public/real-identity (changes what stays private, e.g. in a git-ignored `planning/`
> folder); and how hands-on I want to be (execute autonomously vs. walk me through each
> step and wait for my approval before continuing).
>
> Once we've talked through those, propose: (1) a one- or two-sentence problem statement,
> stated as a real, answerable question; (2) a realistic phase plan (collect → clean →
> analyze/SQL → visualize → recommend, or whatever phases actually fit this project); and
> (3) a starting folder structure — create the actual folders once I approve the plan,
> don't just describe them. Adjust the structure to what this project actually needs;
> don't copy another project's folders wholesale.
>
> *(On this project, the seed was a real Vanderbilt Office of the Deputy Provost Data
> Analyst job posting — a market-research role assessing which new online/professional
> programs the university should launch — used as the origin for the problem statement
> below, not copied verbatim as the project's own goal.)*

---

## Phase 1 — Data collection

### 1.1 — Map the data landscape (report-first — do not pull full datasets yet)
*Reusable. Don't hand the AI a fixed source list — ask it to help identify what signal
categories the decision actually needs and propose real sources for each, then verify
every recommendation is actually reachable before it goes in the report.*
> Context: {PROBLEM_STATEMENT} — read `{PROBLEM_STATEMENT_DOC}` (e.g. a landscape-scan or
> project-brief doc from Phase 0) for the full framing, and `{BASELINE_DATA}` (e.g. an
> existing-state catalog, if this project has one) for what's already known or already
> offered.
>
> Help me map the data landscape before pulling anything: what categories of signal does
> this decision actually need (e.g. demand-side, supply-side, competitive landscape,
> audience size — whatever genuinely applies to this specific question, not a fixed
> checklist), and for each category, what real, publicly available sources could provide
> it. I don't already have a fixed list in mind — use your judgment, and explain *why*
> each source actually fits the category, not just that it's topically related.
>
> For every source you recommend, confirm it's actually reachable with one small live
> test call before writing it into the report — don't take a source's reputation on
> faith. Note which access method actually worked (a direct API, a scrape, a manual
> export), since that affects how much collection work each one will take. Return a
> short report per source (what data, format, how to pull it, how it would feed the
> analysis) and recommend the best 2–3 to build on — not the longest list you can
> generate.
>
> *(On this project, that process surfaced BLS Employment Projections, IPEDS completions
> via datausa.io, and program-ranking aggregators like US News as the three worth
> building on — included here only as a worked example of the output, not as sources
> every project should assume.)*

### 1.2 — Validate the recommendation against the decision
*Reusable. The two failure modes below are general; the specific examples are this
project's — substitute your own once you hit a real one.*
> Before pulling any full dataset, stress-test the sources recommended in 1.1 against
> the actual decision — not just whether each is topically related, but whether it
> measures the right variable at the right granularity for *this* decision, and whether
> the resulting tables can actually be joined once collected.
>
> Two concrete failure modes to check for, not just acknowledge in the abstract:
> - **Granularity/fit-for-purpose gaps.** A source can be directionally on-topic but
>   silently wrong for the decision — e.g., on this project, IPEDS grad tuition data is
>   by CIP code and university, but not broken out by delivery mode (online vs.
>   in-person), so it couldn't be the primary "online competitor pricing" source even
>   though it looked like a clean, scrape-free substitute for one.
> - **Fragile dependencies.** Anything with no official client, an unofficial/reverse-
>   engineered API, or known rate limits should be live-tested now, not assumed to work
>   — e.g., on this project, Google Trends failed with a 429 the moment it was actually
>   queried, despite being the originally planned source (see 1.4 for how that got
>   resolved).
>
> Also confirm the join path: name the bridge/crosswalk table (if one is needed) to
> connect the recommended sources on a shared key, and flag it as a pull item if it
> isn't already on the list. End by locking a single, final list of exactly what gets
> collected in the next step — a failure caught here is cheap; one discovered mid-pull
> means coming back for another table later.

### 1.3 — Data collection, broad pull (only after 1.2 locks the list)
*Reusable. Pull exactly what 1.2 locked — never re-litigate or expand the list at
collection time.*
> Read the whole repo for context first (`README.md`, then `docs/`, then `data/raw/` and
> `scripts/`).
>
> Candidates/units of analysis are NOT pre-chosen — they must be DERIVED from the data,
> not hand-picked. Pull exactly the sources locked in 1.2 (no more, no fewer) — save
> clean raw files to `data/raw/` and log each one in `docs/data-sources.md` with its
> provenance.
>
> Hold off on any source that depends on already knowing the candidates (e.g. a
> per-candidate pricing or ranking pull) — that has to wait until the data itself
> derives the candidate set; pulling it now would mean guessing the list instead of
> deriving it. Flag, don't pull, any other source you notice along the way that looks
> useful but wasn't part of the locked list. Deliver a short report: what you pulled,
> each table's schema and row counts, data-quality issues found, and exactly how the
> tables are meant to join to each other.
>
> *(On this project, the locked list was BLS Employment Projections — openings plus two
> pre-ranked tables — IPEDS completions via datausa.io, and the NCES CIP↔SOC crosswalk —
> a worked example of what "exactly what 1.2 locked" looked like here, not a fixed
> requirement.)*

*Lesson: when a report ends with a multi-item pull-list, restate the proposed execution
order explicitly before running it — sequencing across a multi-source pull is a judgment
call, not a default to assume. (This got corrected mid-session: the AI proposed collecting
2 of 3 approved sources first and holding the third; the right call was all three
together.)*

### 1.4 — Handling a fragile or failed data source (pattern, not a fixed template)
*Recurring pattern — use any time a source recommended in 1.1/1.2 turns out to be
rate-limited, deprecated, or otherwise unreliable once actually tested against the real
service, not just assumed reliable because it's well-known.*
> A planned source, `{SOURCE}`, is failing. Confirm it's still failing before assuming so
> — re-test it live, don't rely on a memory of it failing once. If it is: research and
> live-test real alternatives that could serve the same signal, one small test call per
> candidate, not a full pull. Compare them on cost/rate-limits, what signal each one
> actually measures (these are often NOT interchangeable even when they sound similar —
> e.g. search interest vs. hiring volume vs. news attention are three different things),
> and how cleanly each response converts into a tidy table. Recommend a primary and an
> optional secondary; don't default to whichever one happens to work first.
>
> If the replacement source is queried per-topic rather than pulled in bulk, hold the
> actual pull until the candidates/units of analysis are derived — collecting data and
> choosing which source to use are two different decisions; don't collapse them into one
> step.
>
> *(On this project, the failing source was Google Trends — a 429 on the first real
> test — and IPEDS's own multi-year completions data ended up covering the same "demand
> trend" need well enough that no replacement was even required. Worth checking whether
> a failing source is still actually necessary before spending effort replacing it.)*

### 1.5 — Inspect & explain a collected file
*Reusable, not tied to a single source — use any time a collected file's purpose or
structure isn't self-evident (a crosswalk, a lookup table, an opaque ID scheme), before
relying on it in the next phase.*
> Open the file and report: its actual internal structure (sheets/columns, not just the
> filename), concrete numbers that reveal its shape (e.g. how many-to-many a join key
> really is — average and max fan-out, not just "it's many-to-many"), and a plain-language
> answer to "why do we need this, what does it let us do that we couldn't otherwise."
> Surface anything structurally surprising — format mismatches between this file and
> ones already collected, unexpected cardinality, unmatched/dropped codes — as soon as
> it's found. Don't wait to be asked; it changes the next phase's plan.

---

## Phase 2 — Clean + join

### 2.1 — EDA + plan (explore & discuss FIRST — no cleaning yet)
> Read these first for context: `docs/START-HERE.md`, `docs/project-journal.md`,
> `docs/landscape-scan.md` (or whatever this project's problem-statement doc is called),
> `docs/data-sources.md`.
>
> We're starting Phase 2, and I want to do EDA first — understand the data before any
> cleaning. Act as my senior analyst: profile the tables, explain what you find in plain
> terms, and discuss the decisions with me. **Do NOT clean, join, or write any files
> yet.** Work with whatever raw tables currently exist in `data/raw/` — don't assume a
> fixed count.
>
> Step 1 — Profile each table and report back: shape (rows × cols), columns + data types,
> a few sample rows, null/missing counts, and distinct-value counts for key columns.
> Cross-check against any data-quality issues already flagged in `docs/data-sources.md`
> or prior notes — discover and confirm whatever actually applies to *this* project's
> sources (on this project, that turned out to be BLS rollup-vs-detail rows, IPEDS
> suppressed years, and a many-to-many crosswalk; a different project's sources will
> have their own version of this, not necessarily these).
>
> Step 2 — Discuss the plan with me (don't execute): what's messy in each table and what
> cleaning it needs; how to handle any many-to-many joins the data actually has (walk me
> through the options and trade-offs); and what the final joined "analysis" table should
> look like — its columns and its grain (one row per what?). Explain the concepts as
> they come up (keys, grain, join cardinality, schema) so I actually learn them.
>
> Ask me where a decision is mine to make. Only after we agree on the plan do we move to
> execution (2.2). I'm using you as a senior analyst who guides me and does the hands-on
> work.

### 2.1a — Glossary (documentation, no cleaning) — reusable, re-run anytime
*Run in an isolated Claude Code session (keeps the main Cowork chat focused/cheap). Bring
the result back to the main chat for review. Written to be re-run later in the project
(new tables, new modeling terms, a mart table) without editing the prompt each time.*
> Read every file in `docs/` and skim `data/raw/` (and `data/clean/` if it exists) for
> the current state of the project — don't assume a fixed term list, this prompt gets
> re-run as the project grows.
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
> — the list below is *this project's* actual domain vocabulary (CIP / CIP6, SOC, the
> CIP↔SOC crosswalk / junction (bridge) table, ODP, IPEDS, BLS, "Line item" vs "Summary",
> Go/Test/Pass, grain, join cardinality, staging vs. mart tables, TAM, ERD, Mermaid,
> CRISP-DM), included only as an example of the kind of term worth catching. A different
> project will have its own jargon instead — scan for whatever that project's docs and
> data actually use, don't assume this exact list applies.
>
> Each definition: 1–3 plain-English sentences, no jargon explaining jargon. Group or tag
> entries by likely audience if that helps readability — your call. Documentation only —
> do not touch any files in `data/raw/` or `data/clean/`.

### 2.1b — Data dictionary (documentation, no cleaning) — reusable, re-run anytime
*Run in an isolated Claude Code session. Bring the result back for review. Written to be
re-run as tables are added, cleaned, or feature-engineered, without editing the prompt.*
> Scan `data/raw/` and `data/clean/` (if it exists) for whatever tables/files actually
> exist right now — don't assume a fixed count, this prompt gets re-run over the life of
> the project. Read `docs/data-sources.md` for provenance context.
>
> If `docs/data-dictionary.md` already exists, treat this as an update pass: keep
> sections still accurate, update any that changed (e.g. a raw table that's since been
> cleaned, or a new derived/mart table), and add a section for anything undocumented. If
> it doesn't exist yet, create it.
>
> For each table/file found, profile it directly with pandas (re-derive, don't assume)
> and document: file name/path, its grain (what one row represents, plain English), and a
> column table (name, dtype, plain-English meaning, null/missing notes). Organize by
> pipeline stage (raw / clean / analysis-mart) once more than one stage exists.
> Documentation only — do not modify or write anything inside `data/raw/` or `data/clean/`.

### 2.1c — ERD (documentation, no cleaning) — reusable, re-run anytime
*Run in an isolated Claude Code session. Bring the result back for review. Mermaid
renders natively on GitHub, so no separate design tool is needed. Written to be re-run
as new tables or keys are added.*
> Scan `data/raw/` and `data/clean/` (if it exists), plus `docs/data-sources.md` and
> `docs/decisions-log.md`, for the current tables and how they actually relate — don't
> assume a fixed set, this prompt gets re-run as the project grows.
>
> If `docs/erd.md` already exists, update it to reflect the current state rather than
> starting over. Otherwise create it, with a Mermaid `erDiagram` code block showing each
> table, its key column(s), and the relationship between tables (one-to-one, one-to-many,
> many-to-many). Base the diagram entirely on whatever tables and keys actually exist
> right now — the specific example below is this project's current shape at time of
> writing, not a required structure (`ipeds_completions_masters` (CIP6) →
> `cip_soc_crosswalk` (the CIP-SOC junction/bridge table, many-to-many) →
> `bls_occupational_openings` (SOC), plus `vanderbilt_current_programs` as currently
> unkeyed pending a CIP-coding decision) — a different project's diagram will look
> nothing like this. If the tables relate through a many-to-many junction/bridge table,
> add 2–3 plain-English sentences above the diagram on what that is and why it's needed
> here. Documentation only — do not modify any data files.

*Lesson: write documentation-generation prompts to scan-and-update rather than hardcode a
file count or term list. A rigid prompt ("these 6 tables," "at minimum these terms")
needs a rewrite every time the repo grows; a scan-and-update prompt gets reused all
project long unchanged.*

### 2.2 — Execute clean + join (only after the 2.1 plan is agreed)
> Following the plan we agreed in 2.1, clean the tables **step by step** — I'm following
> each operation in Data Wrangler (or reading along in this chat), so explain each step,
> don't batch it all silently. Then join and derive the analysis table we agreed on.
> Write cleaned outputs to `data/clean/`, the joined/derived table wherever we agreed it
> belongs, and log the cleaning + join decisions (especially any join rule locked in 2.1)
> in `docs/decisions-log.md`. Explicitly note anything deferred out of this pass, so it
> reads as a deliberate choice later, not a gap someone forgot.

*In practice on this project, the "join and derive" half of this prompt grew into its
own dedicated step and prompt — 2.3 below — once it moved into SQL against a real
database. Use 2.2 for the cleaning pass, 2.3 for the join/derive.*

### 2.2a — Reusable single-table cleaning prompt
*v2, revised 2026-08-01 after all 6 tables were actually cleaned (v1 was written after
just 1 table and was never assumed correct — this revision is what it missed). Works
pasted into Claude Code (full repo context) or a fresh chat with repo access. **Not**
guaranteed self-contained in Data Wrangler's single-table AI chat — see Stage 2 below,
which some tables need and a single-table tool can't do.*
> Clean `{TABLE_NAME}` from `data/raw/` into `data/clean/{TABLE_NAME}_clean.csv`. If
> `docs/decisions-log.md` or `docs/data-dictionary.md` already document known issues for
> this table (rollup/summary rows to filter, suppressed values, mixed-unit columns,
> known unmatched codes), follow those. If not, profile the table yourself first
> (dtypes, nulls, distinct-value counts, a few sample rows) and work out what needs
> fixing from what you actually find.
>
> **Stage 1 — standard single-table checks:** rows that are category totals or header
> rows rather than real records (drop them, and report how many); numbers stored as text
> with commas or currency symbols (strip and cast to float); column names with spaces,
> HTML artifacts, or punctuation that SQL won't accept (rename to snake_case); stray
> punctuation in text values (e.g. a trailing period on every title).
>
> A column mixing units without saying so (e.g. some rows total, some per-credit, some
> "fully funded" or "not reported") needs more than a flag: propose a specific,
> documented conversion rule per case, and get it approved before applying it — don't
> silently pick one interpretation, and don't just flag it and stop either. State which
> rows the rule can't resolve (and why) rather than guessing a value for them.
>
> **Stage 2 — cross-table join-key work (check if this table needs it):** some tables
> can't be fully cleaned in isolation — e.g. deriving a join key that has to match
> another already-cleaned table's format (zero-padding, decimal placement), or dropping
> rows that have no match in a reference table (a crosswalk, a code list). If this table
> needs that, read the other cleaned table(s) it must align with, derive/verify the key
> against them, and report exactly how many rows were dropped/changed and why. This
> stage requires full-repo access — it cannot be done from a single-table tool that only
> sees this one file.
>
> **Not covered here:** assigning a code from an external classification system to a
> program/catalog table (e.g. CIP-coding a university's programs) — that's its own
> prompt, 2.2b, since it needs a different kind of source-verification step.
>
> Explain each cleaning step as you apply it — what changed, how many rows or values
> were affected — don't batch it silently. Before saving, run a verification check: does
> the row count make sense, and did any step silently introduce new missing values that weren't
> there before? Never modify or overwrite anything in `data/raw/`. After saving, say
> whether this table's cleaning involved a judgment call worth adding to
> `docs/decisions-log.md`, or was purely mechanical and doesn't need its own entry.

### 2.2b — CIP-coding a program catalog (reusable — algorithmic shortlist + official-source verification)
*Run whenever a table needs a CIP2020 code assigned per row (e.g., a university's own
program catalog) so it can join into a CIP-keyed pipeline. Works whether or not an
official CIP source exists for the institution — the prompt branches based on what's
found, rather than assuming either way. Uses `scripts/suggest_cip_codes_generic.py`
(the parameterized version of `scripts/suggest_vanderbilt_cip_codes.py`, the worked
example this was built from) for the algorithmic shortlisting stage.*
> I need to assign a CIP2020 code to every row in `{PROGRAM_CATALOG_CSV}` so it can join
> into `{CIP_REFERENCE_CSV}` and the rest of the CIP-keyed pipeline. Do this in three
> stages — don't skip straight to picking codes yourself; every code needs a documented
> source.
>
> **Stage 1 — algorithmic shortlist + tiering.** Edit the CONFIG block at the top of
> `scripts/suggest_cip_codes_generic.py` to point at this project's program-catalog file
> and CIP reference list/crosswalk, then run it. It scores every (program name, CIP
> title) pair by word overlap and a character-similarity ratio, and prints the top 5 CIP
> candidates per program. Treat these as a shortlist, not answers — this step only
> narrows thousands of possible codes down to a handful worth a human look. Split the
> results into two tiers: programs where one candidate clearly scores ahead of the rest
> (a plausible pick), and programs where no candidate stands out (flag as low-confidence,
> no pick yet). Report both tiers back to me as a short triage summary, not a flat
> unranked list — I need to know where my judgment is actually needed, not read every
> row myself.
>
> **Stage 2 — check for an official source before finalizing anything.** Ask me whether
> the institution publishes its own official CIP code list (many university Registrars
> do — check their site, or ask me to look). If one exists: use it to verify or correct
> EVERY row from Stage 1, not just the ones flagged low-confidence. On the project this
> prompt was built from, 4 of 11 "confident" algorithmic picks turned out to be wrong
> once checked against the official source — a clean word-overlap score is not the same
> as a correct answer, so don't skip verification on picks that already look solid.
>
> **Stage 3 — fallback if no official source exists.** If the institution has no
> official list (or a specific program isn't covered by it — e.g. it launched after the
> list's last review date, or has no exact name match), fall back to my judgment on the
> Stage 1 shortlist alone. State explicitly, per program, that this is what happened,
> and carry the same warning forward: an algorithmic "confident" pick is provisional,
> not verified, until a real source confirms it.
>
> For every row, record two things alongside the code itself: the code, and its source
> (`"official"`, `"official (matched via ...)"` if the match required interpretation, or
> `"algorithmic shortlist"` / `"algorithmic/inferred"` if no official source covered it).
> Log the full mapping, the match/mismatch count against any official source found, and
> the reasoning in `docs/decisions-log.md`.

*How to adapt: point `scripts/suggest_cip_codes_generic.py`'s CONFIG block at your own
cleaned program-catalog CSV and CIP-code source (crosswalk or plain CIP list), matching
column names. The three-stage structure doesn't change project to project — only
Stage 2's outcome (official source found or not) branches what the rest of the work
looks like.*

---

### 2.3 — Join/derive: build the analysis mart in SQL (reusable — closes Phase 2)

*Written 2026-08-02, after this step was executed once end-to-end (this project's
worked example: `sql/01`–`05`, `scripts/run_sql_pipeline.sh` — explanations now live in
those files' own inline comments, not a separate walkthrough doc — producing
`derived_candidates`). Needs full repo context plus access to the machine
where the database runs — a sandboxed chat can plan this step but not execute it
against a local database. The verify-the-previous-plan opening earned its place: on
this project it caught three real gaps in an earlier session's otherwise-sound plan
(a distinct-count discrepancy in the catalog-overlap list, floating-point join keys,
suppressed-year trend handling) before any of them could become bugs. The design
itself lives in a standalone spec in the planning folder, written as the analyst's
logic with the SQL as its AI-assisted implementation — so the provenance of the design
is checkable separately from the code.*

> I'm completing the final step of the data-preparation phase of a project that scores
> and ranks candidate options (academic programs, products, market segments — whatever
> this repo's unit of analysis is) toward a decision recommendation: joining the
> cleaned source tables into a single analysis mart. Collection and per-table cleaning
> are already done — read `docs/START-HERE.md` first for orientation, then
> `docs/decisions-log.md` for which design rules are already locked, and the data
> dictionary's Clean section for each table's actual columns, grain, and known gaps.
> Don't carry table names, row counts, join keys, or coverage assumptions over from
> another project — discover them here and verify them against the live files.
>
> The design for this step is mine, documented as a standalone spec in the planning
> folder ({DESIGN_SPEC} — on this project: `docs/planning/phase2-mart-design-spec.md`):
> the mart's construction steps, integrity rules, and target columns. Read it after
> the orientation docs and implement THAT design — but treat it the way you'd treat
> any plan written outside this session: re-check every factual claim in it (row
> counts, distinct-key counts, column names, documented coverage gaps) against the
> actual data, and assess the design itself independently — if you see a better
> construction or a real gap, propose the improvement with your reasoning for my
> approval. Don't silently deviate from the spec, and don't rubber-stamp it either.
> Report what held, what didn't, and what it missed.
>
> Before building anything:
>
> 1. Separate this step's design decisions into already settled (cite the decision-log
>    entry or the design spec) and still-open. For each open one — the mart's grain, any rule for
>    collapsing a many-to-many mapping into per-row metrics, whether sparsely-covered
>    reference data may enter the metrics at all, how the catalog-overlap comparison
>    matches — present the options with tradeoffs and a recommendation. These are mine
>    to approve or reject before you proceed, not defaults to fall back on.
> 2. Propose the mart's target schema: one row per unit of analysis, each column tied
>    to its source table(s) and the exact rule that computes it, including what a NULL
>    in that column will mean.
>
> Execute only after I approve, in SQL against a real database rather than in the
> cleaning language, as numbered, versioned `.sql` files that run in order. The
> database itself is part of the plan, not an assumption — propose what to run this
> on (engine, local vs. hosted, how connection and authentication will work) based on
> what's actually installed on this machine and what the project's docs call for; set
> it up only once that's agreed, and document the connection details. Requirements —
> and for each, state the reasoning so I can verify the choice rather than take it on
> trust:
>
> - Column types that make joins exact: identifier codes stored as text or exact
>   decimals, never floating point. Declare each staging table's primary key so its
>   documented grain is enforced by the database, not assumed.
> - After loading, a verification-check script comparing expected vs. actual — row
>   counts, distinct-key counts, and the *known* imperfections (unmatched codes,
>   documented gaps) pinned as numbers — reported PASS/FAIL, so neither the data nor
>   its flaws can drift silently.
> - Build the mart from the base table outward with join directions that cannot
>   silently drop rows: every candidate row survives; a metric that can't be computed
>   is NULL (unknown), never a fake zero; meaningful zeros stay zeros; and a per-row
>   count records how much source data backs the derived metrics.
> - Independently re-verify at least one row: recompute its derived numbers from the
>   raw source values outside the pipeline and show both results side by side.
> - A deterministic export (stable ordering) so reruns diff cleanly; every mart column
>   documented in the data dictionary; every decision and its reasoning logged in the
>   decision log.
>
> For each technique used (window functions, weighted aggregation, join direction,
> type choices), state the concept and why it applies to this data plainly enough that
> I can check the choice myself — assume every claim will be independently verified
> before it's accepted. Flag anywhere the data is ambiguous or the reasoning is
> uncertain instead of smoothing it over with confident language.

*How to adapt: the prompt deliberately names no tables, counts, or institutions — the
repo docs it points at carry all of that, which is what makes it portable. The real
dependencies are (a) that the orientation doc, decision log, and data dictionary exist
and are current — a project without them needs those first (prompts 2.1a–c) — and
(b) the design spec, which is per-project and written by the analyst *before* this
prompt runs: the prompt implements and stress-tests a documented design, it does not
invent one from scratch. The SQL dialect and database engine are also unspecified —
Postgres here, but choosing them is part of the prompt's own plan step.
Outcome on this project: `derived_candidates`, 1,268 rows, decisions in
`decisions-log.md` 2026-08-02.*

---

## Phase 3 — SQL analysis & scoring

### 3.1 — Score and rank the analysis mart (reusable)

*Continues from 2.3's output, in a fresh chat — this is genuinely new analysis work, not
a continuation of data prep. Framed for verification, not learning: every claim needs
stated evidence, since the point is that it can be independently checked, not taken on
faith. Environment note: if the mart lives in a local database, a sandboxed chat can
profile the exported CSV and draft the queries, but running SQL against the live
database happens on the machine that hosts it.*

> I'm turning the analysis mart from a project that scores and ranks candidate options
> (academic programs, products, market segments — whatever this repo's unit of analysis
> is) into an actual composite score and a banded recommendation (e.g. Go/Test/Pass, or
> whatever categorical verdict this project uses). Data collection, cleaning, and the
> join/derive step are already done — read `docs/START-HERE.md` first for orientation,
> then the most recent relevant entries in `docs/decisions-log.md`, and the data
> dictionary's Analysis Marts section for the mart's actual columns and grain. Don't
> carry over another project's column names, row counts, or metrics — discover and
> verify this project's own.
>
> **Don't build anything yet — profile the mart first and present a plan.** For every
> claim or recommendation, state the evidence behind it (the actual numbers found by
> querying/profiling, not a general description) — assume I will independently check
> each one before accepting it, and don't move to the next step until the reasoning for
> the current one is stated plainly enough for me to verify it myself.
>
> 1. Identify the mart's actual metric columns and report their real distributions —
>    min/max/median/percentiles — and null counts per column with a plain-language
>    reason for each null pattern found (e.g. "no match in a reference table,"
>    "insufficient historical data"). Discover and report this project's real numbers;
>    don't assume which columns matter or how many rows are affected.
> 2. Propose a normalization method for putting these metrics onto comparable scales,
>    given whatever mix of units they actually turn out to be. State the tradeoffs of
>    each option considered and why one is recommended over the others.
> 3. Propose composite-score weights, with reasoning for each weight spelled out. This is
>    my decision to approve or reject, not a default to finalize on your own.
> 4. State exactly how every null pattern found in step 1 is handled in the score, and
>    defend that choice against at least one alternative (excluding affected rows vs.
>    scoring on partial data vs. a neutral placeholder), rather than picking one silently.
> 5. Only after the score is computed, report its actual distribution and propose band
>    cutoffs from that real distribution — not round numbers decided in advance.
>
> Flag explicitly anywhere the data is ambiguous or the reasoning is uncertain, rather
> than smoothing over it with confident-sounding language. Discuss and agree on the plan
> first; execute only after I approve it.

*How to adapt: the prompt names no columns, weights, or cutoffs — the data dictionary
and the mart itself carry all of that, discovered fresh each run. The real dependency is
that the mart already exists with documented columns; a project without one needs 2.3
first. Outcome on this project: method locked and scored 2026-08-05 — see
`docs/decisions-log.md`'s 2026-08-05 entries. Cutoffs (step 5) ended up needing their own
follow-up prompt, `3.3` below, once the score actually existed.*

### 3.2 — Independently verify a scoring findings report (reusable)

*Continues from 3.1's output — run in a separate notebook/session so the check isn't
influenced by the same reasoning that produced the report. Framed for verification:
recompute from the raw data, never from the report's own numbers, and report
MATCH/MISMATCH explicitly rather than adjusting silently. Outcome on this project:
`notebooks/phase3_ai_report_verification.ipynb`, every claim in
`docs/planning/phase3-scoring-findings.md` matched on first run.*

> Read {FINDINGS_REPORT} (the report to verify) and {DATA_FILE} (the underlying data it
> was computed from). Recompute every numeric claim in the report directly from
> {DATA_FILE} — never assume the report's own numbers are correct.
>
> Build a notebook, one claim per section, that: states the claim from the report in a
> markdown cell; computes it independently from {DATA_FILE} in the next cell; and
> reports MATCH or MISMATCH explicitly, not just a number left to speak for itself.
>
> Cover at minimum: every distribution statistic named in the report for each numeric
> column, null/missing counts per column including any overlap the report claims
> between them, and any other specific number stated as fact (row counts, correlation
> coefficients, category breakdowns). For a normalization or methodology recommendation
> specifically, don't just recompute the summary statistic — demonstrate the tradeoff
> empirically on a few real, representative rows so the claim is visible in actual
> output, not taken on faith.
>
> Explain each technique in a short note the first time it's used, at whatever depth
> matches who's actually going to read this. End with a summary table built from the
> individual checks (claim | report's value | notebook's value | match) rather than
> retyped by hand, and flag anything that doesn't match rather than adjusting the report
> to fit.

*(Each verification-check section in the resulting notebook also carries its own small
"starter prompt" — a claim-scoped, adaptable version of this same idea — for anyone who
wants to regenerate or adjust a single check rather than the whole notebook. Those live
inline in the notebook itself, not here.)*

### 3.3 — Derive band cutoffs from a real score distribution (starter prompt)

*Continues from 3.1/3.2, once a composite score exists on every row. A checklist-style
starting point for deriving categorical bands from a continuous score as a sequence of
standalone, checkable queries rather than one script written all at once — each step
verifiable on its own before it's folded into the final file. Outcome on this project:
`sql/08_score_bands.sql`, cutoffs at the 90th percentile and the median (the
distribution had no natural break), band counts 126/502/626.*

> Derive [Go/Test/Pass, or whatever categorical bands this project uses] cutoffs from
> the real score distribution on [the scored table]. Work through this as a sequence of
> standalone, checkable queries:
>
> 1. Define the population — which rows actually belong in this analysis, and why that
>    has to be settled before computing any statistic.
> 2. Five-number summary + a spread of percentiles (10th/25th/75th/90th/95th/99th) on
>    the score column.
> 3. Sanity-check the extremes — pull the actual top and bottom rows by score, not just
>    the summary numbers.
> 4. Look at the shape — bucket the score into ranges and count rows per bucket. Is
>    there a natural cliff/gap, or is the distribution smooth?
> 5. Set the cutoffs: cite a real break if one exists; if the distribution is smooth,
>    use a named, defensible convention instead (e.g. top-decile / median split) rather
>    than an invented number, and say plainly that's what's happening.
>
> Consolidate into one clean, well-commented SQL script once all five hold up
> individually, matching this repo's existing CTE-per-step style. Log the final cutoffs
> and the reasoning in the decision log, cited against the real numbers from step 2–4.

*How to adapt: names no specific bands, table, or column — works for any categorical
banding decision once a continuous score exists. The core reusable part isn't the SQL,
it's the four-step framework and the "teach one step at a time" pacing.*

### 3.4 — Cluster near-duplicate titles within a shortlist (starter prompt)

*Continues from 3.1–3.3, once a shortlist of scored candidates exists. Groups
near-duplicate entries (same real program, different code) as a first pass for human
review — not a final answer.*

> Given a CSV of shortlisted candidates (code + title + score), write a script that
> groups titles likely to represent the same real program under different codes, as a
> first pass for human review.
>
> 1. Score every pair of titles by (a) count of shared significant words after removing
>    generic terms (degree types, "general," "other," etc.) and (b) a character-level
>    similarity ratio as a secondary signal.
> 2. Pick a conservative threshold for what counts as "linked" — validate it against a
>    sample before trusting it. A softer rule (fewer shared words plus a high similarity
>    ratio) is prone to false positives on short, generically worded titles, which can
>    chain unrelated items into one oversized cluster through transitive grouping —
>    check for this failure mode specifically before trusting the result.
> 3. If the codes carry a hierarchical structure (e.g. a shared prefix), use it as an
>    independent, authoritative signal alongside text similarity — it catches
>    near-duplicates that text alone might miss or wrongly merge.
> 4. Group linked titles into clusters (e.g. via union-find / connected components).
> 5. Export the original data with a cluster ID column added, sorted by cluster, for
>    manual review.

*How to adapt: swap the CSV path and column names; adjust the "generic terms" stopword
list to your domain; tune the linking threshold against a sample of your own data
rather than assuming a fixed number will transfer.*

## Phase 4 — Tableau dashboard

### 4.1 — Build a dashboard's CSV extracts from a locked design spec (starter prompt)

*Continues from the scoring/analysis phase, once a BI dashboard's content is already
designed and locked — this prompt is not for deciding what the dashboard shows, only
for building the data behind it. Assumes the design already exists as its own written
spec, same pattern as 2.3: the design is the analyst's, documented separately, and this
prompt implements and stress-tests it rather than inventing one. Tableau Public
specifically can't connect live to a database, so every dashboard needs its data
pre-extracted to CSV regardless of how the design decisions got made — a different tool
(Power BI, Looker, a live Tableau Server connection) might not need this step at all.*

> I'm building the CSV extract(s) a BI dashboard will read directly. The dashboard's
> content and structure are already locked in {DESIGN_SPEC} — read it first, along with
> {DECISION_LOG} for the reasoning behind it. Don't invent or adjust the design here;
> implement exactly what's specified, and treat every factual claim in the spec (column
> names, expected row counts, filter logic) the way you'd treat any plan from outside
> this session — verify it against the live database rather than assuming it's still
> accurate.
>
> Write one numbered SQL file (matching this repo's existing style: numbered steps, a
> preview `SELECT` before each export, comments explaining why each step exists) that
> produces every extract the spec calls for. For each extract:
>
> 1. State the expected row count and what population/filter defines it, before writing
>    the export — something to check the actual result against, not just eyeball after
>    the fact.
> 2. If the extract needs a value that doesn't already exist on any table (a label, a
>    flag, a name mapped from a small fixed list), build it as its own small lookup
>    table joined in — not hardcoded inline across the query — so the mapping is
>    visible and reusable in one place.
> 3. If the extract could plausibly have missing rows (a filtered date range, a category
>    that isn't guaranteed complete), check for gaps before exporting: build the full
>    expected combination set and compare it against what actually exists, rather than
>    just reporting a row count that came in lower than expected. If gaps are found,
>    work out whether the cause is a real, explainable pattern (e.g. a category that
>    didn't exist yet for part of the date range) or a genuine data-quality problem, and
>    say which it looks like and why.
>
> Run every export against the real database and report the actual row counts back
> against what step 1 predicted — don't assume a query is correct just because it ran
> without an error. Don't commit or push anything.

*How to adapt: names no tables, columns, or extract count — the design spec (written
per-project, before this prompt runs) supplies all of that. The gap-check step (3) only
applies when an extract could plausibly be incomplete; skip it for extracts where
completeness isn't in question. Outcome on this project: `sql/11_dashboard_extracts.sql`,
two extracts — a 1,254-row scored population and a 49-row completions trend (16 of an
expected 65 rows missing, traced to two CIP codes with no completions data anywhere
before 2020, consistent with them being new codes added in the CIP2020 taxonomy
revision rather than a data-quality problem).*

## Phase 5 — One-page recommendation — *placeholder*
