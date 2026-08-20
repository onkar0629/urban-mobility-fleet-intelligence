-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 11 — DATA QUALITY VALIDATION
-- ============================================================
-- Purpose:
--   Define reusable SQL checks for validating data across
--   RAW, STAGING and CORE layers.
--
-- Quality dimensions:
--   1. Completeness
--   2. Validity
--   3. Uniqueness
--   4. Referential Integrity
--   5. Reconciliation
--   6. Operational / Freshness checks
-- ============================================================

USE DATABASE DIVVY_DB;


-- ============================================================
-- 11.1 — RAW TRIPS COMPLETENESS
-- ============================================================

SELECT
    COUNT(*) AS TOTAL_ROWS,
    COUNT_IF(RIDE_ID IS NULL) AS NULL_RIDE_ID,
    COUNT_IF(STARTED_AT IS NULL) AS NULL_STARTED_AT,
    COUNT_IF(ENDED_AT IS NULL) AS NULL_ENDED_AT,
    COUNT_IF(MEMBER_CASUAL IS NULL) AS NULL_MEMBER_CASUAL
FROM DIVVY_DB.RAW.RAW_TRIPS;


-- ============================================================
-- 11.2 — RAW TRIPS UNIQUENESS
-- ============================================================

SELECT
    RIDE_ID,
    COUNT(*) AS RECORD_COUNT
FROM DIVVY_DB.RAW.RAW_TRIPS
WHERE RIDE_ID IS NOT NULL
GROUP BY RIDE_ID
HAVING COUNT(*) > 1
ORDER BY RECORD_COUNT DESC;


-- ============================================================
-- 11.3 — TRIP TIMESTAMP VALIDITY
-- ============================================================

SELECT
    COUNT(*) AS INVALID_TIMESTAMP_ROWS
FROM DIVVY_DB.STAGING.STG_TRIPS
WHERE STARTED_AT IS NULL
   OR ENDED_AT IS NULL
   OR ENDED_AT < STARTED_AT;


-- ============================================================
-- 11.4 — TRIP DURATION VALIDITY
-- ============================================================

SELECT
    COUNT(*) AS INVALID_DURATION_ROWS
FROM DIVVY_DB.STAGING.STG_TRIPS
WHERE TRIP_DURATION_MINUTES IS NULL
   OR TRIP_DURATION_MINUTES < 0;

-- ============================================================
-- 11.5 — STATION COMPLETENESS
-- ============================================================

SELECT
    COUNT(*) AS NULL_STATION_ROWS
FROM DIVVY_DB.STAGING.STG_TRIPS
WHERE START_STATION_ID IS NULL
   OR END_STATION_ID IS NULL;

-- ============================================================
-- 11.7 — CORE FACT DUPLICATE CHECK
-- ============================================================

SELECT
    RIDE_ID,
    COUNT(*) AS RECORD_COUNT
FROM DIVVY_DB.CORE.FACT_TRIP
WHERE RIDE_ID IS NOT NULL
GROUP BY RIDE_ID
HAVING COUNT(*) > 1
ORDER BY RECORD_COUNT DESC;

-- ============================================================
-- 11.6 — GEO-COORDINATE VALIDITY
-- ============================================================

SELECT
    COUNT(*) AS INVALID_START_COORDINATES
FROM DIVVY_DB.STAGING.STG_TRIPS
WHERE
    (
        START_LAT IS NOT NULL
            AND (START_LAT < -90 OR START_LAT > 90)
        )
   OR
    (
        START_LNG IS NOT NULL
            AND (START_LNG < -180 OR START_LNG > 180)
        );
-- ============================================================
-- 11.8 — REFERENTIAL INTEGRITY
-- ============================================================

SELECT
    COUNT(*) AS INVALID_STATION_REFERENCES
FROM DIVVY_DB.CORE.FACT_TRIP F
LEFT JOIN DIVVY_DB.CORE.DIM_STATION S
    ON F.START_STATION_KEY = S.STATION_KEY
WHERE F.START_STATION_KEY IS NOT NULL
  AND S.STATION_KEY IS NULL;


-- ============================================================
-- 11.9 — RAW → STAGING RECONCILIATION
-- ============================================================

SELECT
    (SELECT COUNT(*)
     FROM DIVVY_DB.RAW.RAW_TRIPS) AS RAW_COUNT,

    (SELECT COUNT(*)
     FROM DIVVY_DB.STAGING.STG_TRIPS) AS STAGING_COUNT;


-- ============================================================
-- 11.10 — STAGING → CORE RECONCILIATION
-- ============================================================

SELECT
    (SELECT COUNT(*)
     FROM DIVVY_DB.STAGING.STG_TRIPS
     WHERE IS_VALID_TIMESTAMP = TRUE
       AND IS_VALID_DURATION = TRUE) AS VALID_STAGING_COUNT,

    (SELECT COUNT(*)
     FROM DIVVY_DB.CORE.FACT_TRIP) AS CORE_TRIP_COUNT;


-- ============================================================
-- 11.11 — LATEST INGESTION CHECK
-- ============================================================

SELECT
    MAX(INGESTION_TIMESTAMP) AS LAST_RAW_INGESTION
FROM DIVVY_DB.RAW.RAW_TRIPS;