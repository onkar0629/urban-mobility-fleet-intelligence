-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 08 — HISTORICAL INGESTION
-- ============================================================
-- Purpose:
--   Load Divvy historical trip files into RAW_TRIPS.
--
-- Pipeline:
--   ADLS → Snowflake Stage → COPY INTO → RAW_TRIPS
--
-- Current implementation:
--   Azure ADLS connection will be configured later.
-- ============================================================

USE DATABASE DIVVY_DB;
USE SCHEMA RAW;


-- ============================================================
-- 08.1 — VERIFY HISTORICAL STAGE
-- ============================================================

SHOW STAGES IN SCHEMA DIVVY_DB.RAW;


-- ============================================================
-- 08.2 — INSPECT HISTORICAL FILES
-- ============================================================
-- Execute after the stage is connected to ADLS.

-- LIST @DIVVY_DB.RAW.STG_HISTORICAL_TRIPS;


-- ============================================================
-- 08.3 — HISTORICAL COPY INTO
-- ============================================================
-- Execute after Azure ADLS integration is configured.
--
-- The COPY operation loads source data into RAW_TRIPS
-- while preserving source-file information for traceability.

-- COPY INTO DIVVY_DB.RAW.RAW_TRIPS
-- FROM @DIVVY_DB.RAW.STG_HISTORICAL_TRIPS
-- FILE_FORMAT = (
--     FORMAT_NAME = DIVVY_DB.RAW.FF_DIVVY_TRIPS
-- )
-- PATTERN = '.*\.csv'
-- ON_ERROR = 'ABORT_STATEMENT';


-- ============================================================
-- 08.4 — LOAD VALIDATION
-- ============================================================

-- SELECT COUNT(*) AS RAW_TRIPS_COUNT
-- FROM DIVVY_DB.RAW.RAW_TRIPS;


-- ============================================================
-- 08.5 — LOAD HISTORY
-- ============================================================

-- SELECT *
-- FROM TABLE(
--     INFORMATION_SCHEMA.COPY_HISTORY(
--         TABLE_NAME => 'DIVVY_DB.RAW.RAW_TRIPS',
--         START_TIME => DATEADD('day', -1, CURRENT_TIMESTAMP())
--     )
-- )
-- ORDER BY LAST_LOAD_TIME DESC;