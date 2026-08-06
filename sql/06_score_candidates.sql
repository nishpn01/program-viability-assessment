-- ============================================================================
-- 06_score_candidates.sql
-- Phase 3 — 1 of 2: turn derived_candidates' raw metrics into a 0-100 composite
-- score per candidate CIP program.
--
-- Run with:  psql -p 5433 -d program_viability -f sql/06_score_candidates.sql
-- (requires derived_candidates to already exist — run sql/01-05 first if not)
--
-- Locked rules implemented here (docs/phase3-scoring-findings.md,
-- docs/decisions-log.md 2026-08-04):
--   * Normalization: PERCENTILE RANK, not min-max. Two of the four metrics are
--     extremely right-skewed (completions_latest_year skew 17.5,
--     completions_trend_pct skew 13.9) -- min-max would let one outlier
--     (Business Administration, 97,150 completions) crush every other
--     candidate's score near zero. Percentile rank only uses relative
--     position, so it's immune to that.
--   * Weights: completions_latest_year 30%, employment_weighted_openings 30%,
--     completions_trend_pct 15%, employment_weighted_growth_pct 15%,
--     in_bls_top30_flag 10%. Size (60%) outweighs trend (30%) on purpose --
--     the skew above means a huge trend % is often a small-base artifact,
--     not real momentum.
--   * NULLs: PARTIAL REWEIGHT. A candidate missing a metric (77 with no labor
--     match, 126 with no completions trend) gets scored on whatever it does
--     have, with the remaining weights rescaled to still sum to 100% for
--     that row -- never excluded, never given a fabricated placeholder value.
--     n_metrics_used records how much evidence backs each score.
--
-- Concepts in this file:
--   * PERCENT_RANK() OVER (ORDER BY x): ranks every row from 0 (lowest x) to
--     1 (highest x) based on relative position only, not magnitude -- unlike
--     min-max, one extreme outlier can't distort everyone else's score.
--     Scaled here to 0-100 to match this project's score basis.
--   * Percentiles are computed only among candidates that actually HAVE a
--     value for that metric (WHERE x IS NOT NULL) -- a NULL can't be ranked,
--     and letting it sit in the ordering would skew everyone else's
--     percentile. The LEFT JOIN back onto the full 1,268-row base afterward
--     is what lets a NULL stay NULL instead of becoming a fake low score.
--   * COALESCE(x * w, 0) in the numerator + a matching CASE in the
--     denominator is the mechanical trick for "partial reweight": a NULL
--     component contributes 0 to both the top and bottom of the average,
--     which is mathematically identical to just not counting it.
--   * ROUND(x, 1) needs x cast to ::numeric first. PERCENT_RANK() and plain
--     division both return double precision, and Postgres only defines
--     ROUND(numeric, integer) -- ROUND(double precision, integer) doesn't
--     exist as a function signature. Every ROUND call below casts for this.
-- ============================================================================

DROP TABLE IF EXISTS scored_candidates;

CREATE TABLE scored_candidates AS
WITH

-- ----------------------------------------------------------------------------
-- STEP 1: percentile-rank each metric, 0-100, among candidates that have a
-- value for it. Each CTE is independent so a NULL in one metric doesn't
-- affect another metric's ranking.
-- ----------------------------------------------------------------------------

pct_completions AS (
    SELECT cip2020_code,
           ROUND((PERCENT_RANK() OVER (ORDER BY completions_latest_year) * 100)::numeric, 1)
               AS pct_completions_latest_year
    FROM derived_candidates
),

pct_trend AS (
    SELECT cip2020_code,
           ROUND((PERCENT_RANK() OVER (ORDER BY completions_trend_pct) * 100)::numeric, 1)
               AS pct_completions_trend_pct
    FROM derived_candidates
    WHERE completions_trend_pct IS NOT NULL         -- 126 excluded from ranking; rejoined as NULL below
),

pct_openings AS (
    SELECT cip2020_code,
           ROUND((PERCENT_RANK() OVER (ORDER BY employment_weighted_openings) * 100)::numeric, 1)
               AS pct_employment_weighted_openings
    FROM derived_candidates
    WHERE employment_weighted_openings IS NOT NULL  -- 77 excluded from ranking; rejoined as NULL below
),

