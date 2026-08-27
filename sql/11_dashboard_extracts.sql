-- ============================================================================
-- 11_dashboard_extracts.sql
-- Phase 4 -- build the two CSV extracts the Tableau dashboard reads directly.
-- Design locked in
-- docs/planning/phase4-dashboard-design-spec.md (see also docs/decisions-log.md,
-- Step 18).
--
-- Generated with AI assistance; starter prompt in docs/ai-prompts-log.md (4.1).
--
-- Run from the REPO ROOT:
--   psql -p 5433 -d program_viability -f sql/11_dashboard_extracts.sql
-- ============================================================================

-- STEP 0 -- finalist CIP6 -> proposed-name mapping. Rerunnable: drops first.
-- Source: docs/planning/phase3-finalist-program-naming-recommendations.md.
DROP TABLE IF EXISTS finalist_programs;

CREATE TABLE finalist_programs (
    cip2020_code   NUMERIC(7,4)  NOT NULL,
    proposed_name  TEXT          NOT NULL
);

INSERT INTO finalist_programs (cip2020_code, proposed_name) VALUES
    (30.7001, 'MSc. in Data Science'),
    (11.0104, 'MSc. in Applied Informatics'),
    (45.0603, 'MSc. in Quantitative Economics'),
    (30.7102, 'MSc. in Business Analytics'),
    (11.0401, 'MSc. in Information Science');

ALTER TABLE finalist_programs ADD PRIMARY KEY (cip2020_code);


--SELECT * FROM finalist_programs ORDER BY cip2020_code;


-- ----------------------------------------------------------------------------
-- EXTRACT A -- the scored population, one row per candidate.
-- ----------------------------------------------------------------------------

-- STEP 1 -- preview: row count and finalist count, checked before exporting.
-- Expected: 1,254 total (the 14 already-offered rows have band IS NULL and
-- are dropped by the filter), 5 of them is_finalist = TRUE.
SELECT
    count(*)                                            AS n_rows,
    count(*) FILTER (WHERE f.cip2020_code IS NOT NULL)  AS n_finalists
FROM scored_candidates s
JOIN derived_candidates d USING (cip2020_code)
LEFT JOIN finalist_programs f USING (cip2020_code)
WHERE s.band IS NOT NULL;

-- STEP 2 -- extract review before export.
SELECT
    s.cip2020_title,
    s.score,
    s.band,
    d.employment_weighted_openings,
    d.employment_weighted_growth_pct,
    d.completions_latest_year,
    s.pct_completions_latest_year,
    s.pct_employment_weighted_openings,
    s.pct_completions_trend_pct,
    s.pct_employment_weighted_growth_pct,
    s.pct_bls_top30_flag,
    d.in_bls_top30_flag,
    (f.cip2020_code IS NOT NULL)  AS is_finalist,
    f.proposed_name
FROM scored_candidates s
JOIN derived_candidates d USING (cip2020_code)
LEFT JOIN finalist_programs f USING (cip2020_code)
WHERE s.band IS NOT NULL
ORDER BY s.score DESC;

-- STEP 3 -- export Extract A.
\copy (SELECT s.cip2020_title, s.score, s.band, d.employment_weighted_openings, d.employment_weighted_growth_pct, d.completions_latest_year, s.pct_completions_latest_year, s.pct_employment_weighted_openings, s.pct_completions_trend_pct, s.pct_employment_weighted_growth_pct, s.pct_bls_top30_flag, d.in_bls_top30_flag, (f.cip2020_code IS NOT NULL) AS is_finalist, f.proposed_name FROM scored_candidates s JOIN derived_candidates d USING (cip2020_code) LEFT JOIN finalist_programs f USING (cip2020_code) WHERE s.band IS NOT NULL ORDER BY s.score DESC) TO 'data/derived/dashboard_population.csv' WITH (FORMAT csv, HEADER true);

-- ----------------------------------------------------------------------------
-- EXTRACT B -- completions trend, finalists only, 2012-2024.
-- ----------------------------------------------------------------------------

-- STEP 4 -- gap check: which of the 5 x 13 = 65 expected (CIP, year)
-- combinations are actually missing (IPEDS suppression), checked BEFORE the
-- export so a short extract is explained
WITH expected AS (
    SELECT f.cip2020_code, f.proposed_name, y.year
    FROM finalist_programs f
    CROSS JOIN generate_series(2012, 2024) AS y(year)
)
SELECT e.cip2020_code, e.proposed_name, e.year
FROM expected e
LEFT JOIN ipeds_completions_masters ic
    ON ic.cip2020_code = e.cip2020_code AND ic.year = e.year
WHERE ic.completions IS NULL
ORDER BY e.proposed_name, e.year;


-- WITH expected AS (
--     SELECT f.cip2020_code, f.proposed_name, y.year
--     FROM finalist_programs f
--     CROSS JOIN generate_series(2012, 2024) AS y(year)
-- ),
-- missing AS (
--     SELECT e.cip2020_code, e.proposed_name, e.year
--     FROM expected e
--     LEFT JOIN ipeds_completions_masters ic
--         ON ic.cip2020_code = e.cip2020_code AND ic.year = e.year
--     WHERE ic.completions IS NULL
-- )
-- SELECT cip2020_code, proposed_name, count(*) AS n_missing_years,
--        min(year) AS earliest_missing, max(year) AS latest_missing
-- FROM missing
-- GROUP BY cip2020_code, proposed_name
-- ORDER BY proposed_name;

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

-- Confirmed directly (see docs/decisions-log-detailed.md Step 19): 16 of the 65 expected (CIP, year) combos are missing --
-- MSc. in Data Science (30.7001) and MSc. in Business Analytics (30.7102),
-- 2012-2019 each, 8 years apart. Clean, identical boundary across both CIPs
-- (not scattered individual cells) -- consistent with both being newer CIP6
-- codes introduced in the CIP2020 revision, not suppressed low-count cells
-- (the Phase 2 gotcha, which was scattered). Extract B is expected to land at
-- 49 rows, not 65: 3 finalists x 13 years (39) + 2 finalists x 5 years (10).

-- STEP 5 -- the extract itself, as a plain SELECT for review before export.
SELECT
    ic.cip2020_code,
    f.proposed_name,
    ic.year,
    ic.completions
FROM ipeds_completions_masters ic
JOIN finalist_programs f USING (cip2020_code)
ORDER BY f.proposed_name, ic.year;

-- STEP 6 -- export Extract B.
\copy (SELECT ic.cip2020_code, f.proposed_name, ic.year, ic.completions FROM ipeds_completions_masters ic JOIN finalist_programs f USING (cip2020_code) ORDER BY f.proposed_name, ic.year) TO 'data/derived/dashboard_completions_trend.csv' WITH (FORMAT csv, HEADER true);


