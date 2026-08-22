-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 11 — DATA QUALITY
-- ============================================================
-- Reusable data-quality checks across RAW, STAGING and CORE.
-- Operational monitoring is handled by File 12.
-- Final end-to-end validation is handled by File 13.
-- ============================================================

USE DATABASE DIVVY_DB;

-- ============================================================
-- 11.1 — DATA QUALITY RESULT TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.AUDIT.DATA_QUALITY_RESULT
(
    CHECK_ID        VARCHAR,
    CHECK_NAME      VARCHAR,
    LAYER           VARCHAR,
    OBJECT_NAME     VARCHAR,
    CHECK_TIME      TIMESTAMP_NTZ,
    STATUS          VARCHAR,
    RECORDS_CHECKED NUMBER,
    RECORDS_FAILED  NUMBER,
    FAILURE_PERCENT NUMBER(10,2),
    SEVERITY        VARCHAR,
    DETAILS         VARCHAR
);

ALTER TABLE DIVVY_DB.AUDIT.DATA_QUALITY_RESULT
    ADD COLUMN IF NOT EXISTS FAILURE_PERCENT NUMBER(10,2);

ALTER TABLE DIVVY_DB.AUDIT.DATA_QUALITY_RESULT
    ADD COLUMN IF NOT EXISTS SEVERITY VARCHAR;

-- ============================================================
-- 11.2 — RAW TRIP CHECKS
-- ============================================================

INSERT INTO DIVVY_DB.AUDIT.DATA_QUALITY_RESULT
(
    CHECK_ID, CHECK_NAME, LAYER, OBJECT_NAME, CHECK_TIME,
    STATUS, RECORDS_CHECKED, RECORDS_FAILED, DETAILS
)
SELECT
    UUID_STRING(),
    'RAW_TRIPS_RIDE_ID_NOT_NULL',
    'RAW',
    'RAW_TRIPS',
    CURRENT_TIMESTAMP(),
    IFF(FAILURES = 0, 'PASS', 'FAIL'),
    TOTAL_ROWS,
    FAILURES,
    'RIDE_ID must be populated'
FROM
(
    SELECT
        COUNT(*) AS TOTAL_ROWS,
        COALESCE(COUNT_IF(RIDE_ID IS NULL), 0) AS FAILURES
    FROM DIVVY_DB.RAW.RAW_TRIPS
)

UNION ALL

SELECT
    UUID_STRING(),
    'RAW_TRIPS_TIMESTAMP_VALIDITY',
    'RAW',
    'RAW_TRIPS',
    CURRENT_TIMESTAMP(),
    IFF(FAILURES = 0, 'PASS', 'WARN'),
    TOTAL_ROWS,
    FAILURES,
    'Rows with missing or unordered timestamps are flagged and excluded from trusted CORE processing'
FROM
(
    SELECT
        COUNT(*) AS TOTAL_ROWS,
        COALESCE(COUNT_IF(
            STARTED_AT IS NULL
            OR ENDED_AT IS NULL
            OR ENDED_AT < STARTED_AT
        ), 0) AS FAILURES
    FROM DIVVY_DB.RAW.RAW_TRIPS
)

UNION ALL

SELECT
    UUID_STRING(),
    'RAW_TRIPS_COORDINATE_RANGE',
    'RAW',
    'RAW_TRIPS',
    CURRENT_TIMESTAMP(),
    IFF(FAILURES = 0, 'PASS', 'FAIL'),
    TOTAL_ROWS,
    FAILURES,
    'Latitude must be -90..90 and longitude -180..180'
FROM
(
    SELECT
        COUNT(*) AS TOTAL_ROWS,
        COALESCE(COUNT_IF(
            (START_LAT IS NOT NULL AND (START_LAT < -90 OR START_LAT > 90))
            OR (START_LNG IS NOT NULL AND (START_LNG < -180 OR START_LNG > 180))
            OR (END_LAT IS NOT NULL AND (END_LAT < -90 OR END_LAT > 90))
            OR (END_LNG IS NOT NULL AND (END_LNG < -180 OR END_LNG > 180))
        ), 0) AS FAILURES
    FROM DIVVY_DB.RAW.RAW_TRIPS
)

UNION ALL

SELECT
    UUID_STRING(),
    'RAW_GBFS_JSON_PRESENT',
    'RAW',
    'RAW_GBFS',
    CURRENT_TIMESTAMP(),
    IFF(FAILURES = 0, 'PASS', 'FAIL'),
    TOTAL_ROWS,
    FAILURES,
    'RAW_GBFS must preserve a JSON VARIANT payload'
