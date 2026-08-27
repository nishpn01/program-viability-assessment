# Finalist program naming recommendations

**Date:** 2026-08-08
**Status:** Recommendation for review, not a final decision
**Scope:** Naming/branding only. The Phase 3 composite scores and the five-program
shortlist are locked and were not re-derived for this exercise.

> **Supersedes the first version of this document.** That version named
> Family Practice Nurse/Nursing (51.3805) as the #2 finalist. It was dropped after
> discovering it is already delivered online as the Family Nurse Practitioner
> specialty inside Vanderbilt's existing Master of Science in Nursing; see
> `docs/decisions-log.md`. Information Science/Studies (11.0401) was promoted into the
> fifth slot. The collision check in this version was added in direct response to that
> finding.

---

## Purpose

Each finalist is currently carried in the analysis under its CIP 2020 code and federal
CIP title. CIP titles are a statistical classification for federal reporting; they are
not degree names and would not appear on a catalog page, a diploma, or a marketing
landing page. This document proposes what Vanderbilt would plausibly call each program
at launch.

---

## Method

Three sources, in descending order of authority:

1. **Vanderbilt's own online catalog**: `data/clean/vanderbilt_current_programs_clean.csv`
   (15 programs, CIP-coded in Phase 2). The strongest evidence available, since it is
   the naming behavior of the entity that would name the new program.
2. **Vanderbilt Registrar CIP list**: `docs/planning/CIP_Codes.pdf`, the official
   internal program-to-CIP mapping used in Phase 2. Shows how Vanderbilt labels programs
   internally, including specialty tracks that never appear as standalone catalog entries.
3. **Peer graduate catalogs**: bounded Firecrawl search across comparable institutions,
   used only as secondary validation that a proposed name is conventional in the market.

---

## Collision check (step 2)

Checked each of the five CIP codes against the full Registrar list two ways: an exact
CIP6 code match, and a **name-based** search for the same field appearing under a
different CIP. The second check matters; see the method note below.

| CIP code | Exact CIP6 match in Registrar list | Same field under a different CIP | Verdict |
|---|---|---|---|
| 30.7001 | **Yes**: "Data Science", undergraduate **minor** under both College of Connected Computing and School of Engineering | **Yes**: graduate "Data Science" listed at 30.3001 (Computational Science) | **Flag**: existing residential master's of the same name |
| 11.0104 | No | No general informatics program; qualified variants exist at other CIPs (51.2706, 51.3808, 26.1103) | Clear, adjacency to manage |
| 45.0603 | **Yes**: "Economics", undergraduate major **and** minor in A&S, **and** a graduate "Economics" program | (none) | **Strongest flag**: exact CIP6 match to a named graduate program |
| 30.7102 | No | No, nothing in Owen's list; Peabody's "Learning Analytics" (13.0601) is unrelated education research | Clear |
| 11.0401 | No | No | Clear |

**Neither flag reproduces the 51.3805 pattern.** That case was disqualifying because the
program is already delivered online, a direct duplicate of the deliverable. Delivery
mode was checked for both flags here:

- **Data Science**: Vanderbilt's Data Science Institute runs a "9-month, 30-credit,
  on-campus M.S. in Data Science ... delivered fully in person." Residential only.
- **Economics**: A&S runs the M.A. in Economics, also known as GPED (Graduate Program in
  Economic Development). Campus-based, with an on-campus seminar series; no online option
  found.

So both are **naming and positioning constraints, not online duplicates**. Whether that
is disqualifying for viability is a call for the ranking's owner, not a naming decision;
the scores are locked and unchanged here.

**Method note worth carrying forward.** The graduate Data Science program is coded
**30.3001**, not 30.7001. A pure CIP-code join, which is what `sql/04`'s
`already_offered_by_vanderbilt` logic does, would have missed it entirely, even with
complete input data. This is a different failure mode from the Nursing gap (which was
incomplete input at the right CIP), and it would not be fixed by the rebuild described in
the decisions log. The Registrar list also carries no level or delivery-mode column for
its graduate sections, so neither check can be fully automated from that PDF alone.

---

## Vanderbilt's naming convention (observed)

All 15 programs in the current online catalog follow one construction:

> **`[Full degree designator] in [Plain-language field]`**

Consistent behaviors:

- The degree designator is **always spelled out in full**: "Master of Science in
  Computer Science", never "MS in Computer Science" or "M.S.C.S."
- **No abbreviations, acronyms, colons, or marketing suffixes** in the name itself.
- The field is a **plain noun phrase**. There is no "for Leaders"-style construction
  anywhere in the catalog.
- Modifiers are **scope qualifiers, not superlatives**: "Applied Clinical Informatics",
  "Applied Behavior Analysis", "Innovative Design and Technology in Education".
- Designators in use: Master of Science, Master of Education, Master of Engineering,
  Master of Legal Studies, Doctor of Nursing Practice, Doctor of Education, Doctor of
  Ministry, PhD. **There is no Master of Arts in the online catalog**, which is relevant
  to the Economics finalist.

