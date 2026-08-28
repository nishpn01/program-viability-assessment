-- ============================================================================
-- 08_score_bands.sql
-- Phase 3, 3 of 3: set Go/Test/Pass band cutoffs from the real score
-- distribution, then write the band back onto scored_candidates.
--
-- Generated with AI assistance; starter prompt in docs/ai-prompts-log.md (3.3).
-- ============================================================================

-- STEP 0 -- define the population: exclude the 14 CIPs Vanderbilt already offers.
-- FILTER (WHERE ...) on an aggregate counts only the matching rows, in one query.
SELECT
    count(*) AS total_rows,
    count(*) FILTER (WHERE NOT already_offered_by_vanderbilt) AS candidate_pool,
    count(*) FILTER (WHERE already_offered_by_vanderbilt)     AS already_offered
FROM scored_candidates;

-- STEP 1 -- five-number summary + percentiles on score, population only.
-- PERCENTILE_CONT is an aggregate (like MIN/MAX/AVG), not a window function
-- like PERCENT_RANK in 06. Returns double precision even though score is
-- NUMERIC, so ROUND still needs ::numeric here.
SELECT
    round(min(score), 1) AS min,
    round(avg(score), 1) AS mean,
    round((percentile_cont(0.10) WITHIN GROUP (ORDER BY score))::numeric, 1) AS p10,
    round((percentile_cont(0.25) WITHIN GROUP (ORDER BY score))::numeric, 1) AS p25,
    round((percentile_cont(0.50) WITHIN GROUP (ORDER BY score))::numeric, 1) AS median,
    round((percentile_cont(0.75) WITHIN GROUP (ORDER BY score))::numeric, 1) AS p75,
    round((percentile_cont(0.90) WITHIN GROUP (ORDER BY score))::numeric, 1) AS p90,
    round((percentile_cont(0.95) WITHIN GROUP (ORDER BY score))::numeric, 1) AS p95,
    round((percentile_cont(0.99) WITHIN GROUP (ORDER BY score))::numeric, 1) AS p99,
    round(max(score), 1) AS max
FROM scored_candidates
WHERE NOT already_offered_by_vanderbilt;

-- STEP 2 -- top and bottom 15 by score.
SELECT cip2020_code, cip2020_title, n_metrics_used, score
FROM scored_candidates
WHERE NOT already_offered_by_vanderbilt
ORDER BY score DESC
LIMIT 15;

SELECT cip2020_code, cip2020_title, n_metrics_used, score
FROM scored_candidates
WHERE NOT already_offered_by_vanderbilt
ORDER BY score ASC
LIMIT 15;

-- STEP 3 -- bucket scores into 10 ranges, check for a cliff.
SELECT width_bucket(score, 0, 100, 10) AS bucket, count(*) AS n
FROM scored_candidates
WHERE NOT already_offered_by_vanderbilt
GROUP BY 1
ORDER BY 1;

-- STEP 4 -- apply the locked cutoffs (p90 = 75.3, median = 45.7 from Step 1)
-- and count candidates per band.
SELECT
    CASE
        WHEN score >= 75.3 THEN 'Go'
        WHEN score >= 45.7 THEN 'Test'
        ELSE 'Pass'
    END AS band,
    count(*) AS n
FROM scored_candidates
WHERE NOT already_offered_by_vanderbilt
GROUP BY 1
ORDER BY min(score) DESC;

-- STEP 5 -- persist the band onto scored_candidates. The 14 already-offered
-- rows are left NULL here (not "Pass") -- they were never in the decision to
-- begin with, so a band would misrepresent them as considered and rejected.
ALTER TABLE scored_candidates ADD COLUMN IF NOT EXISTS band TEXT;

UPDATE scored_candidates
SET band = CASE
    WHEN score >= 75.3 THEN 'Go'
    WHEN score >= 45.7 THEN 'Test'
    ELSE 'Pass'
END
WHERE NOT already_offered_by_vanderbilt;

--query check
SELECT band, count(*) FROM scored_candidates GROUP BY band;