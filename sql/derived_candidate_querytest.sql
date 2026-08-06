-- 1. Feel the mart: biggest fields Vanderbilt doesn't offer
SELECT cip2020_title, completions_latest_year, employment_weighted_openings
FROM derived_candidates
WHERE NOT already_offered_by_vanderbilt
ORDER BY completions_latest_year DESC
LIMIT 20;

-- 2. Growing fields with strong labor demand (a preview of scoring)
SELECT cip2020_title, completions_trend_pct, employment_weighted_growth_pct
FROM derived_candidates
WHERE completions_trend_pct > 50
  AND employment_weighted_growth_pct > 10
  AND NOT already_offered_by_vanderbilt
ORDER BY employment_weighted_growth_pct DESC;

-- 3. Rebuild one CTE alone to see a window function work
SELECT cip2020_code, year, completions,
       ROW_NUMBER() OVER (PARTITION BY cip2020_code ORDER BY year DESC) AS rn
FROM ipeds_completions_masters
WHERE cip2020_code = 30.7001;

-- 4. Verify a flag by hand: which top-30 occupation triggered Data Science?
SELECT soc_code, occupation_title FROM bls_most_new_jobs
WHERE soc_code IN ('15-1252','11-3021','15-2051');