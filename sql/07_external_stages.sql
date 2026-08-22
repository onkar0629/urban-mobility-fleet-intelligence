-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 07 — AZURE EXTERNAL STAGES
-- ============================================================
-- Azure ADLS Gen2:
--   Account  : umfiadlsg2onkar
--   Container: divvy-data
--
-- Snowflake uses a storage integration so credentials are not
-- stored in SQL or GitHub.
-- ============================================================

USE DATABASE DIVVY_DB;
USE SCHEMA RAW;

CREATE STORAGE INTEGRATION IF NOT EXISTS DIVVY_AZURE_INT
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = AZURE
    ENABLED = TRUE
    AZURE_TENANT_ID = '7ad4ff51-b4d9-4c04-b74f-b478b4dc95eb'
    STORAGE_ALLOWED_LOCATIONS =
    (
        'azure://umfiadlsg2onkar.blob.core.windows.net/divvy-data/'
    );

DESC INTEGRATION DIVVY_AZURE_INT;

CREATE OR REPLACE STAGE DIVVY_DB.RAW.STG_HISTORICAL_TRIPS
    URL = 'azure://umfiadlsg2onkar.blob.core.windows.net/divvy-data/historical/'
    STORAGE_INTEGRATION = DIVVY_AZURE_INT
    FILE_FORMAT = DIVVY_DB.RAW.FF_DIVVY_TRIPS;

CREATE OR REPLACE STAGE DIVVY_DB.RAW.STG_GBFS
    URL = 'azure://umfiadlsg2onkar.blob.core.windows.net/divvy-data/gbfs/'
    STORAGE_INTEGRATION = DIVVY_AZURE_INT
    FILE_FORMAT = DIVVY_DB.RAW.FF_GBFS_JSON;

LIST @DIVVY_DB.RAW.STG_HISTORICAL_TRIPS;

LIST @DIVVY_DB.RAW.STG_GBFS;

SHOW STAGES IN SCHEMA DIVVY_DB.RAW;