FROM
(
    SELECT
        COUNT(*) AS TOTAL_ROWS,
        COALESCE(COUNT_IF(RAW_JSON IS NULL), 0) AS FAILURES
    FROM DIVVY_DB.RAW.RAW_GBFS
);

-- ============================================================
-- 11.3 — STAGING CHECKS
-- ============================================================

INSERT INTO DIVVY_DB.AUDIT.DATA_QUALITY_RESULT
(
    CHECK_ID, CHECK_NAME, LAYER, OBJECT_NAME, CHECK_TIME,
    STATUS, RECORDS_CHECKED, RECORDS_FAILED, FAILURE_PERCENT,
    SEVERITY, DETAILS
)
SELECT
    UUID_STRING(),
    'STAGING_VALID_TRIPS',
    'STAGING',
    'STG_TRIPS',
    CURRENT_TIMESTAMP(),
    IFF(FAILURES = 0, 'PASS', 'WARN'),
    TOTAL_ROWS,
    FAILURES,
    ROUND(100.0 * FAILURES / NULLIF(TOTAL_ROWS, 0), 2),
    'MEDIUM',
    'Rows failing timestamp, duration, station or duplicate rules are excluded from CORE'
FROM
(
    SELECT
        COUNT(*) AS TOTAL_ROWS,
        COALESCE(COUNT_IF(
            NOT IS_VALID_TIMESTAMP
            OR NOT IS_VALID_DURATION
            OR NOT IS_VALID_STATION
            OR IS_DUPLICATE
        ), 0) AS FAILURES
    FROM DIVVY_DB.STAGING.STG_TRIPS
);

-- ============================================================
-- 11.4 — CORE RECONCILIATION
-- ============================================================

INSERT INTO DIVVY_DB.AUDIT.DATA_QUALITY_RESULT
(
    CHECK_ID, CHECK_NAME, LAYER, OBJECT_NAME, CHECK_TIME,
    STATUS, RECORDS_CHECKED, RECORDS_FAILED, DETAILS
)
SELECT
    UUID_STRING(),
    'CORE_TRIP_RECONCILIATION',
    'CORE',
    'FACT_TRIP',
    CURRENT_TIMESTAMP(),
    IFF(FAILURES = 0, 'PASS', 'FAIL'),
    VALID_STAGING_ROWS,
    FAILURES,
    'Valid staging trips should reconcile to CORE fact trips'
FROM
(
    SELECT
        (
            SELECT COUNT(*)
            FROM DIVVY_DB.STAGING.STG_TRIPS
            WHERE IS_VALID_TIMESTAMP
              AND IS_VALID_DURATION
              AND IS_VALID_STATION
              AND NOT IS_DUPLICATE
        ) AS VALID_STAGING_ROWS,
        ABS
        (
            (
                SELECT COUNT(*)
                FROM DIVVY_DB.STAGING.STG_TRIPS
                WHERE IS_VALID_TIMESTAMP
                  AND IS_VALID_DURATION
                  AND IS_VALID_STATION
                  AND NOT IS_DUPLICATE
            )
            -
            (
                SELECT COUNT(*)
                FROM DIVVY_DB.CORE.FACT_TRIP
            )
        ) AS FAILURES
);

-- ============================================================
-- 11.5 — CORE FOREIGN-KEY CHECK
-- ============================================================

INSERT INTO DIVVY_DB.AUDIT.DATA_QUALITY_RESULT
(
    CHECK_ID, CHECK_NAME, LAYER, OBJECT_NAME, CHECK_TIME,
    STATUS, RECORDS_CHECKED, RECORDS_FAILED, DETAILS
)
SELECT
    UUID_STRING(),
    'CORE_TRIP_KEYS_PRESENT',
    'CORE',
    'FACT_TRIP',
    CURRENT_TIMESTAMP(),
    IFF(FAILURES = 0, 'PASS', 'FAIL'),
    TOTAL_ROWS,
    FAILURES,
    'Valid fact trips should have station and rider dimension keys'
FROM
(
    SELECT
        COUNT(*) AS TOTAL_ROWS,
        COALESCE(COUNT_IF(
            START_STATION_KEY IS NULL
            OR END_STATION_KEY IS NULL
            OR RIDER_KEY IS NULL
        ), 0) AS FAILURES
    FROM DIVVY_DB.CORE.FACT_TRIP
);

-- ============================================================
-- 11.6 — QUALITY SUMMARY
-- ============================================================

