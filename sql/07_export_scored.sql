-- ============================================================================
-- 07_export_scored.sql
-- Phase 3 — 2 of 2: export the scored mart to CSV.
--
-- Run from the REPO ROOT:
--   psql -p 5433 -d program_viability -f sql/07_export_scored.sql
--
-- Ordered by score DESC (this file is meant to be read top-to-bottom as a
-- ranking), with cip2020_code as a tiebreaker so reruns stay deterministic.
-- ============================================================================

\copy (SELECT * FROM scored_candidates ORDER BY score DESC, cip2020_code) TO 'data/derived/scored_candidates.csv' WITH (FORMAT csv, HEADER true);

-- Run from terminal - repo root: psql -p 5433 -d program_viability -f sql/07_export_scored.sql