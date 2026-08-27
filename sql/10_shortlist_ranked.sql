-- ============================================================================
-- 10_shortlist_ranked.sql
-- Phase 3 -- rank the clustered shortlist, one row per cluster/single, and compare
-- the ranking with vs. without the two flagged caveats. Read-only review, not a
-- rebuild step.
--
-- Generated with AI assistance, downstream of the clustering step
-- (docs/ai-prompts-log.md, 3.4).
--
-- PREREQUISITE: data/derived/shortlist_review_clustered.csv must already exist
-- (built by `scripts/cluster_shortlist_titles.py`, which itself runs on the output
-- of `sql/09_shortlist_review.sql`). This file loads that CSV back into Postgres --
-- clustering itself is a text-similarity operation done in Python, not SQL, so this
-- is the point where its output rejoins the database.
--
-- Run from the REPO ROOT:
--   psql -p 5433 -d program_viability -f sql/10_shortlist_ranked.sql
-- ============================================================================

-- STEP 0 -- load the clustered CSV into a staging table. Rerunnable: drops first.
DROP TABLE IF EXISTS shortlist_clustered;

CREATE TABLE shortlist_clustered (
    cip2020_code                  text,
    cip2020_title                 text,
    score                         numeric(5,1),
    completions_latest_year       numeric,
    employment_weighted_openings  numeric,
    n_socs_used                   integer,
    no_labor_data                 boolean,
    has_soc_11_1021               boolean,
    matched_soc_codes             text,
    algo_cluster_id               text,
    algo_cluster_size             integer
);

\copy shortlist_clustered FROM 'data/derived/shortlist_review_clustered.csv' WITH (FORMAT csv, HEADER true);

-- PATCH -- cluster-1 (the 13-member Nursing cluster) is excluded
-- below via `algo_cluster_id != 'cluster-1'`, added to every `representatives` CTE.
-- Found while naming the finalists: Family Practice Nurse/Nursing (51.3805, the #2
-- finalist at the time) is actually "Family Nurse Practitioner," an existing named
-- specialty under Vanderbilt's current online MSN (confirmed against the Registrar's
-- CIP list, docs/planning/CIP_Codes.pdf, and confirmed the specialty is genuinely
-- delivered online, not just on-campus). 7 of the cluster's 13 members matched a named
-- Vanderbilt Nursing track exactly; the other 6 didn't, but the whole cluster is
-- excluded anyway rather than only the 7 confirmed matches -- the root cause is that
-- `data/raw/vanderbilt_current_programs.csv` recorded Vanderbilt's MSN as ONE catalog
-- row instead of one row per specialty, so the unmatched 6 can't be trusted as
-- genuinely new either; we only know the data is incomplete for this cluster, not
-- that it's complete for the rest of it.
--
-- This is a shortlist-stage patch, not a real fix -- the actual fix belongs upstream,
-- in the raw Vanderbilt catalog data and a full rebuild of sql/04 through this file.
-- Logged as future scope (docs/decisions-log.md, Step 17) rather than done immediately.

-- STEP 1 -- representative row per cluster: the max-scoring member. Decision (locked,
-- see docs/decisions-log.md Step 16): a cluster's ranking unit is its single strongest specific program, not
-- an average across the cluster -- the cluster's mean/min are kept as supporting
-- narrative evidence, not the ranking number itself. See decisions-log.md.
WITH ranked_within_cluster AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY algo_cluster_id ORDER BY score DESC) AS rn
    FROM shortlist_clustered
),
representatives AS (
    SELECT
        cip2020_code, cip2020_title, score, algo_cluster_id, algo_cluster_size,
        no_labor_data, has_soc_11_1021
    FROM ranked_within_cluster
    WHERE rn = 1 AND algo_cluster_id != 'cluster-1'   -- patch, see comment above STEP 1
)
SELECT *
FROM representatives
ORDER BY score DESC;

-- STEP 2 -- same ranking, but excluding any representative that itself carries either
-- caveat flag (has_soc_11_1021 or no_labor_data). This is the "clean" comparison view
-- -- run alongside Step 1 to see exactly which candidates move, and by how much.
WITH ranked_within_cluster AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY algo_cluster_id ORDER BY score DESC) AS rn
    FROM shortlist_clustered
),
representatives AS (
    SELECT
        cip2020_code, cip2020_title, score, algo_cluster_id, algo_cluster_size,
        no_labor_data, has_soc_11_1021
    FROM ranked_within_cluster
    WHERE rn = 1 AND algo_cluster_id != 'cluster-1'   -- patch, see comment above STEP 1
)
SELECT *
FROM representatives
WHERE NOT has_soc_11_1021 AND NOT no_labor_data
ORDER BY score DESC;

-- STEP 3 -- side-by-side: top 10 of each view, labeled, so the difference is visible
-- in one result set instead of switching between Step 1 and Step 2.
WITH ranked_within_cluster AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY algo_cluster_id ORDER BY score DESC) AS rn
    FROM shortlist_clustered
),
representatives AS (
    SELECT
        cip2020_code, cip2020_title, score, algo_cluster_id, algo_cluster_size,
        no_labor_data, has_soc_11_1021
    FROM ranked_within_cluster
    WHERE rn = 1 AND algo_cluster_id != 'cluster-1'   -- patch, see comment above STEP 1
),
all_ranked AS (
    SELECT 'all (with flags)' AS view, ROW_NUMBER() OVER (ORDER BY score DESC) AS rank,
           cip2020_code, cip2020_title, score, has_soc_11_1021, no_labor_data
    FROM representatives
),
clean_ranked AS (
    SELECT 'clean (flags excluded)' AS view, ROW_NUMBER() OVER (ORDER BY score DESC) AS rank,
           cip2020_code, cip2020_title, score, has_soc_11_1021, no_labor_data
    FROM representatives
    WHERE NOT has_soc_11_1021 AND NOT no_labor_data
)
SELECT * FROM all_ranked WHERE rank <= 10
UNION ALL
SELECT * FROM clean_ranked WHERE rank <= 10
ORDER BY view, rank;

-- STEP 4 -- export both full rankings for reference / re-review outside SQL.
\copy (WITH ranked_within_cluster AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY algo_cluster_id ORDER BY score DESC) AS rn FROM shortlist_clustered), representatives AS (SELECT cip2020_code, cip2020_title, score, algo_cluster_id, algo_cluster_size, no_labor_data, has_soc_11_1021 FROM ranked_within_cluster WHERE rn = 1 AND algo_cluster_id != 'cluster-1') SELECT * FROM representatives ORDER BY score DESC) TO 'data/derived/shortlist_ranked.csv' WITH (FORMAT csv, HEADER true);

\copy (WITH ranked_within_cluster AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY algo_cluster_id ORDER BY score DESC) AS rn FROM shortlist_clustered), representatives AS (SELECT cip2020_code, cip2020_title, score, algo_cluster_id, algo_cluster_size, no_labor_data, has_soc_11_1021 FROM ranked_within_cluster WHERE rn = 1 AND algo_cluster_id != 'cluster-1') SELECT * FROM representatives WHERE NOT has_soc_11_1021 AND NOT no_labor_data ORDER BY score DESC) TO 'data/derived/shortlist_ranked_clean.csv' WITH (FORMAT csv, HEADER true);
