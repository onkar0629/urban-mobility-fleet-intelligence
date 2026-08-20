-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 02 — FILE FORMAT SETUP
-- ============================================================
-- Purpose:
--   Define Snowflake file formats used to interpret source data.
--
-- Formats:
--   1. Divvy historical trip CSV
--   2. Divvy GBFS JSON
-- ============================================================


USE DATABASE DIVVY_DB;


-- ============================================================
-- 02.1 — HISTORICAL TRIP CSV
-- ============================================================

CREATE FILE FORMAT IF NOT EXISTS DIVVY_DB.RAW.FF_DIVVY_TRIPS
    TYPE = CSV
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    TRIM_SPACE = TRUE
    EMPTY_FIELD_AS_NULL = TRUE
    NULL_IF = ('NULL', 'null', '')
    ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE
    ENCODING = 'UTF8';


-- ============================================================
-- 02.2 — GBFS JSON
-- ============================================================

CREATE FILE FORMAT IF NOT EXISTS DIVVY_DB.RAW.FF_GBFS_JSON
    TYPE = JSON
    STRIP_OUTER_ARRAY = FALSE
    IGNORE_UTF8_ERRORS = FALSE;


-- ============================================================
-- 02.3 — VERIFICATION
-- ============================================================

SHOW FILE FORMATS IN SCHEMA DIVVY_DB.RAW;