-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 07 — SNOWFLAKE STAGES
-- ============================================================
-- Purpose:
--   Define Snowflake stages used for source-file ingestion.
--
-- Historical:
--   Divvy CSV → External Stage → COPY INTO → RAW
--
-- GBFS:
--   JSON → External Stage → Snowpipe → RAW
--
-- Azure ADLS configuration will be added during the
-- Azure integration phase.
-- ============================================================

USE DATABASE DIVVY_DB;
USE SCHEMA RAW;


-- ============================================================
-- 07.1 — HISTORICAL TRIPS STAGE
-- ============================================================
-- Azure URL / STORAGE_INTEGRATION will be configured later.

CREATE STAGE IF NOT EXISTS DIVVY_DB.RAW.STG_HISTORICAL_TRIPS
    FILE_FORMAT = DIVVY_DB.RAW.FF_DIVVY_TRIPS;


-- ============================================================
-- 07.2 — GBFS FILE FORMAT
-- ============================================================
-- GBFS is semi-structured JSON.
-- The complete JSON payload will be preserved as VARIANT
-- in RAW_GBFS.

CREATE FILE FORMAT IF NOT EXISTS DIVVY_DB.RAW.FF_GBFS_JSON
    TYPE = JSON
    STRIP_OUTER_ARRAY = FALSE;


-- ============================================================
-- 07.3 — GBFS STAGE
-- ============================================================
-- Azure URL / STORAGE_INTEGRATION will be configured later.

CREATE STAGE IF NOT EXISTS DIVVY_DB.RAW.STG_GBFS
    FILE_FORMAT = DIVVY_DB.RAW.FF_GBFS_JSON;


-- ============================================================
-- 07.4 — VERIFY STAGES
-- ============================================================

SHOW STAGES IN SCHEMA DIVVY_DB.RAW;


-- ============================================================
-- 07.5 — VERIFY FILE FORMATS
-- ============================================================

SHOW FILE FORMATS IN SCHEMA DIVVY_DB.RAW;