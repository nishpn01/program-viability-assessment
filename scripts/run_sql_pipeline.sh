#!/usr/bin/env bash
# ============================================================================
# run_sql_pipeline.sh — rebuild the Phase 3 SQL pipeline end to end.
#
# Generated with AI assistance; starter prompt in docs/ai-prompts-log.md (2.3).
#
# Usage (from anywhere):  bash scripts/run_sql_pipeline.sh
#
# Prereqs: Homebrew postgresql@18 running on port 5433 (starts on login via
# launchd; if down: brew services start postgresql@18) and a database named
# program_viability (once: createdb -p 5433 program_viability).
#
# set -e  → stop at the first error instead of plowing on with bad data.
# cd to the repo root → the \copy paths in 02 and 05 are relative to it.
# ============================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

PSQL="psql -p 5433 -d program_viability -v ON_ERROR_STOP=1"

for f in sql/01_create_tables.sql \
         sql/02_load_data.sql \
         sql/03_verification_checks.sql \
         sql/04_build_derived_candidates.sql \
         sql/05_export.sql; do
    echo "=== running $f ==="
    $PSQL -f "$f"
done

echo "=== pipeline complete: data/derived/derived_candidates.csv ==="
