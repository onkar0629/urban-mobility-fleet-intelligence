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

SET HISTORICAL_RUN_ID = UUID_STRING();

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
VALUES
(
    $HISTORICAL_RUN_ID,
    'HISTORICAL_TRIPS',
    'DIVVY',
    NULL,
    CURRENT_TIMESTAMP(),
    'RUNNING',
    0,
    0
);

-- ============================================================
-- 08.4 — COPY ADLS → RAW
-- ============================================================

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
        $3,
        $4,
        $5,
        $6,
        $7,
        $8,
        $9,
        $10,
        $11,
        $12,
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

UPDATE DIVVY_DB.AUDIT.PIPELINE_RUN
SET
    END_TIME = CURRENT_TIMESTAMP(),
    STATUS = 'SUCCESS',
    RECORDS_PROCESSED = (SELECT COUNT(*) FROM DIVVY_DB.CORE.FACT_TRIP)
WHERE PIPELINE_RUN_ID = $HISTORICAL_RUN_ID;

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
