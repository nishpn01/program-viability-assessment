-- ============================================================================
-- 03_verification_checks.sql
-- Join/derive (Phase 2, final step) — 3 of 5: verification checks — confirm the loaded data matches the
-- known facts from the Phase 2 data dictionary before building anything on it.
--
-- Generated with AI assistance; starter prompt in docs/ai-prompts-log.md (2.3).
--
-- Run with:  psql -p 5433 -d program_viability -f sql/03_verification_checks.sql
--
-- Concepts in this file:
--   * COUNT(*) vs COUNT(DISTINCT col): total rows vs unique values of a column.
--   * CASE WHEN ... THEN ... ELSE ... END: SQL's if/else, used here to print
--     PASS/FAIL instead of making a human compare numbers.
--   * UNION ALL: stacks the result rows of many SELECTs into one report.
--     (UNION without ALL would also de-duplicate — unnecessary work here.)
--   * Scalar subquery: (SELECT COUNT(*) FROM t) used as a single value.
-- Every check states its expected value from docs/data-dictionary.md.
-- ============================================================================

WITH checks(check_name, expected, actual) AS (
    -- row counts ------------------------------------------------------------
    SELECT 'ipeds rows',                14331, (SELECT COUNT(*) FROM ipeds_completions_masters)
    UNION ALL
    SELECT 'crosswalk rows',             6097, (SELECT COUNT(*) FROM cip_soc_crosswalk)
    UNION ALL
    SELECT 'bls openings rows',           832, (SELECT COUNT(*) FROM bls_occupational_openings)
    UNION ALL
    SELECT 'bls fastest-growing rows',     30, (SELECT COUNT(*) FROM bls_fastest_growing)
    UNION ALL
    SELECT 'bls most-new-jobs rows',       30, (SELECT COUNT(*) FROM bls_most_new_jobs)
    UNION ALL
    SELECT 'vanderbilt programs',          15, (SELECT COUNT(*) FROM vanderbilt_current_programs)

    -- key facts the derived table depends on ---------------------------------
    UNION ALL
    SELECT 'distinct CIP codes in IPEDS (candidate universe)',
           1268, (SELECT COUNT(DISTINCT cip2020_code) FROM ipeds_completions_masters)
    UNION ALL
    SELECT 'distinct SOC codes in openings',
           832,  (SELECT COUNT(DISTINCT soc_code) FROM bls_occupational_openings)
    UNION ALL
    SELECT 'distinct Vanderbilt CIP codes (15 programs share one code once)',
           14,   (SELECT COUNT(DISTINCT cip2020_code) FROM vanderbilt_current_programs)
    UNION ALL
    SELECT 'IPEDS year range spans 2012..2024',
           1,    (SELECT CASE WHEN MIN(year) = 2012 AND MAX(year) = 2024 THEN 1 ELSE 0 END
                  FROM ipeds_completions_masters)

    -- join-readiness: every IPEDS CIP must exist in the crosswalk ------------
    -- (Phase 2 already dropped the 22 unmatched CIPs; verify that held.)
    UNION ALL
    SELECT 'IPEDS CIP codes missing from crosswalk',
           0,    (SELECT COUNT(DISTINCT i.cip2020_code)
                  FROM ipeds_completions_masters i
                  WHERE NOT EXISTS (SELECT 1 FROM cip_soc_crosswalk x
                                    WHERE x.cip2020_code = i.cip2020_code))

    -- known limitation, pinned as a number so it can't drift silently:
    -- 12 of the 832 openings SOCs have no crosswalk entry (documented in ERD).
    UNION ALL
    SELECT 'openings SOC codes with no crosswalk entry (documented gap)',
           12,   (SELECT COUNT(*)
                  FROM bls_occupational_openings o
                  WHERE NOT EXISTS (SELECT 1 FROM cip_soc_crosswalk x
                                    WHERE x.soc2018_code = o.soc_code))
)
SELECT check_name,
       expected,
       actual,
       CASE WHEN expected = actual THEN 'PASS' ELSE 'FAIL' END AS status
FROM checks
ORDER BY status, check_name;
