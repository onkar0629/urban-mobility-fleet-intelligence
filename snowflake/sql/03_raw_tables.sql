-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 03 — RAW TABLES
-- ============================================================
-- Purpose:
--   Create source-aligned RAW tables.
--
-- RAW principles:
--   - Preserve source data
--   - Minimal transformation
--   - Maintain ingestion traceability
--   - Support controlled reprocessing
-- ============================================================

USE DATABASE DIVVY_DB;


-- ============================================================
-- 03.1 — RAW HISTORICAL TRIPS
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.RAW.RAW_TRIPS
(
    RIDE_ID             VARCHAR,
    RIDEABLE_TYPE       VARCHAR,
    STARTED_AT          TIMESTAMP_NTZ,
    ENDED_AT            TIMESTAMP_NTZ,
    START_STATION_NAME  VARCHAR,
    START_STATION_ID    VARCHAR,
    END_STATION_NAME    VARCHAR,
    END_STATION_ID      VARCHAR,
    START_LAT           NUMBER(10,7),
    START_LNG           NUMBER(10,7),
    END_LAT             NUMBER(10,7),
    END_LNG             NUMBER(10,7),
    MEMBER_CASUAL       VARCHAR,

    -- Ingestion metadata
    SOURCE_SYSTEM       VARCHAR,
    SOURCE_FILE         VARCHAR,
    SOURCE_PATH         VARCHAR,
    LOAD_ID             VARCHAR,
    INGESTION_TIMESTAMP TIMESTAMP_NTZ
);


-- ============================================================
-- 03.2 — RAW GBFS
-- ============================================================
-- GBFS source is semi-structured JSON.
-- The complete payload is preserved in VARIANT.
-- JSON extraction happens in STAGING.

CREATE TABLE IF NOT EXISTS DIVVY_DB.RAW.RAW_GBFS
(
    SOURCE_SYSTEM       VARCHAR,
    SOURCE_FILE         VARCHAR,
    SOURCE_PATH         VARCHAR,
    FEED_NAME           VARCHAR,
    LOAD_ID             VARCHAR,
    INGESTION_TIMESTAMP TIMESTAMP_NTZ,
    RAW_JSON             VARIANT
);


-- ============================================================
-- 03.3 — VERIFICATION
-- ============================================================

SHOW TABLES IN SCHEMA DIVVY_DB.RAW;