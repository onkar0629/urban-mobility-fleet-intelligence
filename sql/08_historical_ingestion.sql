-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 08 — HISTORICAL INGESTION
-- ============================================================
-- Flow:
--   ADLS historical/ → External Stage → COPY INTO → RAW_TRIPS
--
-- Snowflake load history provides file-level idempotency for
-- already-loaded files.
-- ============================================================

USE DATABASE DIVVY_DB;
USE SCHEMA RAW;

LIST @DIVVY_DB.RAW.STG_HISTORICAL_TRIPS;

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

SELECT COUNT(*) AS RAW_TRIPS_COUNT
FROM DIVVY_DB.RAW.RAW_TRIPS;

SELECT
    MEMBER_CASUAL,
    COUNT(*) AS TRIP_COUNT
FROM DIVVY_DB.RAW.RAW_TRIPS
GROUP BY MEMBER_CASUAL
ORDER BY TRIP_COUNT DESC;