One further pattern, confirmed on the Computer Science page: **Vanderbilt runs the same
degree name in both modalities.** The CS department describes the online program as "an
online option for the M.S. degree in computer science," with applications to the online
and residency programs managed separately and formats non-combinable. The online catalog
and the residential program carry the identical name.

---

## Recommendations

| CIP code | CIP title | Proposed program name | Rationale |
|---|---|---|---|
| 30.7001 | Data Science, General | **Master of Science in Data Science** | The Registrar list labels this exact CIP "Data Science" under the College of Connected Computing, and the catalog's construction gives the rest. Reusing the residential DSI program's name for an online version is established Vanderbilt practice, not a collision: Computer Science already runs identically-named online and residency M.S. programs with separate admissions. Peer-confirmed: Johns Hopkins Engineering for Professionals and Northwestern SPS both title their online programs simply "Data Science." |
| 11.0104 | Informatics | **Master of Science in Applied Informatics** | Vanderbilt never names a program bare "Informatics"; every instance in the Registrar list carries a domain qualifier (Applied Clinical 51.2706, Nursing 51.3808, Bioinformatics 26.1103), and "Applied" is Vanderbilt's own modifier, used twice in the current online catalog. The qualifier also separates it from the School of Medicine's existing Master of Science in Applied Clinical Informatics and from the Information Science finalist below. *Alternative for review:* Indiana's Luddy School offers a "Master of Science in Informatics" at this exact CIP, so the unqualified form is market-defensible; only Vanderbilt-internal precedent argues against it. |
| 45.0603 | Econometrics and Quantitative Economics | **Master of Science in Quantitative Economics** | Must differentiate from A&S's existing M.A. in Economics (GPED), which the Registrar maps to this same CIP6. "Quantitative" is the differentiator the CIP title itself supplies, and the M.S. designator follows the online catalog, which contains no Master of Arts. Peer-confirmed: UW-Madison offers "Quantitative Economics, M.S."; Arizona titles its program directly after the CIP. |
| 30.7102 | Business Analytics | **Master of Science in Business Analytics** | The cleanest of the five: no Registrar entry at any level, undergraduate or graduate. Owen names its specialized master's degrees after the field ("Master of Science Finance", "Master of Accountancy", "Master of Marketing"), which the online catalog normalizes to "Master of Science in [field]". Also the dominant peer convention, used verbatim by Emory Goizueta, Georgetown McDonough, and WashU Olin. |
| 11.0401 | Information Science/Studies | **Master of Science in Information Science** | No Vanderbilt program exists at this CIP or under this name, so the catalog's standard construction applies directly. "Information Science" rather than the bare "Information" keeps it parallel to the other College of Connected Computing master's degrees and distinguishable from the Informatics finalist. Peer-confirmed: UNC's School of Data Science and Society offers the "M.S. in Information Science (MSIS)"; Michigan's UMSI uses "Master of Science in Information." |

---

## Notes and open questions for review

**Informatics and Information Science are the sharpest problem in this set.** They are
adjacent CIP codes, adjacent names, and would both sit in the College of Connected
Computing next to the School of Medicine's existing Applied Clinical Informatics: three
near-synonyms in one portfolio. The names above are drawn to be mutually distinguishable
(11.0104 as the applied/domain-facing program, 11.0401 as the information-systems and
governance program, which is roughly how NCES separates the two codes). Whether both
should launch at all is a portfolio question, not a naming one. If only one proceeds,
Information Science is the more differentiated of the two against Vanderbilt's existing
informatics footprint.

**Economics is the finding to escalate.** It is the only finalist with an exact CIP6
match to a named Vanderbilt graduate program. It is not the 51.3805 situation (GPED is
residential and development-focused, so an online quantitative M.S. is a genuinely
different product), but it deserves the same explicit sign-off rather than passing
silently.

**Data Science needs a positioning decision, not a naming one.** Extension of the DSI
residential degree, or a separately branded online program? The CS precedent says
Vanderbilt is comfortable with the former, and the recommendation assumes it.

**Nothing here reflects program design.** These names assume each program's content
matches its CIP definition. If a curriculum drifts, for example if Business Analytics
is built as a healthcare-analytics program, the name should be revisited, and the CIP
code with it.

---

## Sources

- `data/clean/vanderbilt_current_programs_clean.csv`: Vanderbilt online catalog, 15 programs, CIP-coded in Phase 2
- `docs/planning/CIP_Codes.pdf`: Vanderbilt Registrar official CIP mapping
- `docs/decisions-log.md`: the 51.3805 finding that reshaped this shortlist
- Vanderbilt pages verified for delivery mode (Firecrawl, 2026-08-08): Data Science
  Institute M.S., A&S M.A. in Economics (GPED), CS graduate program
- Peer catalogs consulted (Firecrawl, 2026-08-08): UNC School of Data Science and Society,
  Michigan UMSI, Syracuse iSchool, Indiana Luddy, Emory Goizueta, Georgetown McDonough,
  WashU Olin, Michigan Ross, Duke Fuqua, Johns Hopkins Engineering for Professionals,
  Northwestern SPS, UW-Madison, Arizona