-- ============================================================
-- 11.6 — GBFS SNAPSHOT CHECKS
-- ============================================================

INSERT INTO DIVVY_DB.AUDIT.DATA_QUALITY_RESULT
(
    CHECK_ID, CHECK_NAME, LAYER, OBJECT_NAME, CHECK_TIME,
    STATUS, RECORDS_CHECKED, RECORDS_FAILED, FAILURE_PERCENT,
    SEVERITY, DETAILS
)
SELECT
    UUID_STRING(),
    'STAGING_STATION_STATUS_REQUIRED_FIELDS',
    'STAGING',
    'STG_STATION_STATUS',
    CURRENT_TIMESTAMP(),
    IFF(FAILURES = 0, 'PASS', 'FAIL'),
    TOTAL_ROWS,
    FAILURES,
    ROUND(100.0 * FAILURES / NULLIF(TOTAL_ROWS, 0), 2),
    'HIGH',
    'Station status snapshots require station_id and snapshot timestamp'
FROM
(
    SELECT
        COUNT(*) AS TOTAL_ROWS,
        COALESCE(COUNT_IF(STATION_ID IS NULL OR SNAPSHOT_TIMESTAMP IS NULL), 0) AS FAILURES
    FROM DIVVY_DB.STAGING.STG_STATION_STATUS
)

UNION ALL

SELECT
    UUID_STRING(),
    'STAGING_VEHICLE_STATUS_REQUIRED_FIELDS',
    'STAGING',
    'STG_VEHICLE_STATUS',
    CURRENT_TIMESTAMP(),
    IFF(FAILURES = 0, 'PASS', 'FAIL'),
    TOTAL_ROWS,
    FAILURES,
    ROUND(100.0 * FAILURES / NULLIF(TOTAL_ROWS, 0), 2),
    'HIGH',
    'Vehicle status snapshots require vehicle_id and snapshot timestamp'
FROM
(
    SELECT
        COUNT(*) AS TOTAL_ROWS,
        COALESCE(COUNT_IF(VEHICLE_ID IS NULL OR SNAPSHOT_TIMESTAMP IS NULL), 0) AS FAILURES
    FROM DIVVY_DB.STAGING.STG_VEHICLE_STATUS
)

UNION ALL

SELECT
    UUID_STRING(),
    'CORE_STATION_STATUS_KEYS_PRESENT',
    'CORE',
    'FACT_STATION_STATUS',
    CURRENT_TIMESTAMP(),
    IFF(FAILURES = 0, 'PASS', 'FAIL'),
    TOTAL_ROWS,
    FAILURES,
    ROUND(100.0 * FAILURES / NULLIF(TOTAL_ROWS, 0), 2),
    'MEDIUM',
    'Station status facts should resolve station/date/time keys'
FROM
(
    SELECT
        COUNT(*) AS TOTAL_ROWS,
        COALESCE(COUNT_IF(STATION_KEY IS NULL OR DATE_KEY IS NULL OR TIME_KEY IS NULL), 0) AS FAILURES
    FROM DIVVY_DB.CORE.FACT_STATION_STATUS
)

UNION ALL

SELECT
    UUID_STRING(),
    'CORE_VEHICLE_STATUS_KEYS_PRESENT',
    'CORE',
    'FACT_VEHICLE_STATUS',
    CURRENT_TIMESTAMP(),
    IFF(FAILURES = 0, 'PASS', 'FAIL'),
    TOTAL_ROWS,
    FAILURES,
    ROUND(100.0 * FAILURES / NULLIF(TOTAL_ROWS, 0), 2),
    'MEDIUM',
    'Vehicle status facts should resolve vehicle/date/time keys'
FROM
(
    SELECT
        COUNT(*) AS TOTAL_ROWS,
        COALESCE(COUNT_IF(VEHICLE_KEY IS NULL OR DATE_KEY IS NULL OR TIME_KEY IS NULL), 0) AS FAILURES
    FROM DIVVY_DB.CORE.FACT_VEHICLE_STATUS
);

-- ============================================================
-- 11.7 — QUALITY SUMMARY
-- ============================================================

SELECT
    STATUS,
    COUNT(*) AS CHECK_COUNT,
    SUM(RECORDS_FAILED) AS FAILED_RECORDS
FROM DIVVY_DB.AUDIT.DATA_QUALITY_RESULT
GROUP BY STATUS
ORDER BY STATUS;

SELECT *
FROM DIVVY_DB.AUDIT.DATA_QUALITY_RESULT
ORDER BY CHECK_TIME DESC
LIMIT 50;
