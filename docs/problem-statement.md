# Problem statement

The brief below is the ask this project answers, stated as it stood before any analysis
began. It names no data sources and no method, because a brief would not. Working out
what to measure, where to get it, and what counts as a good answer is the analyst's job,
and that work is what the rest of this repo documents.

## The brief

Vanderbilt has been expanding its online and professional program portfolio, and the
expansion has concentrated in a few areas. Education, computing, and nursing are well
covered online. Most other professional fields are absent from the online catalog
entirely.

The office responsible for new program development has to decide where to expand next.
That decision currently risks being driven by whichever school makes the strongest
internal case, or by whichever peer institution moved most recently, neither of which is
evidence about whether a program would find students or lead anywhere for them.

The ask:

> **Which new online graduate program should Vanderbilt launch next, and what is the
> case for it?**

What the office needs back:

- One recommendation, named, with the reasoning behind it.
- The shortlist it came from, ranked, so the runners-up stay visible and the choice can
  be argued with.
- A verdict on every option that was considered, including the ones that did not make
  the shortlist. A field that is not right this year may be right in two, and that only
  stays available if it was assessed rather than dropped from consideration.
- Reasoning a director can follow, question, and defend to leadership without taking any
  step on faith.
- Something interactive for exploring the options, and a written document that can be
  circulated on its own.

Constraints:

- Public data only. No access to internal enrollment, financial, or faculty systems.
- Every number has to be traceable back to a source, since the recommendation will be
  challenged.
- Scoped to a few working sessions, so depth in one area matters more than covering
  everything at once.

Audience: the office director and academic leadership.

## What the brief leaves open

Deliberately, almost everything about how to answer it.

The brief does not say what demand means, or how to measure whether a field is worth
entering, or what makes one candidate stronger than another. It does not say which
programs to consider, or how many. It does not name a single dataset.

Those decisions are the actual work, and they are where this project spent most of its
effort. Each one is recorded in [`decisions-log.md`](decisions-log.md), including the
options that were considered and rejected.

## Turning the brief into something answerable

A program is worth launching if enough people want to study the field, the field leads
somewhere for them afterward, and Vanderbilt is not already offering it. Stated that
way, the ask decomposes into four questions:

1. **Is there student demand?** How many people nationally complete a degree in this
   field each year, and is that number rising or falling?
2. **Is there labor demand?** Do the jobs this field feeds have openings, and are those
   occupations growing?
3. **Is it already covered?** Does Vanderbilt offer this field online today?
4. **How does it compare?** Given all of the above, where does this field rank against
   every other field the university could offer?

Nothing in the brief points to a dataset for any of these. Identifying which public
sources could answer them, testing whether those sources were actually reachable, and
establishing what each one could not answer was the first phase of the project. The
sources that survived that pass are listed with pull dates in
[`data-sources.md`](data-sources.md).

Two decisions from that phase shaped everything after it. The candidate set was derived
from the data rather than chosen in advance, after an earlier draft that started from a
hand-picked list of fields was abandoned for reproducing assumptions instead of testing
them. And the fourth question, comparison, forced a scoring method, which is the single
most consequential methodology choice in the project.

## Scope that was cut

The brief as originally framed also asked for competitive saturation and pricing
benchmarks against peer online programs. Both were cut and carried forward as future
scope. No data was collected for either, and neither feeds the recommendation. What
shipped answers the four questions above and stops there.

## The role this models

The project is built to the shape of a Data Analyst posting in Vanderbilt's Office of
the Deputy Provost, an office that supports decisions about which new academic and
professional programs the university should pursue. Summarizing that posting rather than
reproducing it, the role covers three areas:

**Strategic insights and market research.** Market assessments for proposed new
programs, covering labor-market demand, learner audience sizing, competitive landscape,
pricing benchmarks, and program viability. Findings go to executive-level audiences
through briefing materials and presentations.

**Data analysis and visualization.** Analysis across financial, platform, and academic
program data, and dashboards tracking KPIs for executives. The posting names Tableau as
the preferred reporting system.

**Data reporting strategy.** Documenting collection and reporting processes, protecting
data integrity, and raising data literacy across the office.

The stated qualifications include a quantitative background, at least two years in data
analysis or strategic research, experience with Tableau, Qualtrics, and R, and the
ability to work through ambiguity and turn market complexity into recommendations
someone can act on.

This project exercises the first two areas. Qualtrics and R were not used, since no
survey data was collected and the analysis ran in SQL and Python.

## Disclaimer

This is an independent, self-directed practice project.

It is not affiliated with, commissioned by, endorsed by, reviewed by, or compensated by
Vanderbilt University. No non-public institutional information was used at any point.
Every input is a public dataset or a public web page, documented with pull dates in
[`data-sources.md`](data-sources.md).

The brief above was written for this exercise. No such request was made by the
university, and the recommendation was never delivered to it or acted on by it.
Vanderbilt was chosen as the subject because its online catalog is public and the
question is one universities genuinely face, which makes it a fair test of whether the
method produces a defensible answer.
