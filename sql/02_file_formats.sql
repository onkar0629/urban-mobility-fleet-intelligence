-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 02 — FILE FORMAT SETUP
-- ============================================================
-- Historical Divvy trips → CSV
-- Divvy GBFS snapshots   → JSON
-- ============================================================

USE DATABASE DIVVY_DB;

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

CREATE FILE FORMAT IF NOT EXISTS DIVVY_DB.RAW.FF_GBFS_JSON
    TYPE = JSON
    STRIP_OUTER_ARRAY = FALSE
    IGNORE_UTF8_ERRORS = FALSE;

SHOW FILE FORMATS IN SCHEMA DIVVY_DB.RAW;
