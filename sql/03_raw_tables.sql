-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 03 — RAW TABLES
-- ============================================================
-- RAW preserves source-aligned data and ingestion traceability.
-- Historical trips are typed to match the verified CSV source.
-- GBFS payloads are preserved as VARIANT.
-- ============================================================

USE DATABASE DIVVY_DB;

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
    SOURCE_SYSTEM       VARCHAR,
    SOURCE_FILE         VARCHAR,
    SOURCE_PATH         VARCHAR,
    LOAD_ID             VARCHAR,
    INGESTION_TIMESTAMP TIMESTAMP_NTZ
);

CREATE TABLE IF NOT EXISTS DIVVY_DB.RAW.RAW_GBFS
(
    SOURCE_SYSTEM       VARCHAR,
    SOURCE_FILE         VARCHAR,
    SOURCE_PATH         VARCHAR,
    FEED_NAME           VARCHAR,
    LOAD_ID             VARCHAR,
    INGESTION_TIMESTAMP TIMESTAMP_NTZ,
    RAW_JSON            VARIANT
);

SHOW TABLES IN SCHEMA DIVVY_DB.RAW;
