-- ============================================================================
-- 01_create_tables.sql
-- Join/derive (Phase 2, final step) — 1 of 5: define the six staging tables that mirror data/clean/*.csv
--
-- Run with:  psql -p 5433 -d program_viability -f sql/01_create_tables.sql
--
-- Concepts in this file:
--   * DDL (Data Definition Language): CREATE/DROP TABLE — defines table shape.
--   * Types: TEXT (string), INTEGER (whole number), NUMERIC (exact decimal).
--     NUMERIC is used instead of FLOAT/REAL everywhere because floats cannot
--     represent most decimals exactly (51.2706 becomes 51.27059999…), which
--     makes equality joins silently drop rows. NUMERIC(7,4) = up to 7 digits
--     total, 4 after the decimal point — exactly fits CIP codes like 51.2706.
--   * PRIMARY KEY: enforces the table's grain (what one row means). A duplicate
--     key on load is an error, so the grain documented in the data dictionary
--     is enforced by the database.
--   * DROP TABLE IF EXISTS ... CASCADE: makes this script re-runnable from
--     scratch (idempotent). CASCADE also drops anything built on top.
-- ============================================================================

-- Drop in reverse dependency order so re-runs start clean.
DROP TABLE IF EXISTS derived_candidates            CASCADE;
DROP TABLE IF EXISTS vanderbilt_current_programs   CASCADE;
DROP TABLE IF EXISTS bls_most_new_jobs             CASCADE;
DROP TABLE IF EXISTS bls_fastest_growing           CASCADE;
DROP TABLE IF EXISTS bls_occupational_openings     CASCADE;
DROP TABLE IF EXISTS cip_soc_crosswalk             CASCADE;
DROP TABLE IF EXISTS ipeds_completions_masters     CASCADE;

-- ----------------------------------------------------------------------------
-- IPEDS: national master's completions per field of study per year.
-- Grain: one row per CIP6 code per year (2012–2024, suppressed years absent).
-- 14,331 rows expected.
-- ----------------------------------------------------------------------------
CREATE TABLE ipeds_completions_masters (
    cip6_id       INTEGER       NOT NULL,  -- raw IPEDS integer form of the CIP code (e.g. 10000)
    cip6_title    TEXT          NOT NULL,
    year          INTEGER       NOT NULL,
    completions   NUMERIC       NOT NULL,  -- degree completions that year (national)
    cip2020_code  NUMERIC(7,4)  NOT NULL,  -- normalized CIP code (e.g. 1.0000, 51.2706)
    PRIMARY KEY (cip2020_code, year)       -- grain: CIP × year
);

-- ----------------------------------------------------------------------------
-- Crosswalk: which occupations (SOC) each field of study (CIP) feeds into.
-- This is a junction table — a many-to-many mapping.
-- Grain: one row per CIP–SOC pair. 6,097 rows expected.
-- ----------------------------------------------------------------------------
CREATE TABLE cip_soc_crosswalk (
    cip2020_code   NUMERIC(7,4)  NOT NULL,
    cip2020_title  TEXT          NOT NULL,
    soc2018_code   TEXT          NOT NULL,  -- SOC codes are identifiers like '19-1011', never math → TEXT
    soc2018_title  TEXT          NOT NULL,
    PRIMARY KEY (cip2020_code, soc2018_code)  -- grain: the pair
);

-- ----------------------------------------------------------------------------
-- BLS Table 1.10: employment projections for every detailed occupation.
-- Grain: one row per SOC code. 832 rows expected. NOTE: no wage column exists
-- in this table — wages only exist in the two 30-row ranked tables below.
-- ----------------------------------------------------------------------------
CREATE TABLE bls_occupational_openings (
    occupation_title                    TEXT     NOT NULL,
    soc_code                            TEXT     NOT NULL PRIMARY KEY,
    occupation_type                     TEXT     NOT NULL,  -- constant 'Line item' after cleaning
    employment_2024                     NUMERIC,            -- thousands of jobs
    employment_2034                     NUMERIC,
    employment_change_numeric_2024_34   NUMERIC,
    employment_change_percent_2024_34   NUMERIC,
    labor_force_exit_rate_2024_34       NUMERIC,
    occupational_transfer_rate_2024_34  NUMERIC,
    total_separations_rate_2024_34      NUMERIC,
    labor_force_exits_2024_34           NUMERIC,
    occupational_transfers_2024_34      NUMERIC,
    total_separations_2024_34           NUMERIC,
    occupational_openings_2024_34       NUMERIC             -- avg annual openings, thousands
);

-- ----------------------------------------------------------------------------
-- BLS Table 1.3: the 30 fastest-growing occupations (by % growth).
-- Grain: one row per SOC code. 30 rows expected. Has wages.
-- ----------------------------------------------------------------------------
CREATE TABLE bls_fastest_growing (
    occupation_title                   TEXT     NOT NULL,
    soc_code                           TEXT     NOT NULL PRIMARY KEY,
    employment_2024                    NUMERIC,
    employment_2034                    NUMERIC,
    employment_change_numeric_2024_34  NUMERIC,
    employment_change_percent_2024_34  NUMERIC,
    median_annual_wage_2024            NUMERIC
);

-- ----------------------------------------------------------------------------
-- BLS Table 1.4: the 30 occupations adding the most new jobs (by count).
-- Same shape as bls_fastest_growing. 30 rows expected.
-- ----------------------------------------------------------------------------
CREATE TABLE bls_most_new_jobs (
    occupation_title                   TEXT     NOT NULL,
    soc_code                           TEXT     NOT NULL PRIMARY KEY,
    employment_2024                    NUMERIC,
    employment_2034                    NUMERIC,
    employment_change_numeric_2024_34  NUMERIC,
    employment_change_percent_2024_34  NUMERIC,
    median_annual_wage_2024            NUMERIC
);

-- ----------------------------------------------------------------------------
-- Vanderbilt's current online graduate catalog (Master's + Doctorate).
-- Grain: one row per program. 15 rows expected — note only 14 DISTINCT
-- cip2020_code values: two M.Ed. programs legitimately share 13.0401
-- (verified against the official registrar list in docs/planning/CIP_Codes.pdf).
-- That is why cip2020_code is NOT the primary key here.
-- ----------------------------------------------------------------------------
CREATE TABLE vanderbilt_current_programs (
    program_name           TEXT          NOT NULL PRIMARY KEY,
    school                 TEXT          NOT NULL,
    level                  TEXT          NOT NULL,
    format                 TEXT          NOT NULL,
    credits_or_duration    TEXT,
    price_raw              TEXT,
    program_url            TEXT,
    total_price_estimated  NUMERIC,
    cip2020_code           NUMERIC(7,4)  NOT NULL,
    cip2020_code_source    TEXT          NOT NULL
);
