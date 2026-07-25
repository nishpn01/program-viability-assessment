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

### 1.2 — Data collection, broad pull (data-first)
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

### 1.3 — Search-trend / market signal — DEFERRED (placeholder)
*Belongs to Phase 1 but runs AFTER Phase 2 (it needs the derived candidates first, since
it's queried per program). Optional — IPEDS multi-year completions already gives the
demand trend; this would add search-interest / market buzz. Prompt to be written when we
get there.*

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

### 2.2 — Execute clean + join (only after the 2.1 plan is agreed)
> Following the plan we agreed in 2.1, clean the tables **step by step** — I'm following
> each operation in Data Wrangler, so explain each step, don't batch it all silently.
> Then join and derive the candidates. Write cleaned outputs to `data/clean/`, a
> `derived_candidates` table, and log the cleaning + join decisions (esp. the crosswalk
> rule) in `docs/decisions-log.md`. Deferred: competitor pricing, search-trend.

---

## Phase 3 — SQL (BigQuery or Postgres) — *placeholder*
## Phase 4 — Tableau dashboard — *placeholder*
## Phase 5 — One-page recommendation — *placeholder*
## Phase 6 — Rehearse the project story — *placeholder*
