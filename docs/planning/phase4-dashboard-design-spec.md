# Phase 4 — dashboard design spec: new-program opportunity dashboard

*Pranish's design for the Phase 4 Tableau dashboard, drafted during Phase 4 planning
(2026-08-08/09) and reconciled against two independent reads of the same design
literature: Claude's review of *Storytelling with Data* and *The Big Book of
Dashboards*, and Pranish's own parallel read of the same two books via NotebookLM. Both
landed on close to the same structure without coordinating, which is most of why it's
locked here instead of argued over further. The Tableau build in the next step
implements this spec; it doesn't invent the layout while building. Lives in
`docs/planning/`, public alongside the rest of that folder.*

## Objective

One integrated Tableau dashboard that makes the case for one of five finalist programs
to the ODP director — not five charts sitting in a folder, and not four separate
dashboards, one per metric. Built on the Phase 3 output: `scored_candidates.csv`,
`derived_candidates.csv`, and `ipeds_completions_masters_clean.csv`.

## The scenario

Big idea, one sentence: five programs cleared Vanderbilt's bar for a new online launch
out of 1,254 real candidates — this dashboard shows which one is strongest, why, and
how close the field actually is.

Audience: the ODP director, opening this with no one in the room to narrate it, so the
dashboard has to carry its own context instead of leaning on a live presenter. The
scoring model already answered "is there a case." This dashboard answers "show me the
case."

## Structure — three tiers

Built around Shneiderman's mantra — overview first, zoom and filter, details on
demand — instead of four equally-weighted boxes with no hierarchy between them.

**Overview.** A row of four numbers: composite score, annual openings, completion
volume, growth trend percent. Bound to the finalist filter below — nothing selected,
the row shows the top-ranked finalist's numbers by default; pick a different finalist
and the row updates to that program's numbers. Underneath it, a ranked bar chart of the
five finalists by composite score. Bar length carries the size of the gap between them,
not just the order: Data Science General is #1, but the real story is how much
stronger its case is than the next one down.

**Zoom.** Two charts, each pulling one pair of raw metrics back out of the blended
composite score so the number isn't a black box. First, a scatter of national
completions against national openings across the full Go/Test/Pass population (1,254
candidates), gray, with the five finalists highlighted in their own colors — the size
half of the score, 60 percent of the weight, shown as an actual spread instead of one
blended figure. Second, a score-distribution strip plot across that same population,
with the Go, Test, and Pass bands shaded behind it at their real cutoffs (Go at 75.3,
Test at 45.7) and the five finalists labeled — the chart that makes the top-decile
convention visible instead of asserted in a footnote.

**Details on demand.** Hovering or clicking a finalist's bar in the ranked chart
surfaces the five weighted pillars behind that program's score (completions level,
completions trend, labor openings, labor growth, the BLS top-30 flag) as a tooltip, not
a fifth permanent chart. The one element that still earns its own chart slot is the
completions trend line, 2012 to 2024, finalists only — durability over time doesn't
show up anywhere else on the dashboard.

## Filters

Two, not one.

**Select finalist** — a parameter, not a plain quick filter, because it has to drive
the KPI row and the highlight color across data sources that don't share a physical
join in Tableau (the Go-band extract and the trend extract). A parameter plus one
calculated field per extract is the standard way to synchronize a single control across
data sources with no common key.

**Labor-signal corroboration** — a toggle on `in_bls_top30_flag`, already one of the
five locked scoring pillars. Replaces an earlier idea, a Credential Level filter, that
turned out to have nothing behind it: every one of the 1,254 candidates is Master's-level
only by design, since the IPEDS pull was scoped to Degree = Masters back in Phase 1.
Nothing to filter there.

## Color

One fixed color per finalist, the same five colors on every chart they appear in, so a
specific program stays traceable across the whole dashboard instead of just reading as
"highlighted" versus "not." Everything else in the field is gray. The Go/Test/Pass band
shading in the distribution chart is a separate use of color, background fill rather
than data-point fill, so it doesn't compete with the finalist colors for the same
channel.

## Data extracts

Two, not three like the earlier draft had it, once the pillar breakdown moved into a
tooltip instead of its own chart.

**Extract A** — the full Go/Test/Pass population, one row per candidate:
`cip2020_title`, `score`, `band`, `employment_weighted_openings`,
`employment_weighted_growth_pct`, `completions_latest_year`, the five `pct_*`
percentile columns from `scored_candidates`, `in_bls_top30_flag`, and an `is_finalist`
flag with the proposed program name filled in for the five. Feeds the KPI row, the
ranked bar, both zoom charts, and both filters.

**Extract B** — `completions` by `year`, 2012 through 2024, the five finalist CIP6
codes only, pulled from `ipeds_completions_masters_clean.csv`. Feeds the trend chart
alone.

## Explicitly not doing this pass

**A School/College filter.** Real idea, raised back in Phase 3 (2026-08-08 journal
entry, noticing three of the five finalists are tech-adjacent), but it needs a manual
Vanderbilt college/school mapping for all 1,254 candidates that was never collected —
new data work, not a dashboard decision. Stays parked.

**Color-coding finalists by tech-adjacent versus non-tech.** Considered directly,
declined. The identity-color channel is already spoken for; loading a second meaning
onto the same channel is close to the "misuse of color" mistake both design sources
call out by name.

**Four separate single-metric dashboards.** Considered and rejected early. The point of
a composite score is that the metrics interact — a program can be high on labor demand
and flat on student interest — and that only shows up if the numbers sit in one place
together.

## Open, going into the build

Exact Tableau canvas layout (horizontal preferred over the vertical NotebookLM mockup)
gets settled in the build step, not here — this spec fixes what goes on the dashboard
and why, not pixel placement. Whether the KPI row should default to the #1 finalist or
to an average across all five is worth a second look once the row actually exists and
can be looked at, not decided from a description alone.

## Build reconciliation (2026-08-19)

Three points where the shipped dashboard differs from what's locked above.

**Details on demand.** The spec calls for the five weighted pillars to surface as a
hover tooltip on the ranked bar, not a permanent chart. The build instead added a
fifth, always-visible element — a comparison table showing all five pillars and the
final score for all five finalists side by side. Decided during the build: a static,
inspectable breakdown holds up better under scrutiny than a tooltip a viewer might not
think to check.

**Filters.** Two were locked: Select Finalist and Labor-Signal Corroboration. Five
shipped: Select Finalist, Band, an annual-openings range, a national-completions
range, and Year. Labor-Signal Corroboration, one of the two originally locked, was not
built this pass — deferred, not dropped.

**KPI row default.** The spec left open whether the KPI row should default to the
top-ranked finalist or an average across all five. Resolved during the build: it
defaults to the top-ranked finalist.
