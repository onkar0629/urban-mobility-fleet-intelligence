-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 13 — VALIDATION QUERIES
-- ============================================================
-- Purpose:
--   End-to-end validation of the Snowflake data pipeline.
--
-- Layers:
--   RAW → STAGING → CORE → MART
--
-- Validation areas:
--   - Object existence
--   - Row counts
--   - Null checks
--   - Duplicate checks
--   - Date/time validity
--   - Referential integrity
--   - Reconciliation
--   - Pipeline audit status
-- ============================================================

USE DATABASE DIVVY_DB;


-- ============================================================
-- 13.1 — DATABASE OBJECT VALIDATION
-- ============================================================

SHOW SCHEMAS IN DATABASE DIVVY_DB;

SHOW TABLES IN SCHEMA DIVVY_DB.RAW;

SHOW TABLES IN SCHEMA DIVVY_DB.STAGING;

SHOW TABLES IN SCHEMA DIVVY_DB.CORE;

SHOW TABLES IN SCHEMA DIVVY_DB.MART;

SHOW TABLES IN SCHEMA DIVVY_DB.AUDIT;


-- ============================================================
-- 13.2 — ROW COUNT SUMMARY
-- ============================================================

SELECT 'RAW_TRIPS' AS TABLE_NAME,
       COUNT(*) AS ROW_COUNT
FROM DIVVY_DB.RAW.RAW_TRIPS

UNION ALL

SELECT 'STG_TRIPS',
       COUNT(*)
FROM DIVVY_DB.STAGING.STG_TRIPS

UNION ALL

SELECT 'FACT_TRIP',
       COUNT(*)
FROM DIVVY_DB.CORE.FACT_TRIP;


-- ============================================================
-- 13.3 — RAW TRIPS NULL CHECK
-- ============================================================

SELECT
    COUNT(*) AS TOTAL_ROWS,
    COUNT_IF(RIDE_ID IS NULL) AS NULL_RIDE_ID,
    COUNT_IF(STARTED_AT IS NULL) AS NULL_STARTED_AT,
    COUNT_IF(ENDED_AT IS NULL) AS NULL_ENDED_AT,
    COUNT_IF(MEMBER_CASUAL IS NULL) AS NULL_MEMBER_CASUAL
FROM DIVVY_DB.RAW.RAW_TRIPS;


-- ============================================================
-- 13.4 — DUPLICATE RIDE CHECK
-- ============================================================

SELECT
    RIDE_ID,
    COUNT(*) AS DUPLICATE_COUNT
FROM DIVVY_DB.RAW.RAW_TRIPS
WHERE RIDE_ID IS NOT NULL
GROUP BY RIDE_ID
HAVING COUNT(*) > 1
ORDER BY DUPLICATE_COUNT DESC;


-- ============================================================
-- 13.5 — INVALID TRIP DURATION
-- ============================================================

SELECT
    COUNT(*) AS INVALID_DURATION_COUNT
FROM DIVVY_DB.STAGING.STG_TRIPS
WHERE TRIP_DURATION_MINUTES < 0
   OR TRIP_DURATION_MINUTES IS NULL;


-- ============================================================
-- 13.6 — INVALID TIMESTAMPS
-- ============================================================

SELECT
    COUNT(*) AS INVALID_TIMESTAMP_COUNT
FROM DIVVY_DB.STAGING.STG_TRIPS
WHERE STARTED_AT IS NULL
   OR ENDED_AT IS NULL
   OR ENDED_AT < STARTED_AT;


-- ============================================================
-- 13.7 — INVALID COORDINATES
-- ============================================================

SELECT
    COUNT(*) AS INVALID_COORDINATE_COUNT
FROM DIVVY_DB.STAGING.STG_TRIPS
WHERE (START_LAT IS NOT NULL
       AND (START_LAT < -90 OR START_LAT > 90))
   OR (START_LNG IS NOT NULL
       AND (START_LNG < -180 OR START_LNG > 180))
   OR (END_LAT IS NOT NULL
       AND (END_LAT < -90 OR END_LAT > 90))
   OR (END_LNG IS NOT NULL
       AND (END_LNG < -180 OR END_LNG > 180));


-- ============================================================
-- 13.8 — FACT TRIP REFERENTIAL INTEGRITY
-- ============================================================

SELECT
    COUNT(*) AS INVALID_START_STATION_KEYS
FROM DIVVY_DB.CORE.FACT_TRIP F
LEFT JOIN DIVVY_DB.CORE.DIM_STATION S
    ON F.START_STATION_KEY = S.STATION_KEY
WHERE F.START_STATION_KEY IS NOT NULL
  AND S.STATION_KEY IS NULL;


-- ============================================================
-- 13.9 — RAW → STAGING RECONCILIATION
-- ============================================================

SELECT
    (SELECT COUNT(*)
     FROM DIVVY_DB.RAW.RAW_TRIPS) AS RAW_COUNT,

    (SELECT COUNT(*)
     FROM DIVVY_DB.STAGING.STG_TRIPS) AS STAGING_COUNT;


-- ============================================================
-- 13.10 — STAGING → CORE RECONCILIATION
-- ============================================================

SELECT
    (SELECT COUNT(*)
     FROM DIVVY_DB.STAGING.STG_TRIPS
     WHERE IS_VALID_TIMESTAMP = TRUE
       AND IS_VALID_DURATION = TRUE) AS VALID_STAGING_COUNT,

    (SELECT COUNT(*)
     FROM DIVVY_DB.CORE.FACT_TRIP) AS CORE_COUNT;


-- ============================================================
-- 13.11 — CORE → MART VALIDATION
-- ============================================================

SELECT 'MART_OPERATIONS' AS TABLE_NAME,
       COUNT(*) AS ROW_COUNT
FROM DIVVY_DB.MART.MART_OPERATIONS

UNION ALL

SELECT 'MART_STATION',
       COUNT(*)
FROM DIVVY_DB.MART.MART_STATION

UNION ALL

SELECT 'MART_RIDER',
       COUNT(*)
FROM DIVVY_DB.MART.MART_RIDER

UNION ALL

SELECT 'MART_FLEET',
       COUNT(*)
FROM DIVVY_DB.MART.MART_FLEET;

-- ============================================================
-- 13.12 — LATEST INGESTION
-- ============================================================

SELECT
    MAX(INGESTION_TIMESTAMP) AS LAST_INGESTION_TIME
FROM DIVVY_DB.RAW.RAW_TRIPS;


-- ============================================================
-- 13.13 — FAILED PIPELINE RUNS
-- ============================================================

SELECT *
FROM DIVVY_DB.AUDIT.VW_PIPELINE_FAILURES
ORDER BY START_TIME DESC;


-- ============================================================
-- 13.14 — RECENT PIPELINE RUNS
-- ============================================================

SELECT *
FROM DIVVY_DB.AUDIT.VW_RECENT_PIPELINE_RUNS
LIMIT 20;