pct_growth AS (
    SELECT cip2020_code,
           ROUND((PERCENT_RANK() OVER (ORDER BY employment_weighted_growth_pct) * 100)::numeric, 1)
               AS pct_employment_weighted_growth_pct
    FROM derived_candidates
    WHERE employment_weighted_growth_pct IS NOT NULL
),

-- ----------------------------------------------------------------------------
-- STEP 2: bring every candidate's percentile scores (or NULL where unranked)
-- back onto the full base. The flag is already binary, so it maps straight
-- to 0 or 100 -- no ranking needed, and it's never NULL (04 COALESCEs it to
-- FALSE), so it always contributes.
-- ----------------------------------------------------------------------------

components AS (
    SELECT d.cip2020_code,
           pc.pct_completions_latest_year,
           pt.pct_completions_trend_pct,
           po.pct_employment_weighted_openings,
           pg.pct_employment_weighted_growth_pct,
           CASE WHEN d.in_bls_top30_flag THEN 100.0 ELSE 0.0 END AS pct_bls_top30_flag
    FROM derived_candidates d
    LEFT JOIN pct_completions pc USING (cip2020_code)
    LEFT JOIN pct_trend       pt USING (cip2020_code)
    LEFT JOIN pct_openings    po USING (cip2020_code)
    LEFT JOIN pct_growth      pg USING (cip2020_code)
),

-- ----------------------------------------------------------------------------
-- STEP 3: weighted average with partial reweight. weighted_sum and
-- weight_used both drop a component when it's NULL, so dividing one by the
-- other rescales the remaining weights automatically -- no separate
-- "renormalize" step needed.
-- ----------------------------------------------------------------------------

weighted AS (
    SELECT cip2020_code,
           pct_completions_latest_year,
           pct_completions_trend_pct,
           pct_employment_weighted_openings,
           pct_employment_weighted_growth_pct,
           pct_bls_top30_flag,
           ( COALESCE(pct_completions_latest_year       * 30, 0) +
             COALESCE(pct_completions_trend_pct          * 15, 0) +
             COALESCE(pct_employment_weighted_openings   * 30, 0) +
             COALESCE(pct_employment_weighted_growth_pct * 15, 0) +
             pct_bls_top30_flag                          * 10
           ) AS weighted_sum,
           ( CASE WHEN pct_completions_latest_year       IS NOT NULL THEN 30 ELSE 0 END +
             CASE WHEN pct_completions_trend_pct          IS NOT NULL THEN 15 ELSE 0 END +
             CASE WHEN pct_employment_weighted_openings   IS NOT NULL THEN 30 ELSE 0 END +
             CASE WHEN pct_employment_weighted_growth_pct IS NOT NULL THEN 15 ELSE 0 END +
             10                                            -- flag is never NULL
           ) AS weight_used,
           ( CASE WHEN pct_completions_latest_year       IS NOT NULL THEN 1 ELSE 0 END +
             CASE WHEN pct_completions_trend_pct          IS NOT NULL THEN 1 ELSE 0 END +
             CASE WHEN pct_employment_weighted_openings   IS NOT NULL THEN 1 ELSE 0 END +
             CASE WHEN pct_employment_weighted_growth_pct IS NOT NULL THEN 1 ELSE 0 END +
             1                                             -- flag always counts
           ) AS n_metrics_used
    FROM components
)

-- ----------------------------------------------------------------------------
-- FINAL ASSEMBLY
-- ----------------------------------------------------------------------------
SELECT d.cip2020_code,
       d.cip2020_title,
       d.already_offered_by_vanderbilt,
       w.pct_completions_latest_year,
       w.pct_completions_trend_pct,
       w.pct_employment_weighted_openings,
       w.pct_employment_weighted_growth_pct,
       w.pct_bls_top30_flag,
       w.n_metrics_used,               -- 5 = full data; less = a partial-reweight score, flagged
       ROUND((w.weighted_sum / w.weight_used)::numeric, 1) AS score
FROM derived_candidates d
JOIN weighted w USING (cip2020_code);

-- Enforce the grain: exactly one score per CIP.
ALTER TABLE scored_candidates ADD PRIMARY KEY (cip2020_code);
