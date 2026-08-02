# AI Prompts Log

The prompts used to build this project, in run order. Each entry is the cleaned-up
version that actually worked — not the messy first draft. Numbered by phase (0, then
1.1, 1.2 …) so the sequence is obvious; run them top to bottom.

> **⚠️ Before publishing (project-end polish — PARKED, do not forget):**
> 1. **Tone** — rewrite every prompt in a professional, "replicate this work" voice.
>    Remove any "teach me / I'm learning / walk me through" language. That's fine while
>    building, but the final artifact a hiring manager reads should read like a
>    methodology, not a lesson.
> 2. **Reusability** — templatize. Replace the specific university, sources, and numbers
>    with placeholders (`{UNIVERSITY}`, `{PROBLEM_STATEMENT}`, `{DATA_SOURCES}`) and add a
>    short "how to adapt this to another school/sources" note, so someone else can run the
>    same method on their own case without reading the whole history. (Standard approach:
>    parameterize the prompts + a one-page adapt guide.)

---

## Phase 0 — Kickoff

### 0.1 — Create the project
> I found a Data Analyst job description at a university — a market-research role that
> assesses whether and which new online / professional programs the university should
> launch. Build a data-analysis project modeled on that role. Read the JD for context,
> act as the office's director, and propose the problem statement the role would actually
> answer. Then scope a realistic end-to-end project around it (collect → clean → SQL →
> visualize → recommend).

---

## Phase 1 — Data collection

### 1.1 — Source exploration (report-first)
> Context: a project deciding which new online graduate program the university should
> launch, by comparing fields on labor-market demand, national student demand / market
> size, and competition. The university's current online catalog is in
> `data/raw/vanderbilt_current_programs.csv`; the problem statement is in
> `docs/landscape-scan.md`.
>
> Explore the data landscape — do NOT pull full datasets, just report what's available
> and how to get it:
> 1. BLS Employment Projections (fastest-growing / most-openings tables).
> 2. IPEDS completions by CIP (datausa.io API + nces.ed.gov/ipeds).
> 3. Program aggregators (US News / OnlineU) for online-program pricing.
>
> Then use your judgment — flag any other credible source relevant to the problem
> (including a replacement for Google Trends, which is unreliable). Return a short report
> per source (what data, format, how to pull, how it feeds the analysis) and recommend
> the best 2–3 datasets to build on.
>
> For every source, confirm it's actually reachable with one small live test call before
> writing it into the report — don't take a source's reputation on faith. Note which
> access method actually worked: some government sites (e.g. bls.gov) block plain HTTP but
> scrape cleanly via Firecrawl; ranking/aggregator sites should have their exact URL
> confirmed by search, never guessed from the slug pattern.

### 1.2 — Validate the recommendation against the decision
> Before pulling any full dataset, stress-test the sources recommended in 1.1 against
> the actual decision — not just whether each is topically related, but whether it
> measures the right variable at the right granularity for *this* decision, and whether
> the resulting tables can actually be joined once collected.
>
> Two concrete failure modes to check for, not just acknowledge in the abstract:
> - **Granularity/fit-for-purpose gaps.** A source can be directionally on-topic but
>   silently wrong for the decision — e.g. IPEDS grad tuition data is by CIP code and
>   university, but not broken out by delivery mode (online vs. in-person), so it can't
>   be the primary "online competitor pricing" source even though it looks like a clean,
>   scrape-free substitute for one.
> - **Fragile dependencies.** Anything with no official client, an unofficial/reverse-
>   engineered API, or known rate limits should be live-tested now, not assumed to work
>   — e.g. Google Trends failed with a 429 the moment it was actually queried, despite
>   being the originally planned source.
>
> Also confirm the join path: name the bridge/crosswalk table needed to connect the
> recommended sources on a shared key, and flag it as a pull item if it isn't already on
> the list. End by locking a single, final list of exactly what gets collected in the
> next step — a failure caught here is cheap; one discovered mid-pull means coming back
> for another table later.

### 1.3 — Data collection, broad pull (only after 1.2 locks the list)
> Read the whole repo for context first (`README.md`, then `docs/`, then `data/raw/` and
> `scripts/`).
>
> Candidates are NOT pre-chosen — they must be DERIVED from the data. Pull the structured
> sources needed to derive and rank them; save clean raw files to `data/raw/` and log each
> in `docs/data-sources.md`:
> 1. BLS Employment Projections — Table 1.10 (openings, all occupations) + Tables 1.3/1.4
>    (fastest-growing, most new jobs). SOC-keyed.
> 2. IPEDS completions by CIP via datausa.io — masters, multi-year. CIP-keyed.
> 3. NCES CIP↔SOC crosswalk — to join BLS (SOC) ↔ IPEDS (CIP) later.
>
> Do NOT pull competitor pricing yet — it needs a per-field URL per program, and the
> programs aren't known until the data derives them (a later, per-candidate pull). Flag,
> don't pull, any other useful source. Deliver a short report: what you pulled, each
> table's schema + row counts, data-quality issues, and how the tables join on CIP/SOC.

