-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 09 — GBFS INGESTION
-- ============================================================
-- Python handles API extraction/validation; Snowflake handles ingestion.
-- Azure/Snowpipe configuration is added after the Azure phase.

USE DATABASE DIVVY_DB;
USE SCHEMA RAW;

SHOW STAGES IN SCHEMA DIVVY_DB.RAW;

-- LIST @DIVVY_DB.RAW.STG_GBFS;

-- CREATE PIPE IF NOT EXISTS DIVVY_DB.RAW.PIPE_GBFS
--     AUTO_INGEST = TRUE
-- AS
-- COPY INTO DIVVY_DB.RAW.RAW_GBFS
-- FROM @DIVVY_DB.RAW.STG_GBFS
-- FILE_FORMAT = (FORMAT_NAME = DIVVY_DB.RAW.FF_GBFS_JSON)
-- PATTERN = '.*\\.json'
-- ON_ERROR = 'CONTINUE';

-- COPY INTO DIVVY_DB.RAW.RAW_GBFS
-- FROM @DIVVY_DB.RAW.STG_GBFS
-- FILE_FORMAT = (FORMAT_NAME = DIVVY_DB.RAW.FF_GBFS_JSON)
-- PATTERN = '.*\\.json'
-- ON_ERROR = 'CONTINUE';

-- SELECT COUNT(*) AS GBFS_RECORD_COUNT
-- FROM DIVVY_DB.RAW.RAW_GBFS;
