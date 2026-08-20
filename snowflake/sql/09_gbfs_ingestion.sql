-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 09 — GBFS INGESTION
-- ============================================================
-- Purpose:
--   Define the Snowflake-side ingestion logic for GBFS JSON.
--
-- Pipeline:
--   GBFS API
--       ↓
--   Python Extraction / Validation
--       ↓
--   Timestamped JSON
--       ↓
--   ADLS Gen2
--       ↓
--   Snowflake Stage
--       ↓
--   Snowpipe
--       ↓
--   RAW_GBFS
--
-- Azure configuration is implemented separately.
-- ============================================================

USE DATABASE DIVVY_DB;
USE SCHEMA RAW;


-- ============================================================
-- 09.1 — VERIFY GBFS STAGE
-- ============================================================

SHOW STAGES IN SCHEMA DIVVY_DB.RAW;


-- ============================================================
-- 09.2 — INSPECT GBFS FILES
-- ============================================================
-- Execute after the stage is connected to ADLS.

-- LIST @DIVVY_DB.RAW.STG_GBFS;


-- ============================================================
-- 09.3 — SNOWPIPE
-- ============================================================
-- Snowpipe automatically loads newly arriving GBFS files.
--
-- The exact COPY transformation will be finalized after
-- the physical GBFS JSON structure is verified.

-- CREATE PIPE IF NOT EXISTS DIVVY_DB.RAW.PIPE_GBFS
--     AUTO_INGEST = TRUE
-- AS
-- COPY INTO DIVVY_DB.RAW.RAW_GBFS
-- FROM @DIVVY_DB.RAW.STG_GBFS
-- FILE_FORMAT = (
--     FORMAT_NAME = DIVVY_DB.RAW.FF_GBFS_JSON
-- )
-- PATTERN = '.*\.json'
-- ON_ERROR = 'CONTINUE';


-- ============================================================
-- 09.4 — MANUAL TEST LOAD
-- ============================================================
-- Useful for initial testing before enabling automated
-- Snowpipe ingestion.

-- COPY INTO DIVVY_DB.RAW.RAW_GBFS
-- FROM @DIVVY_DB.RAW.STG_GBFS
-- FILE_FORMAT = (
--     FORMAT_NAME = DIVVY_DB.RAW.FF_GBFS_JSON
-- )
-- PATTERN = '.*\.json'
-- ON_ERROR = 'CONTINUE';


-- ============================================================
-- 09.5 — GBFS LOAD VALIDATION
-- ============================================================

-- SELECT
--     COUNT(*) AS GBFS_RECORD_COUNT
-- FROM DIVVY_DB.RAW.RAW_GBFS;


-- ============================================================
-- 09.6 — LOAD HISTORY
-- ============================================================

-- SELECT *
-- FROM TABLE(
--     INFORMATION_SCHEMA.COPY_HISTORY(
--         TABLE_NAME => 'DIVVY_DB.RAW.RAW_GBFS',
--         START_TIME => DATEADD('day', -1, CURRENT_TIMESTAMP())
--     )
-- )
-- ORDER BY LAST_LOAD_TIME DESC;