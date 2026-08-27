-- ============================================================================
-- 05_export.sql
-- Join/derive (Phase 2, final step) — 5 of 5: export the analysis mart to CSV for downstream use
-- (docs/data-dictionary.md "Analysis marts" layer; Tableau input in Phase 4).
--
-- Generated with AI assistance; starter prompt in docs/ai-prompts-log.md (2.3).
--
-- Run from the REPO ROOT:
--   psql -p 5433 -d program_viability -f sql/05_export.sql
--
-- \copy ... TO is the mirror image of the loads in 02: it streams query
-- results out of the server into a client-side file. ORDER BY makes the file
-- deterministic so reruns produce identical diffs in git.
-- ============================================================================

\copy (SELECT * FROM derived_candidates ORDER BY cip2020_code) TO 'data/derived/derived_candidates.csv' WITH (FORMAT csv, HEADER true);
