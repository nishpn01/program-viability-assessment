-- ============================================================================
-- 02_load_data.sql
-- Join/derive (Phase 2, final step), 2 of 5: load the six cleaned CSVs into the staging tables.
--
-- Generated with AI assistance; starter prompt in docs/ai-prompts-log.md (2.3).
--
-- Run from the REPO ROOT (paths below are relative):
--   psql -p 5433 -d program_viability -f sql/02_load_data.sql
--
-- Concepts in this file:
--   * \copy is a psql CLIENT command: it reads the file from this machine and
--     streams rows to the server. Plain SQL COPY reads from the SERVER's own
--     filesystem, which matters on remote databases. BigQuery's equivalent is
--     `bq load`.
--   * WITH (FORMAT csv, HEADER true): parse as CSV (handles quoted commas)
--     and skip the first (header) row.
--   * TRUNCATE first so the script is re-runnable without duplicating rows.
--   * Because 01_create_tables.sql declared types and primary keys, this load
--     doubles as validation: a bad value or duplicate key aborts with an error
--     instead of loading silently corrupted data.
-- ============================================================================

TRUNCATE ipeds_completions_masters,
         cip_soc_crosswalk,
         bls_occupational_openings,
         bls_fastest_growing,
         bls_most_new_jobs,
         vanderbilt_current_programs;

\copy ipeds_completions_masters   FROM 'data/clean/ipeds_completions_masters_clean.csv'   WITH (FORMAT csv, HEADER true);
\copy cip_soc_crosswalk           FROM 'data/clean/cip_soc_crosswalk_clean.csv'           WITH (FORMAT csv, HEADER true);
\copy bls_occupational_openings   FROM 'data/clean/bls_occupational_openings_clean.csv'   WITH (FORMAT csv, HEADER true);
\copy bls_fastest_growing         FROM 'data/clean/bls_fastest_growing_clean.csv'         WITH (FORMAT csv, HEADER true);
\copy bls_most_new_jobs           FROM 'data/clean/bls_most_new_jobs_clean.csv'           WITH (FORMAT csv, HEADER true);
\copy vanderbilt_current_programs FROM 'data/clean/vanderbilt_current_programs_clean.csv' WITH (FORMAT csv, HEADER true);
