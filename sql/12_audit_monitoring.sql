-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 12 — AUDIT & MONITORING
-- ============================================================
-- Operational monitoring queries for pipeline runs, data-quality
-- results, Snowflake load history, Snowpipe, streams and tasks.
-- This file is read-only except for no object-creation operations.
-- ============================================================

USE DATABASE DIVVY_DB;

-- ============================================================
-- 12.1 — RECENT PIPELINE RUNS
-- ============================================================

SELECT
    PIPELINE_RUN_ID,
    PIPELINE_NAME,
    SOURCE_SYSTEM,
    START_TIME,
    END_TIME,
    STATUS,
    RECORDS_PROCESSED,
    RECORDS_REJECTED,
    ERROR_MESSAGE
FROM DIVVY_DB.AUDIT.PIPELINE_RUN
ORDER BY START_TIME DESC
LIMIT 20;

-- ============================================================
-- 12.2 — DATA QUALITY MONITORING
-- ============================================================

SELECT
    CHECK_ID,
    CHECK_NAME,
    LAYER,
    OBJECT_NAME,
    CHECK_TIME,
    STATUS,
    RECORDS_CHECKED,
    RECORDS_FAILED,
    DETAILS
FROM DIVVY_DB.AUDIT.DATA_QUALITY_RESULT
ORDER BY CHECK_TIME DESC
LIMIT 50;

-- ============================================================
-- 12.3 — FAILED QUALITY CHECKS
-- ============================================================

SELECT *
FROM DIVVY_DB.AUDIT.DATA_QUALITY_RESULT
WHERE STATUS = 'FAIL'
ORDER BY CHECK_TIME DESC;

-- ============================================================
-- 12.4 — HISTORICAL LOAD HISTORY
-- ============================================================

SELECT
    FILE_NAME,
    TABLE_NAME,
    STATUS,
    ROW_COUNT,
    ROW_PARSED,
    FIRST_ERROR_MESSAGE,
    LAST_LOAD_TIME
FROM TABLE
(
    INFORMATION_SCHEMA.COPY_HISTORY
    (
        TABLE_NAME => 'DIVVY_DB.RAW.RAW_TRIPS',
        START_TIME => DATEADD('day', -7, CURRENT_TIMESTAMP())
    )
)
ORDER BY LAST_LOAD_TIME DESC;

-- ============================================================
-- 12.5 — GBFS PIPE STATUS
-- ============================================================

SELECT SYSTEM$PIPE_STATUS('DIVVY_DB.RAW.PIPE_GBFS') AS PIPE_STATUS;

-- ============================================================
-- 12.6 — GBFS STREAM STATE
-- ============================================================

SELECT
    SYSTEM$STREAM_HAS_DATA('DIVVY_DB.RAW.STR_RAW_GBFS') AS STREAM_HAS_DATA;

-- ============================================================
-- 12.7 — TASK STATUS
-- ============================================================

SHOW TASKS IN SCHEMA DIVVY_DB.AUDIT;

-- ============================================================
-- 12.8 — TASK EXECUTION HISTORY
-- ============================================================

SELECT
    NAME,
    STATE,
    SCHEDULED_TIME,
    QUERY_START_TIME,
    COMPLETED_TIME,
    ERROR_CODE,
    ERROR_MESSAGE
FROM TABLE
(
    INFORMATION_SCHEMA.TASK_HISTORY
    (
        TASK_NAME => 'DIVVY_DB.AUDIT.TASK_GBFS_PIPELINE',
        SCHEDULED_TIME_RANGE_START => DATEADD('day', -7, CURRENT_TIMESTAMP())
    )
)
ORDER BY SCHEDULED_TIME DESC;

-- ============================================================
-- 12.9 — CURRENT ROW COUNTS
-- ============================================================

SELECT 'RAW_TRIPS' AS OBJECT_NAME, COUNT(*) AS ROW_COUNT
FROM DIVVY_DB.RAW.RAW_TRIPS
UNION ALL
SELECT 'RAW_GBFS', COUNT(*)
FROM DIVVY_DB.RAW.RAW_GBFS
UNION ALL
SELECT 'STG_TRIPS', COUNT(*)
FROM DIVVY_DB.STAGING.STG_TRIPS
UNION ALL
SELECT 'STG_STATION_STATUS', COUNT(*)
FROM DIVVY_DB.STAGING.STG_STATION_STATUS
UNION ALL
SELECT 'STG_VEHICLE_STATUS', COUNT(*)
FROM DIVVY_DB.STAGING.STG_VEHICLE_STATUS
UNION ALL
SELECT 'FACT_TRIP', COUNT(*)
FROM DIVVY_DB.CORE.FACT_TRIP
UNION ALL
SELECT 'FACT_STATION_STATUS', COUNT(*)
FROM DIVVY_DB.CORE.FACT_STATION_STATUS
UNION ALL
SELECT 'FACT_VEHICLE_STATUS', COUNT(*)
FROM DIVVY_DB.CORE.FACT_VEHICLE_STATUS
ORDER BY OBJECT_NAME;
