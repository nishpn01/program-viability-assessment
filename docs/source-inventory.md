# Source Inventory — what data each source actually offers

*Verified live on 2026-07-23 (small test queries only — no full datasets pulled yet).
Endpoints, cube names, and URL patterns below were confirmed working, not guessed.*

## 1. BLS — labor demand (bls.gov)

| Dataset | What it gives | Format | Use |
|---------|---------------|--------|-----|
| Occupational Outlook Handbook (OOH) | Per-occupation median pay, 10-yr growth %, jobs, entry education | Web page (scrape) | Already pulled for 12 occupations → `data/raw/bls_labor_demand.csv` |
| **Employment Projections — Table 1.10** (`bls.gov/emp/tables/occupational-separations-and-openings.htm`) | **Annual average occupational openings** (the real "how many jobs open up a year" number — separations + growth, not just net employment change), for every SOC occupation at once | HTML table (confirmed scrapable) **or** one XLSX download (`bls.gov/emp/ind-occ-matrix/occupation.xlsx`) covering ~800 occupations in one file | Better labor-demand metric than OOH's "employment change" — captures replacement demand too. One pull covers every candidate, no per-occupation scraping needed |
| Employment Projections — Tables 1.3 / 1.4 | Pre-ranked lists: fastest-growing occupations, most new jobs | Same XLSX/HTML | Lets the labor market *nominate* candidates instead of only scoring a hand-picked list |
| OEWS | Wages + employment by occupation **and by state/metro** | Downloadable XLSX | Only needed later if a state/metro map chart is added |

## 2. IPEDS — national market size (nces.ed.gov/ipeds, via datausa.io API)

**Confirmed live**, no API key required: `https://api.datausa.io/tesseract/data.jsonrecords`

| Cube | What it gives | Confirmed dimensions | Use |
|------|---------------|----------------------|-----|
| `ipeds_completions` | Completions by CIP code, year, degree level, nationally | `CIP2/CIP4/CIP6`, `Year`, `Degree` (Masters = ID 7), `Geography`, `Sector` | **Student demand / market size** — this is the `student_demand.csv` audience-sizing signal, straight from source, no scraping |
| `ipeds_tuition_by_cip` | Grad-student tuition & fees **by CIP by university** (in-state/out-of-state/published) | `CIP`, `University`, `Year` | Scrape-free alternative/cross-check for competitor pricing — **but not by delivery mode** (see gotcha below) |
| `onet_by_cip` | O\*NET skill importance linked to CIP codes | `CIP`, `Skill Element`, `Year` | Nice-to-have: ties a program's field to in-demand skills; not required for the core 3 tables |

Sample verified: `?cube=ipeds_completions&drilldowns=CIP2,Year&measures=Completions` returned real multi-year national totals (e.g., Agriculture completions 2012–2021) on the first try.

> IPEDS Data Center's manual CSV export is the fallback if datausa.io ever lags a data
> refresh, but the API is clean enough that manual export shouldn't be needed.

**Gotcha:** `ipeds_tuition_by_cip` gives grad tuition by CIP and university, but does
**not** distinguish online vs. in-person delivery. It's tempting to use it as a scrape-
free stand-in for competitor pricing, but a university's on-campus and online tuition
for the same CIP can differ — this cube can't tell them apart, so it can't be the
*primary* online-competitor-pricing source. Treat it as a cross-check/sanity-check
alongside a delivery-mode-aware source (e.g. per-field online rankings), not a
replacement for one.

## 3. Competitor pricing / program aggregators

| Source | What it gives | Format | Verified? |
|--------|---------------|--------|-----------|
| US News Online Rankings (per-field pages, e.g. `usnews.com/education/online-education/mba/online-business-analytics-rankings`) | Ranked list of online programs per specialty: rank, tuition **per credit**, enrollment, public/private | Web page (scrape) | **Yes** — guessing the URL slug 404s into nav-only boilerplate; the correct per-field ranking URL (found via `firecrawl search`, not guessed) renders the full table cleanly |
| OnlineU | Similar program + tuition listings | Web page (scrape) | Not independently verified this pass — worth a spot-check if US News coverage is thin for a given field |

**Gotcha:** don't hand-guess US News URLs — the slug pattern isn't obvious (it's
`/{degree}/online-{specialty}-rankings`, not `/{specialty}-masters`). Use `firecrawl
search` per candidate field to find the real ranking-page URL, then scrape that.

## 4. Not requested, but worth flagging

| Source | What it gives | Format | Why it matters |
|--------|---------------|--------|-----------------|
| **College Scorecard API** (`api.data.gov/ed/collegescorecard/v1`) | Program-level (CIP + credential level, per institution) **earnings and debt outcomes**, plus completions | Free JSON API — confirmed live with `DEMO_KEY`, no signup strictly required for light testing (a real key is one-click free for sustained use) | The one source that answers "if a student completes *this* program, what do they actually earn?" — an ROI angle none of BLS/IPEDS/aggregators give directly. Bridges labor-market payoff to the program level instead of the occupation level |
| Google Trends | National search interest by term, 5-yr trend | `pytrends` / manual export | Already the planned `student_demand.csv` search-interest layer per `docs/project-brief.md` — not new, just confirming it's still the right call, no live check done this pass |

## The join gotcha (flag now, fix in Phase 2 cleaning)

BLS tables key on **SOC occupation codes**; IPEDS/datausa/Scorecard key on **CIP program
codes**. They don't share a code system. NCES publishes an official CIP↔SOC crosswalk
(`nces.ed.gov` — "CIP to SOC crosswalk") — plan to pull that alongside the three main
tables so the `candidate_program` bridge key in Phase 2 cleaning can actually connect
labor demand to completions/tuition, instead of relying on manual field-name matching.

## Recommendation — best 2–3 datasets to build on

1. **BLS Employment Projections Table 1.10** (+ 1.3/1.4 for candidate nomination) —
   one structured pull, every occupation, the correct "openings" metric.
2. **datausa.io `ipeds_completions`** (Degree = Masters) — clean public API, no
   scraping fragility, directly the market-size/audience number the TAM assumption needs.
3. **datausa.io `ipeds_tuition_by_cip`** as the primary pricing source, with US News
   per-field rankings (via `firecrawl search`, not guessed URLs) as the enrichment layer
   for ranking/enrollment context that IPEDS tuition data doesn't carry.

This leans the pipeline toward **two free structured APIs doing the heavy lifting** and
scraping only for the one thing APIs can't give (program *rankings*), which is the more
robust build for a project on a 2–3 session timebox.

## Claude Code exploration prompt

Lives in `docs/ai-prompts-log.md` → **Phase 1 — Source exploration** (kept with all the
other prompts so they're in one place).
