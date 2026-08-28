# Problem statement

## The question

Vanderbilt is scaling its online and professional programs quickly, and the growth is
concentrated in two areas: education, through Peabody College, and computing and AI,
through the College of Connected Computing. Of the high-demand graduate fields the
university does not yet offer online, which are the strongest launch opportunities?

The analysis scores every candidate field on student demand and labor-market demand,
sorts each into a Go, Test, or Pass band, and ends with one recommendation for which
program to launch next.

## Framing

This is a market-opportunity assessment built entirely from public data. It makes no
claim about Vanderbilt's internal strategy, budget, faculty capacity, facilities, or
accreditation constraints, none of which are public. What it can show is where external
demand suggests an opening, and how the openings rank against each other on evidence
that anyone can check.

## What is in scope, and what was cut

The original framing also called for competitive saturation and pricing benchmarks. Both
were cut from this build and carried forward as future scope. No raw file exists for
either, and neither feeds the score. Saying so plainly matters more than implying a
fuller analysis than the one that ran.

What shipped ranks candidates on two signals:

- **Student demand and market size.** IPEDS national completions by field of study,
  Master's level, 2012 to 2024, which supplies both current size and a multi-year trend.
- **Labor-market demand.** BLS Employment Projections, giving annual job openings and
  projected growth per occupation.

A third input acts as corroboration rather than a metric: whether a field's matched
occupations appear on BLS's own fastest-growing or most-new-jobs lists.

## The baseline being measured against

Vanderbilt's current online catalog is what the candidate universe is subtracted from.
At the time of collection it held 15 online degrees at Master's and Doctorate level,
plus 12 certificates that were excluded as add-on credentials rather than standalone
programs.

| Area | Current online offerings |
|---|---|
| Education (Peabody) | Five M.Ed. programs, an Ed.D., and certificates in learning analytics and emerging learning technology |
| Computing and AI | M.S. in Artificial Intelligence, M.S. in Computer Science |
| Engineering | M.Eng. in Engineering Management |
| Health and Nursing | M.S. in Applied Clinical Informatics, MSN, DNP, PhD in Nursing Science |
| Law, Divinity, Business | Master of Legal Studies, D.Min., Owen certificates |

The pattern is depth in education, computing, and nursing, with most other professional
fields absent: business, public health, security, social work, and finance among them.

## How candidates are chosen

Candidate fields are derived from the data rather than drawn up in advance. An earlier
draft of this project did start from a hand-picked list of 12 fields, and that approach
was abandoned once it became clear the list was reproducing assumptions instead of
testing them. The method that replaced it:

1. Take national labor-market demand across all occupations, not a pre-chosen few.
2. Take national student demand by field of study, at Master's level, across 13 years.
3. Connect the two through the official NCES crosswalk, since BLS is keyed on SOC
   occupation codes and IPEDS on CIP program codes.
4. Subtract the fields Vanderbilt already offers online.

Whatever survives that join is a candidate, and the score decides its rank. Full method
in [`decisions-log.md`](decisions-log.md).

## The role this models

The project is built to the shape of a Data Analyst posting in Vanderbilt's Office of
the Deputy Provost, an office that supports decisions about which new academic and
professional programs the university should pursue. Summarizing the posting rather than
reproducing it, the role covers three areas:

**Strategic insights and market research.** Market assessments for proposed new
programs, covering labor-market demand, learner audience sizing, competitive landscape,
pricing benchmarks, and program viability. Findings are communicated to executive-level
audiences through briefing materials and presentations.

**Data analysis and visualization.** Analysis across financial, platform, and academic
program data, and dashboards tracking KPIs for executives. The posting names Tableau as
the preferred reporting system.

**Data reporting strategy.** Documenting collection and reporting processes, protecting
data integrity, and raising data literacy across the office.

The stated qualifications include a quantitative background, at least two years in data
analysis or strategic research, experience with Tableau, Qualtrics, and R, and the
ability to work through ambiguity and turn market complexity into recommendations
someone can act on.

This project deliberately exercises the first two areas. It does not touch Qualtrics or
R, since no primary survey data was collected and the analysis ran in SQL and Python.

## Disclaimer

This is an independent, self-directed practice project.

It is not affiliated with, commissioned by, endorsed by, reviewed by, or compensated by
Vanderbilt University. No non-public institutional information was used at any point.
Every input is a public dataset or a public web page, all documented with pull dates in
[`data-sources.md`](data-sources.md).

The recommendations here are an exercise. They were never delivered to the university,
never acted on, and should not be read as advice to it or as a statement of its plans.
Vanderbilt was chosen as the subject because its online catalog is public and the
question is a real one that universities actually face, which makes it a useful test of
whether the method produces a defensible answer.
