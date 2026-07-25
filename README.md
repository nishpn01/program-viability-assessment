# Program Viability Assessment

**Which new online program should a university launch next?**
A market-research analysis that scores a set of candidate programs on labor-market
demand, competitive landscape, pricing, and audience size, then ranks each
**Go / Test / Pass** with one clear "launch next" recommendation.

Modeled on the work of a higher-education market-intelligence analyst (the Vanderbilt
Office of the Deputy Provost Data Analyst role): turn scattered public market signals
into one decision leadership can act on.

---

## The question

Of the graduate fields a university does **not** already offer online, which are the
strongest launch opportunities? (Working case: Vanderbilt University — current online
catalog verified in `docs/landscape-scan.md`.)

## Candidates

The programs to evaluate are **derived from the data, not pre-picked** — fields that are
in-demand (BLS) and have a real national student market (IPEDS) but that Vanderbilt does
not offer online. How they're derived: `docs/landscape-scan.md`.

## The three signals

1. **Labor-market demand** — do the jobs exist, grow, and pay? (BLS)
2. **Competition & pricing** — how saturated, and at what tuition? (competitor programs)
3. **Student demand / audience** — interest and market size? (Google Trends + IPEDS)

## Pipeline

```
Collect              →   Clean          →   SQL                →   Tableau        →   Recommendation
Firecrawl + Python       pandas             BigQuery / Postgres     dashboard          1-page SCQA
scrape the sources       tidy the tables    join / rank / aggregate  4 charts+filter    Go/Test/Pass
```

## Repo structure

| Path | What lives here |
|------|-----------------|
| `data/raw/` | Source tables as collected, **never edited after collection** |
| `data/clean/` | Analysis-ready tables (typed, standardized) |
| `scripts/` | Collection + parsing scripts (reproducible) |
| `notebooks/` | Cleaning notebook |
| `sql/` | The join / window / aggregation queries |
| `dashboard/` | Tableau workbook + exported chart images |
| `docs/` | Problem statement, provenance, decisions, and the final recommendation |

## Data sources (all public, all free)

- **BLS Occupational Outlook Handbook** — wages, growth, jobs per occupation
- **Competitor program pages** — tuition, credits, duration, format
- **Google Trends** — 5-year search-interest trend
- **IPEDS** — program completions as an audience-size proxy

## Method note

Data is collected with AI assistance: Firecrawl scrapes the public sources and Python
parses them into tidy tables. Every source is logged in `docs/data-sources.md`, and the
collection scripts live in `scripts/`, so the dataset is fully reproducible. The
analytical design, judgment, and recommendation are my own.

---

*A portfolio project by Pranish Pakwan.*
