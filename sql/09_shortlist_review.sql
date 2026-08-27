-- ============================================================================
-- 09_shortlist_review.sql
-- Phase 3 -- shortlist stage: prepare Go/Test candidates for manual clustering
-- and the SOC 11-1021 hand-check. Read-only review, not a rebuild step.
--
-- Generated with AI assistance, as part of the Phase 3 scoring/shortlist work
-- (docs/ai-prompts-log.md, 3.1).
-- ============================================================================

-- STEP 0 -- band counts, to decide the review population (Go only, or Go + Test).
SELECT band, count(*) AS n
FROM scored_candidates
WHERE band IN ('Go', 'Test')
GROUP BY band
ORDER BY band;

-- STEP 1 -- join back to derived_candidates for matched_soc_codes and the other
-- columns scored_candidates doesn't carry. Population: Go only.
SELECT
    s.cip2020_code,
    s.cip2020_title,
    s.score,
    s.band,
    d.completions_latest_year,
    d.employment_weighted_openings,
    d.n_socs_used,
    d.matched_soc_codes
FROM scored_candidates s
JOIN derived_candidates d USING (cip2020_code)
WHERE s.band = 'Go'
ORDER BY s.score DESC;

-- STEP 2 -- flag whether matched_soc_codes contains SOC 11-1021 (same substring
-- check used in the verification notebook and the original findings report).
SELECT
    s.cip2020_code,
    s.cip2020_title,
    s.score,
    d.matched_soc_codes,
    d.matched_soc_codes LIKE '%11-1021%' AS has_soc_11_1021
FROM scored_candidates s
JOIN derived_candidates d USING (cip2020_code)
WHERE s.band = 'Go'
ORDER BY s.score DESC;

-- STEP 3 -- consolidated view: both caveats together, kept (not dropped) so each
-- candidate gets judged individually at the clustering stage. no_labor_data means
-- n_socs_used = 0 -- no crosswalk match at all, not "checked and found no demand."
SELECT
    s.cip2020_code,
    s.cip2020_title,
    s.score,
    d.completions_latest_year,
    d.employment_weighted_openings,
    d.n_socs_used,
    (d.n_socs_used = 0)                          AS no_labor_data,
    d.matched_soc_codes LIKE '%11-1021%'         AS has_soc_11_1021,
    d.matched_soc_codes
FROM scored_candidates s
JOIN derived_candidates d USING (cip2020_code)
WHERE s.band = 'Go'
ORDER BY s.score DESC;

-- STEP 4 -- same rows, sorted by title instead of score, so near-duplicate
-- program names are adjacent even when their scores aren't close.
SELECT
    s.cip2020_code,
    s.cip2020_title,
    s.score,
    d.completions_latest_year,
    d.employment_weighted_openings,
    d.n_socs_used,
    (d.n_socs_used = 0)                          AS no_labor_data,
    d.matched_soc_codes LIKE '%11-1021%'         AS has_soc_11_1021,
    d.matched_soc_codes
FROM scored_candidates s
JOIN derived_candidates d USING (cip2020_code)
WHERE s.band = 'Go'
ORDER BY s.cip2020_title;

-- STEP 5 -- export the score-sorted view for manual clustering in a spreadsheet.
\copy 
(SELECT s.cip2020_code, 
        s.cip2020_title, 
        s.score, 
        d.completions_latest_year, 
        d.employment_weighted_openings, 
        d.n_socs_used, (d.n_socs_used = 0) AS no_labor_data, 
        d.matched_soc_codes LIKE '%11-1021%' AS has_soc_11_1021, 
        d.matched_soc_codes 
        FROM scored_candidates s 
        JOIN derived_candidates d USING (cip2020_code) 
        WHERE s.band = 'Go' 
        ORDER BY s.score DESC) 
        TO 'data/derived/shortlist_review.csv' WITH (FORMAT csv, HEADER true);