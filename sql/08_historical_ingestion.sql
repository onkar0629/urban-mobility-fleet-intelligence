-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 08 — HISTORICAL INGESTION & ELT
-- ============================================================
-- Flow:
--   ADLS historical/ → External Stage → COPY INTO → RAW_TRIPS
--   → STAGING → CORE → MART
--
-- COPY INTO provides file-level load protection for files that
-- Snowflake has already loaded. Downstream procedures are written
-- to be repeatable and avoid duplicate analytical records.
-- ============================================================

USE DATABASE DIVVY_DB;

-- ============================================================
-- 08.1 — AUDIT TABLE REQUIRED BY HISTORICAL PIPELINE
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.AUDIT.PIPELINE_RUN
(
    PIPELINE_RUN_ID    VARCHAR,
    PIPELINE_NAME      VARCHAR,
    SOURCE_SYSTEM      VARCHAR,
    SOURCE_FILE        VARCHAR,
    START_TIME         TIMESTAMP_NTZ,
    END_TIME           TIMESTAMP_NTZ,
    STATUS             VARCHAR,
    RECORDS_PROCESSED  NUMBER,
    RECORDS_REJECTED   NUMBER,
    ERROR_MESSAGE      VARCHAR
);

-- ============================================================
-- 08.2 — VERIFY HISTORICAL STAGE
-- ============================================================

LIST @DIVVY_DB.RAW.STG_HISTORICAL_TRIPS;

-- ============================================================
-- 08.3 — START AUDIT RUN
-- ============================================================
-- A temporary context table is used instead of a session SET
-- variable so the script runs reliably from DataGrip.

CREATE OR REPLACE TEMPORARY TABLE DIVVY_DB.AUDIT.TMP_HISTORICAL_RUN
AS
SELECT UUID_STRING() AS PIPELINE_RUN_ID;

INSERT INTO DIVVY_DB.AUDIT.PIPELINE_RUN
(
    PIPELINE_RUN_ID,
    PIPELINE_NAME,
    SOURCE_SYSTEM,
    SOURCE_FILE,
    START_TIME,
    STATUS,
    RECORDS_PROCESSED,
    RECORDS_REJECTED
)
SELECT
    PIPELINE_RUN_ID,
    'HISTORICAL_TRIPS',
    'DIVVY',
    NULL,
    CURRENT_TIMESTAMP(),
    'RUNNING',
    0,
    0
FROM DIVVY_DB.AUDIT.TMP_HISTORICAL_RUN;

-- ============================================================
-- 08.4 — COPY ADLS → RAW
-- ============================================================
-- TRY_* conversions keep malformed source values as NULL so RAW
-- loading can complete and STAGING can flag the affected rows.

COPY INTO DIVVY_DB.RAW.RAW_TRIPS
(
    RIDE_ID,
    RIDEABLE_TYPE,
    STARTED_AT,
    ENDED_AT,
    START_STATION_NAME,
    START_STATION_ID,
    END_STATION_NAME,
    END_STATION_ID,
    START_LAT,
    START_LNG,
    END_LAT,
    END_LNG,
    MEMBER_CASUAL,
    SOURCE_SYSTEM,
    SOURCE_FILE,
    SOURCE_PATH,
    LOAD_ID,
    INGESTION_TIMESTAMP
)
FROM
(
    SELECT
        $1,
        $2,
        TRY_TO_TIMESTAMP_NTZ($3),
        TRY_TO_TIMESTAMP_NTZ($4),
        $5,
        $6,
        $7,
        $8,
        TRY_TO_DECIMAL($9, 10, 7),
        TRY_TO_DECIMAL($10, 10, 7),
        TRY_TO_DECIMAL($11, 10, 7),
        TRY_TO_DECIMAL($12, 10, 7),
        $13,
        'DIVVY',
        METADATA$FILENAME,
        METADATA$FILENAME,
        METADATA$FILE_CONTENT_KEY,
        CURRENT_TIMESTAMP()
    FROM @DIVVY_DB.RAW.STG_HISTORICAL_TRIPS
)
FILE_FORMAT = DIVVY_DB.RAW.FF_DIVVY_TRIPS
ON_ERROR = 'ABORT_STATEMENT';

-- ============================================================
-- 08.5 — RAW → STAGING
-- ============================================================

CALL DIVVY_DB.STAGING.SP_LOAD_HISTORICAL_STAGING();

-- ============================================================
-- 08.6 — STAGING → CORE
-- ============================================================

CALL DIVVY_DB.CORE.SP_LOAD_HISTORICAL_CORE();

-- ============================================================
-- 08.7 — CORE → MART
-- ============================================================

CALL DIVVY_DB.MART.SP_REFRESH_MARTS();

-- ============================================================
-- 08.8 — COMPLETE AUDIT RUN
-- ============================================================

UPDATE DIVVY_DB.AUDIT.PIPELINE_RUN P
SET
    END_TIME = CURRENT_TIMESTAMP(),
    STATUS = 'SUCCESS',
    RECORDS_PROCESSED =
    (
        SELECT COUNT(*)
        FROM DIVVY_DB.STAGING.STG_TRIPS
        WHERE IS_VALID_TIMESTAMP
          AND IS_VALID_DURATION
          AND IS_VALID_STATION
          AND NOT IS_DUPLICATE
    )
WHERE P.PIPELINE_RUN_ID =
(
    SELECT PIPELINE_RUN_ID
    FROM DIVVY_DB.AUDIT.TMP_HISTORICAL_RUN
);

DROP TABLE IF EXISTS DIVVY_DB.AUDIT.TMP_HISTORICAL_RUN;

-- ============================================================
-- 08.9 — VALIDATION
-- ============================================================

SELECT COUNT(*) AS RAW_TRIPS_COUNT
FROM DIVVY_DB.RAW.RAW_TRIPS;

SELECT COUNT(*) AS STG_TRIPS_COUNT
FROM DIVVY_DB.STAGING.STG_TRIPS;

SELECT COUNT(*) AS FACT_TRIP_COUNT
FROM DIVVY_DB.CORE.FACT_TRIP;

SELECT
    MEMBER_CASUAL,
    COUNT(*) AS TRIP_COUNT
FROM DIVVY_DB.RAW.RAW_TRIPS
GROUP BY MEMBER_CASUAL
ORDER BY TRIP_COUNT DESC;