*Lesson: when a report ends with a multi-item pull-list, restate the proposed execution
order explicitly before running it — sequencing across a multi-source pull is a judgment
call, not a default to assume. (This got corrected mid-session: the AI proposed collecting
2 of 3 approved sources first and holding the third; the right call was all three
together.)*

### 1.4 — Demand-direction signal (Google Trends replacement)
> Google Trends is the planned search-interest signal, but confirm it's still failing
> before assuming so (it was 429-rate-limiting at last check). If it is: research and
> live-test alternatives — a page-view API (e.g. Wikipedia Pageviews), a job-posting-
> volume feed (e.g. Indeed Hiring Lab's public index), a news-volume/sentiment API (e.g.
> GDELT, or a connected trend-aggregator MCP if one's available) — one small test call
> per candidate, not a full pull. Compare them on: cost/rate-limits, what signal they
> actually give (search interest vs. hiring volume vs. news attention — these are
> different things, not interchangeable), and how cleanly the response converts to a
> tidy table. Recommend a primary + optional secondary; don't default to the first one
> that works.
>
> If the source is queried per-topic rather than pulled in bulk, hold the actual pull
> until candidates are derived (Phase 2) — collecting data and choosing *which* source to
> use are two different decisions; don't collapse them into one step.

### 1.5 — Inspect & explain a collected file
*New pattern, not tied to a single source — use this any time a collected file's purpose
or structure isn't self-evident (a crosswalk, a lookup table, an opaque ID scheme), before
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
> `docs/landscape-scan.md`, `docs/data-sources.md`.
>
> We're starting Phase 2, and I want to do EDA first — understand the data before any
> cleaning. Act as my senior analyst: profile the tables, explain what you find in plain
> terms, and discuss the decisions with me. **Do NOT clean, join, or write any files
> yet.** The 6 raw tables are in `data/raw/`.
>
> Step 1 — Profile each table and report back: shape (rows × cols), columns + data types,
> a few sample rows, null/missing counts, and distinct-value counts for key columns.
> Confirm the known gotchas live in the data: BLS Table 1.10 category rollups vs
> `Line item`; IPEDS suppressed (missing) years; CIP↔SOC crosswalk many-to-many.
>
> Step 2 — Discuss the plan with me (don't execute): what's messy in each table and what
> cleaning it needs; how to handle the many-to-many CIP↔SOC join (walk me through the
> options and trade-offs); and what the final joined "analysis" table should look like —
> its columns and its grain (one row per what?). Explain the concepts as they come up
> (keys, grain, join cardinality, schema) so I actually learn them.
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
> — but make sure these are covered if they appear anywhere in the repo: CIP / CIP6, SOC,
> the CIP↔SOC crosswalk / junction (bridge) table, ODP, IPEDS, BLS, "Line item" vs
> "Summary", Go/Test/Pass, grain, join cardinality, staging vs. mart tables, TAM, ERD,
> Mermaid, CRISP-DM (if referenced elsewhere in the docs).
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
> many-to-many) — e.g. right now: `ipeds_completions_masters` (CIP6) → `cip_soc_crosswalk`
> (the CIP-SOC junction/bridge table, many-to-many) → `bls_occupational_openings` (SOC),
> plus `vanderbilt_current_programs` as currently unkeyed pending a CIP-coding decision.
> Above the diagram, add 2–3 plain-English sentences on what a junction/bridge table is
> and why the crosswalk plays that role here. Documentation only — do not modify any
> data files.

*Lesson: write documentation-generation prompts to scan-and-update rather than hardcode a
file count or term list. A rigid prompt ("these 6 tables," "at minimum these terms")
needs a rewrite every time the repo grows; a scan-and-update prompt gets reused all
project long unchanged.*

### 2.2 — Execute clean + join (only after the 2.1 plan is agreed)
> Following the plan we agreed in 2.1, clean the tables **step by step** — I'm following
> each operation in Data Wrangler, so explain each step, don't batch it all silently.
> Then join and derive the candidates. Write cleaned outputs to `data/clean/`, a
> `derived_candidates` table, and log the cleaning + join decisions (esp. the crosswalk
> rule) in `docs/decisions-log.md`. Deferred: competitor pricing, search-trend.

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
> were affected — don't batch it silently. Before saving, sanity-check: does the row
> count make sense, and did any step silently introduce new missing values that weren't
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

## Phase 3 — SQL (BigQuery or Postgres) — *placeholder*
## Phase 4 — Tableau dashboard — *placeholder*
## Phase 5 — One-page recommendation — *placeholder*
## Phase 6 — Rehearse the project story — *placeholder*
