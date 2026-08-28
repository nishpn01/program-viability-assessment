# Glossary

Plain-English definitions of the domain terms, acronyms, and internal jargon used
across this repo. Grouped by who's most likely to need each entry, though everything
here is fair game for anyone; the grouping is just a reading shortcut. Definitions are
written from what's actually in this project's data and docs.

*Scan-and-update doc: re-run the glossary-generation prompt (`ai-prompts-log.md`,
2.1a) as the project grows rather than hand-editing term-by-term.*

---

## The project, in one breath (everyone)

**ODP**: Office of the Deputy Provost, the Vanderbilt office whose real Data Analyst
job posting this project is modeled on. That role does market research to decide which
new academic/professional programs Vanderbilt should launch; this project answers the
same question using public data.

**Program**: A field of study Vanderbilt could launch online (e.g., "Cybersecurity,"
"Data Science"). Used instead of "candidate" throughout this repo, since "candidate"
read like it meant a person. See `docs/decisions-log.md`.

**Go / Test / Pass**: The three-tier verdict every program gets ranked into, based on
a 0 to 100 composite score: **Go** (strong launch case), **Test** (worth a smaller pilot
or further validation), **Pass** (not worth pursuing now). A standard stage-gate /
traffic-light structure. Cutoffs are locked at Go ≥75.3, Test 45.7 to 75.3, Pass <45.7,
a top-decile/median split derived from the real score distribution (see
`docs/decisions-log.md`).

---

## Data and methodology terms (analysts, students new to data work)

**CIP** (Classification of Instructional Programs): the federal government's code
system for academic fields of study (e.g., "Data Science" has its own CIP code).
Used by IPEDS to categorize what students complete degrees in.

**CIP6**: A CIP code at its most specific (6-digit) level, formatted as a 2-digit
family plus a 4-digit sub-field (e.g., `10101`, shown elsewhere as `1.0101`; see the
crosswalk-format note below). This project's IPEDS table is keyed at the CIP6 level.

**SOC** (Standard Occupational Classification): the federal government's code system
for job types (e.g., "15-2051" is Data Scientists). Used by BLS to categorize the labor
market. Formatted as two digits, a dash, then four digits.

**CIP↔SOC crosswalk** (also called a **junction table** or **bridge table**): an
official NCES lookup table that maps CIP codes (fields of study) to SOC codes (jobs),
since BLS and IPEDS don't share a code system on their own. A junction/bridge table
is the standard database fix whenever two tables relate many-to-many instead of
one-to-one: here, one field of study can lead to several jobs, and one job can be
reached from several fields of study. This project's crosswalk has 6,097 rows linking
2,143 CIP codes to 868 SOC codes.

**IPEDS** (Integrated Postsecondary Education Data System): the federal government's
database of U.S. college and university statistics, including how many students
complete each degree program each year. This project uses IPEDS (via the datausa.io
API) as the national student-demand / market-size signal, at the Master's-degree level.

**BLS** (Bureau of Labor Statistics): the federal agency that publishes job-market
data, including how many people work in each occupation, how fast each occupation is
projected to grow, and how many job openings it produces each year. This project uses
BLS Employment Projections as the labor-demand signal.

