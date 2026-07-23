# Program Viability Assessment

**Should a university launch a specific new online / professional program?**
An end-to-end market-research analysis that answers that question with public data
and ends in a clear **grow / test / pass** recommendation.

This project mirrors the real work of a higher-education market-intelligence analyst:
sizing labor-market demand, mapping the competitive landscape, benchmarking pricing,
and estimating audience size — then translating those signals into one decision a
leadership team can act on.

> **Status:** scoping / in progress. The specific program under assessment is being
> finalized (see `docs/project-brief.md`).

---

## The question

*Should [home institution] launch a new online **[program TBD]**?*
Answered across three market signals, ending in a go/no-go call.

## The three signals

1. **Student demand** — are learners interested? (search trends + national completions)
2. **Labor-market demand** — do the jobs exist and pay? (BLS wages, growth, openings)
3. **Program economics** — does it pencil out? (competitor pricing, saturation, differentiation)

## The pipeline

```
Python (pandas)      →   SQL (BigQuery)      →   Tableau           →   Recommendation
clean & standardize      join / rank /           4 charts +            1-page SCQA brief
the 3 raw tables         aggregate the tables    1 filter dashboard    grow / test / pass
```

## Repo structure

| Path | What lives here |
|------|-----------------|
| `data/raw/` | The 3 hand-collected source tables, **never edited after collection** |
| `data/clean/` | Analysis-ready tables output by the cleaning notebook |
| `notebooks/` | `01_clean.ipynb` — documented pandas cleaning |
| `sql/` | The 3–4 BigQuery queries (join, window function, conditional aggregation) |
| `dashboard/` | Tableau workbook + exported chart images |
| `docs/` | Project brief, data-source provenance, and the final recommendation |

## Data sources (all public, all free)

- **U.S. Bureau of Labor Statistics (BLS)** — Occupational Outlook Handbook / OEWS: wages, growth, openings
- **IPEDS (nces.ed.gov/ipeds)** — program completions as a student-demand proxy
- **Google Trends** — 5-year search-interest trend
- **Competitor program pages** — tuition, credits, duration, format

## Method note

Data is hand-curated into small CSVs rather than scraped — that is a normal analyst
practice for a focused market assessment, and it keeps the source tables transparent
and auditable. The raw CSVs are committed so the repo is fully self-contained.

---

*A portfolio project by Pranish Pakwan.*
