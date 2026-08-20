-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 07 — SNOWFLAKE STAGES
-- ============================================================
-- Azure ADLS configuration is added during the Azure phase.

USE DATABASE DIVVY_DB;

CREATE STAGE IF NOT EXISTS DIVVY_DB.RAW.STG_HISTORICAL_TRIPS
    FILE_FORMAT = DIVVY_DB.RAW.FF_DIVVY_TRIPS;

CREATE STAGE IF NOT EXISTS DIVVY_DB.RAW.STG_GBFS
    FILE_FORMAT = DIVVY_DB.RAW.FF_GBFS_JSON;

SHOW STAGES IN SCHEMA DIVVY_DB.RAW;