**"Line item" vs. "Summary"** (BLS Table 1.10): BLS's occupational-openings table mixes
individual occupations ("Line item," e.g., "Data Scientists") with category rollups that
sum up a group of occupations ("Summary," e.g., "Computer and Mathematical
Occupations," or the "Total, all occupations" row). Of the 1,113 rows, 832 are Line
item and 281 are Summary. Any aggregate math must filter to `Occupation type ==
Line item` first, or rollup rows will double-count the detail rows underneath them.

**Grain**: What a single row of a table represents (e.g., "one row per CIP6 per
year," or "one row per program"). A separate decision from the Go/Test/Pass scoring:
grain decides how many rows exist and what each one means, and scoring is math applied
to each row afterward.

**Join cardinality**: How many rows on one side of a join match how many rows on the
other side: one-to-one, one-to-many, or many-to-many. The CIP↔SOC crosswalk is
many-to-many (average 2.8 SOC codes per CIP code, up to 180; average 7 CIP codes per
SOC code, up to 337), which is why it needs a junction table and a documented join rule
rather than a simple merge.

**Suppression** (IPEDS): IPEDS hides (doesn't publish) a data cell when too few
students completed a program in a given year, to protect student privacy. In this
project's data, 319 of 1,290 CIP6 codes are missing at least one year between 2012 and
2024, which is expected suppression, not a data-loading error.

**Staging vs. mart tables**: Staging tables are the cleaned versions of each raw
source, still one table per source (e.g., a cleaned BLS table, a cleaned IPEDS table).
A mart table is the single joined table built specifically to answer the project's
question (e.g., `derived_candidates`), combining multiple staging tables via their
shared keys.

---

## SQL terms (analysts, students new to SQL)

**DDL** (Data Definition Language): the part of SQL that defines a table's shape
(`CREATE TABLE`, column types, primary keys) before any data is loaded. **DML** (Data
Manipulation Language: `SELECT`/`INSERT`/`UPDATE`) reads or changes the data itself.

**CTE (Common Table Expression)**: a named, temporary result set defined with
`WITH name AS (...)` and used later in the same query, like a well-named variable for
SQL. `sql/04_build_derived_candidates.sql` chains several CTEs together (e.g.
`ipeds_latest`, `ranked_socs`, `labor_weighted`) so each step is readable and testable
on its own, replacing what would otherwise be one unreadable nested query.

**Window function**: a calculation performed *within* each group of rows without
collapsing them into one row per group (unlike `GROUP BY`, which does collapse them).
`ROW_NUMBER() OVER (PARTITION BY cip2020_code ORDER BY year DESC)` numbers each CIP's
years newest-to-oldest while keeping every row; filtering to `rn = 1` then picks each
group's most recent year. This is how `derived_candidates` finds each CIP's latest and
earliest available year, and each CIP's top-3 SOCs by employment.

**Weighted average**: an average where some values count more than others, computed
as `SUM(value × weight) / SUM(weight)`. This project's locked join rule uses each
matched SOC's 2024 employment as the weight, so a large occupation deliberately pulls a
CIP's demand score toward itself more than a small one does.

**`NULLIF(x, 0)`**: turns a value into `NULL` if it equals 0, most often used to guard
a division (`SUM(a) / NULLIF(SUM(b), 0)`) so dividing by zero produces an honest
"unknown" (`NULL`) instead of crashing the query.

**Honest NULL vs. meaningful zero**: a recurring design choice in this project's SQL:
`NULL` means "we don't know" (e.g. a completions trend when only one year of data
exists), while `0` means "we checked, and the real answer is zero" (e.g. `n_socs_used`
when a CIP genuinely has no labor-market match). Filling an unknown trend with a fake
`0%` would misrepresent the data as more complete than it actually is.

**`LEFT JOIN` vs. `INNER JOIN`**: an `INNER JOIN` keeps only rows that match on both
sides. A `LEFT JOIN` keeps every row from the left (first-named) table even when
nothing matches on the right, filling the unmatched columns with `NULL`.
`derived_candidates` is built starting `FROM` the IPEDS base table with `LEFT JOIN`s
onto the labor-demand CTEs; an `INNER JOIN` there would have silently deleted every CIP
with no labor-market match, a classic and easy-to-miss join bug.

**Primary key (PK) as an enforced grain guarantee**: declaring `PRIMARY KEY` on a
table's grain column(s) does more than label what a row means. It makes the database
*reject* any insert or query result that would produce a duplicate, turning a
documented assumption about grain into something the database actively guarantees.

---

## Statistics terms (introduced in Phase 3 scoring)

**Percentile**: the value at a given position in a sorted list, stated as "X% of the
way up." The p90 of `completions_latest_year` is the value where 90% of programs have
fewer completions and 10% have more; the median is just the 50th percentile.

**Skew**: how lopsided a distribution is around its center. 0 is symmetric, and a
larger positive number means a small number of large outliers are stretching the
distribution's tail. `completions_latest_year` (skew 17.5) is far more skewed than
`employment_weighted_growth_pct` (skew 0.8), which is why the two were normalized by
percentile rank instead of min-max. Full distribution profile in
`docs/planning/phase3-scoring-findings.md`. No single formula is universal, and different
tools' skew functions can disagree slightly on the same data.

**Correlation coefficient (Pearson's r)**: how strongly two numeric columns move
together, from -1 (perfectly inverse) through 0 (no linear relationship) to +1
(perfectly proportional). Used here to confirm the mart's four continuous metrics are
independent enough (all pairwise r between 0.04 and 0.20) that combining them in a
composite score adds real signal without double-counting one thing twice.

**Min-max scaling**: rescaling a column so its smallest value becomes 0 and largest
becomes 100, with everything else stretched proportionally between. Simple, but one
extreme outlier defines the whole scale for everyone else, which is why it was rejected
for this project's most skewed metrics (`docs/decisions-log.md`).

**Percentile-rank scaling**: rescaling a column by each value's percentile position
rather than its raw magnitude, so a giant outlier can't compress the rest of the
distribution toward 0. The normalization method recommended in
`docs/planning/phase3-scoring-findings.md`, verified against real rows in
`notebooks/phase3_ai_report_verification.ipynb`.

---

## Tableau and dashboard terms (introduced in Phase 4)

**Parameter**: a stored value that isn't tied to any row of data; on its own it does
nothing until a calculated field or chart references it. Drives `Select Finalist`
here, so the KPI row and comparison table can respond to one control even though they
pull from two extracts with no shared join key.

**Filter**: narrows which rows a chart shows. A filter subtracts data; a parameter
just stores a value for something else to read.

**Parameter action**: a click or hover on a chart element that sets a parameter's
value automatically, replacing a viewer having to pick from a dropdown.

**Reference band**: a shaded region behind a chart marking the space between two
fixed values, used here for the Go/Test/Pass score cutoffs on the distribution chart,
so the threshold is visible directly on the chart.

**KPI**: one of the four headline numbers (score, annual openings, completions,
growth) shown at the top of the dashboard for whichever finalist is selected.

**Log scale**: an axis where equal distances represent equal ratios rather than equal
differences. Used on the scatter chart because the underlying data is heavily skewed,
and a linear scale would compress almost every point into one corner.

**Forecast / prediction interval**: Tableau's built-in projection of a time series
beyond its known data. Considered for the completions trend chart and set aside: two
of the five finalists have 5 years of history against 13 for the other three, and a
forecast would have shown equal confidence in unequal projections.

---

## Diagramming and process terms (technical hiring managers, engineers)

**ERD** (Entity-Relationship Diagram): a diagram showing each table in a data model, its
key column(s), and how tables connect to each other (one-to-one, one-to-many,
many-to-many). This project's ERD lives in `docs/erd.md`.

**Mermaid**: A plain-text syntax for drawing diagrams (flowcharts, ER diagrams, etc.)
that GitHub renders automatically from a code block, with no separate diagramming tool
or export step needed. Used for this project's ERD.

---

## Tools referenced in this repo

**Firecrawl**: A web-scraping tool used to pull structured data out of web pages (e.g.,
BLS tables, program listing pages) that don't offer a clean API. Runs locally in this
project because a sandboxed environment blocks outbound network access.

**Data Wrangler**: A VS Code extension for interactively cleaning tabular data
(filtering, renaming, type conversion) with a preview of each step, used for this
project's Phase 2 cleaning work.

**BigQuery**: Google's cloud SQL data warehouse. The SQL phase ran on local Postgres;
porting to BigQuery is parked as a future exercise.

**Tableau Public**: The free, publicly-hosted version of Tableau, used for this
project's dashboard. It can't connect live to a database, so query results are exported
to CSV and loaded into Tableau Public directly.

**datausa.io**: A free public API (built on a "Tesseract" data-cube backend) that
re-publishes IPEDS and other federal datasets in a simpler JSON format than the raw
IPEDS Data Center; this project's IPEDS completions table was pulled from it.

---

## Data-source acronyms (reference)

**NCES**: National Center for Education Statistics, the federal body that publishes
IPEDS and the official CIP↔SOC crosswalk.

**OOH**: Occupational Outlook Handbook, a BLS publication with per-occupation pay,
growth, and education-requirement data (used for this project's first-pass 12-occupation
sample, `bls_labor_demand.csv`, before the broader BLS tables were pulled).

**OEWS**: Occupational Employment and Wage Statistics, a BLS dataset with wages and
employment broken out by state/metro area. Flagged as a source to use only if a
geographic chart is added later.

**College Scorecard**: A U.S. Department of Education API giving program-level
earnings and debt outcomes by institution and CIP code. Flagged as a possible ROI
signal (what graduates of a specific program actually earn).

**O\*NET**: A Department of Labor database linking occupations to the skills they
require. Flagged as a nice-to-have enrichment, tying a program's field to in-demand
skills.
