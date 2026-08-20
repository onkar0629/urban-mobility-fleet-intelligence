-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 04 — STAGING TABLES
-- ============================================================
-- Purpose:
--   Transform RAW source-aligned data into standardized,
--   typed structures ready for CORE processing.
--
-- STAGING responsibilities:
--   - Data type standardization
--   - Timestamp normalization
--   - Naming standardization
--   - Basic validation
--   - Duplicate identification
--   - JSON extraction for GBFS
-- ============================================================

USE DATABASE DIVVY_DB;


-- ============================================================
-- 04.1 — STAGING HISTORICAL TRIPS
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.STAGING.STG_TRIPS
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

    -- Standardized derived attributes
    TRIP_DURATION_MINUTES NUMBER(12,2),

    -- Data-quality indicators
    IS_VALID_TIMESTAMP  BOOLEAN,
    IS_VALID_DURATION   BOOLEAN,
    IS_VALID_STATION    BOOLEAN,
    IS_DUPLICATE        BOOLEAN,

    -- Lineage / processing metadata
    SOURCE_FILE         VARCHAR,
    LOAD_ID             VARCHAR,
    STAGING_TIMESTAMP   TIMESTAMP_NTZ
);


-- ============================================================
-- 04.2 — STAGING STATION STATUS
-- ============================================================
-- Extracted from GBFS station-status JSON.

CREATE TABLE IF NOT EXISTS DIVVY_DB.STAGING.STG_STATION_STATUS
(
    STATION_ID              VARCHAR,
    SNAPSHOT_TIMESTAMP      TIMESTAMP_NTZ,

    STATION_STATUS          VARCHAR,

    NUM_VEHICLES_AVAILABLE  NUMBER,
    NUM_DOCKS_AVAILABLE     NUMBER,

    SOURCE_FILE             VARCHAR,
    LOAD_ID                 VARCHAR,
    STAGING_TIMESTAMP       TIMESTAMP_NTZ
);


-- ============================================================
-- 04.3 — STAGING VEHICLE STATUS
-- ============================================================
-- Extracted from GBFS vehicle-status JSON.

CREATE TABLE IF NOT EXISTS DIVVY_DB.STAGING.STG_VEHICLE_STATUS
(
    VEHICLE_ID          VARCHAR,
    VEHICLE_TYPE_ID     VARCHAR,
    STATION_ID          VARCHAR,

    LATITUDE            NUMBER(10,7),
    LONGITUDE           NUMBER(10,7),

    VEHICLE_STATUS      VARCHAR,
    SNAPSHOT_TIMESTAMP  TIMESTAMP_NTZ,

    SOURCE_FILE         VARCHAR,
    LOAD_ID             VARCHAR,
    STAGING_TIMESTAMP   TIMESTAMP_NTZ
);


-- ============================================================
-- 04.4 — VERIFICATION
-- ============================================================

SHOW TABLES IN SCHEMA DIVVY_DB.STAGING;