-- ============================================================================
-- 04_build_derived_candidates.sql
-- Join/derive (Phase 2, final step) — 4 of 5: build the analysis mart — one row per candidate CIP program,
-- combining student demand (IPEDS) and labor demand (BLS via the crosswalk).
--
-- Run with:  psql -p 5433 -d program_viability -f sql/04_build_derived_candidates.sql
--
-- Locked rules implemented here (docs/decisions-log.md):
--   * Grain: one row per CIP6 code (1,268 rows). No clustering.
--   * Labor demand: each CIP's TOP 3 matched SOCs by 2024 employment,
--     combined with an EMPLOYMENT-WEIGHTED average. Fewer than 3 matches →
--     use what exists and record n_socs_used.
--   * Wages: never blended (no wage data for 772 of 832 SOCs). Only a boolean
--     flag: does a top-3 SOC appear in BLS's own top-30 lists?
--   * Vanderbilt overlap: exact CIP6 match against the 14 distinct VU codes,
--     kept as a flag — rows are never dropped.
--
-- Concepts in this file:
--   * CTEs (WITH name AS (...)): named intermediate results, like variables
--     for queries. Each step below is testable alone: SELECT * FROM <cte>.
--   * Window functions: ROW_NUMBER() OVER (PARTITION BY g ORDER BY s) ranks
--     rows WITHIN each group without collapsing the rows (unlike GROUP BY).
--   * Weighted average: SUM(metric * weight) / SUM(weight).
--   * NULLIF(x, 0): turns 0 into NULL so division never crashes; the result
--     is NULL, i.e. "unknown", which is honest.
--   * LEFT JOIN from the IPEDS base: keeps all 1,268 candidates even when a
--     CIP has no labor-market match (metrics become NULL, row survives).
--     An INNER JOIN here would silently delete candidates — the classic bug.
--   * STRING_AGG: collapses a group's values into one comma-separated string.
--   * BOOL_OR: TRUE if any row in the group is TRUE (like Python's any()).
-- ============================================================================

DROP TABLE IF EXISTS derived_candidates;

CREATE TABLE derived_candidates AS
WITH

-- ----------------------------------------------------------------------------
-- STUDENT DEMAND SIDE (IPEDS)
-- ----------------------------------------------------------------------------

-- Latest available year per CIP. ROW_NUMBER() = 1 picks the newest row of each
-- CIP's partition. "Latest AVAILABLE" matters: 319 CIPs have suppressed years,
-- so latest_year is not always 2024.
ipeds_latest AS (
    SELECT cip2020_code,
           year        AS latest_year,
           completions AS completions_latest_year
    FROM (
        SELECT cip2020_code, year, completions,
               ROW_NUMBER() OVER (PARTITION BY cip2020_code ORDER BY year DESC) AS rn
        FROM ipeds_completions_masters
    ) ranked
    WHERE rn = 1
),

-- Earliest available year per CIP (same trick, ascending order).
ipeds_earliest AS (
    SELECT cip2020_code,
           year        AS trend_earliest_year,
           completions AS completions_earliest_year
    FROM (
        SELECT cip2020_code, year, completions,
               ROW_NUMBER() OVER (PARTITION BY cip2020_code ORDER BY year ASC) AS rn
        FROM ipeds_completions_masters
    ) ranked
    WHERE rn = 1
),

-- % change from each CIP's OWN earliest to latest available year.
-- NULL (unknown, not zero) when only one year exists or the base year is 0.
ipeds_trend AS (
    SELECT l.cip2020_code,
           e.trend_earliest_year,
           CASE
               WHEN l.latest_year > e.trend_earliest_year
               THEN ROUND( (l.completions_latest_year - e.completions_earliest_year)
                           * 100.0 / NULLIF(e.completions_earliest_year, 0), 1)
               ELSE NULL
           END AS completions_trend_pct
    FROM ipeds_latest   l
    JOIN ipeds_earliest e USING (cip2020_code)
),

-- Official CIP 2020 title, taken from the crosswalk (registrar wording).
-- MIN() is just a safe way to pick one title if a CIP ever had two spellings.
cip_titles AS (
    SELECT cip2020_code, MIN(cip2020_title) AS cip2020_title
    FROM cip_soc_crosswalk
    GROUP BY cip2020_code
),

-- ----------------------------------------------------------------------------
-- LABOR DEMAND SIDE (crosswalk -> BLS openings)
-- ----------------------------------------------------------------------------

-- All (CIP, SOC) pairs that have projection data, ranked within each CIP by
-- 2024 employment. soc_code as a tie-breaker makes reruns deterministic.
-- INNER JOIN is correct here: a SOC with no BLS row contributes no data.
-- (The 12 SOCs missing from the crosswalk and 48 crosswalk SOCs missing from
-- BLS simply drop out of this CTE — the LEFT JOIN at the end keeps their CIPs.)
ranked_socs AS (
    SELECT x.cip2020_code,
           o.soc_code,
           o.employment_2024,
           o.occupational_openings_2024_34,
           o.employment_change_percent_2024_34,
           ROW_NUMBER() OVER (PARTITION BY x.cip2020_code
                              ORDER BY o.employment_2024 DESC, o.soc_code) AS soc_rank
    FROM cip_soc_crosswalk        x
    JOIN bls_occupational_openings o ON o.soc_code = x.soc2018_code
    WHERE o.employment_2024 IS NOT NULL          -- a SOC without a weight can't be weighted
),

-- Keep each CIP's top 3 (locked rule). CIPs with 1 or 2 matches keep 1 or 2.
top3_socs AS (
    SELECT * FROM ranked_socs WHERE soc_rank <= 3
),

-- Collapse the top-3 into one row per CIP:
--   weighted openings  = SUM(openings * employment) / SUM(employment)
--   weighted growth %  = SUM(growth%  * employment) / SUM(employment)
-- Bigger occupations pull the average toward themselves — that is the point.
labor_weighted AS (
    SELECT cip2020_code,
           STRING_AGG(soc_code, ', ' ORDER BY soc_rank)                  AS matched_soc_codes,
           COUNT(*)                                                     AS n_socs_used,
           ROUND( SUM(occupational_openings_2024_34    * employment_2024)
                / NULLIF(SUM(employment_2024), 0), 2)                    AS employment_weighted_openings,
           ROUND( SUM(employment_change_percent_2024_34 * employment_2024)
                / NULLIF(SUM(employment_2024), 0), 2)                    AS employment_weighted_growth_pct
    FROM top3_socs
    GROUP BY cip2020_code
),

-- Wage-adjacent bonus flag (locked rule: flag, never a blended metric).
-- TRUE when any of the CIP's top-3 SOCs appears on either BLS top-30 list.
bls_top30_flag AS (
    SELECT cip2020_code,
           BOOL_OR(
               soc_code IN (SELECT soc_code FROM bls_fastest_growing
                            UNION                       -- UNION de-dupes the two lists
                            SELECT soc_code FROM bls_most_new_jobs)
           ) AS in_bls_top30_flag
    FROM top3_socs
    GROUP BY cip2020_code
),

-- The 14 distinct CIP codes Vanderbilt already offers (15 programs; two M.Ed.s
-- legitimately share 13.0401 — verified against planning/CIP_Codes.pdf).
vanderbilt_cips AS (
    SELECT DISTINCT cip2020_code FROM vanderbilt_current_programs
)

-- ----------------------------------------------------------------------------
-- FINAL ASSEMBLY: LEFT JOIN everything onto the IPEDS base so all 1,268
-- candidates survive. EXISTS turns "is this CIP in that list?" into a boolean.
-- ----------------------------------------------------------------------------
SELECT il.cip2020_code,
       ct.cip2020_title,
       il.latest_year,
       il.completions_latest_year,
       tr.trend_earliest_year,
       tr.completions_trend_pct,
       lw.matched_soc_codes,
       COALESCE(lw.n_socs_used, 0)              AS n_socs_used,      -- 0, not NULL: "we looked, found none"
       lw.employment_weighted_openings,                              -- NULL stays NULL: "unknown"
       lw.employment_weighted_growth_pct,
       COALESCE(bf.in_bls_top30_flag, FALSE)    AS in_bls_top30_flag,
       EXISTS (SELECT 1 FROM vanderbilt_cips v
               WHERE v.cip2020_code = il.cip2020_code) AS already_offered_by_vanderbilt
FROM ipeds_latest    il
JOIN cip_titles      ct USING (cip2020_code)   -- safe INNER: verified 0 missing in 03
LEFT JOIN ipeds_trend    tr USING (cip2020_code)
LEFT JOIN labor_weighted lw USING (cip2020_code)
LEFT JOIN bls_top30_flag bf USING (cip2020_code);

-- Enforce the mart's grain: exactly one row per CIP. Fails loudly if the
-- joins above ever fan out (the "join fan-out" bug this PK exists to catch).
ALTER TABLE derived_candidates ADD PRIMARY KEY (cip2020_code);
