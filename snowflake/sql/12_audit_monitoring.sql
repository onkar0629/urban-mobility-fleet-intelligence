-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 12 — AUDIT & MONITORING
-- ============================================================
-- Purpose:
--   Create operational metadata structures for monitoring
--   pipeline executions, data loads and failures.
--
-- Tracks:
--   - Run ID
--   - Pipeline / source
--   - Start / end time
--   - Status
--   - Records processed
--   - Records rejected
--   - Error details
-- ============================================================

USE DATABASE DIVVY_DB;


-- ============================================================
-- 12.1 — PIPELINE RUN AUDIT
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.AUDIT.PIPELINE_RUN_AUDIT
(
    RUN_ID              VARCHAR,
    PIPELINE_NAME       VARCHAR,
    SOURCE_SYSTEM       VARCHAR,

    START_TIME          TIMESTAMP_NTZ,
    END_TIME            TIMESTAMP_NTZ,

    STATUS              VARCHAR,

    RECORDS_READ        NUMBER,
    RECORDS_PROCESSED   NUMBER,
    RECORDS_REJECTED    NUMBER,

    SOURCE_FILE         VARCHAR,

    ERROR_CODE          VARCHAR,
    ERROR_MESSAGE       VARCHAR,

    CREATED_AT          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);


-- ============================================================
-- 12.2 — DATA QUALITY AUDIT
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.AUDIT.DATA_QUALITY_AUDIT
(
    QUALITY_RUN_ID      VARCHAR,
    RUN_ID              VARCHAR,

    TABLE_NAME          VARCHAR,
    CHECK_NAME          VARCHAR,

    CHECK_TYPE          VARCHAR,
    CHECK_STATUS        VARCHAR,

    EXPECTED_VALUE      VARCHAR,
    ACTUAL_VALUE        VARCHAR,

    FAILED_RECORD_COUNT NUMBER,

    EXECUTED_AT         TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),

    ERROR_MESSAGE       VARCHAR
);


-- ============================================================
-- 12.3 — LOAD AUDIT
-- ============================================================
-- Tracks individual source-file loads.

CREATE TABLE IF NOT EXISTS DIVVY_DB.AUDIT.LOAD_AUDIT
(
    LOAD_ID             VARCHAR,

    SOURCE_SYSTEM       VARCHAR,
    SOURCE_FILE         VARCHAR,
    SOURCE_PATH         VARCHAR,

    TARGET_TABLE        VARCHAR,

    LOAD_START_TIME     TIMESTAMP_NTZ,
    LOAD_END_TIME       TIMESTAMP_NTZ,

    STATUS              VARCHAR,

    RECORDS_LOADED      NUMBER,
    RECORDS_REJECTED    NUMBER,

    ERROR_CODE          VARCHAR,
    ERROR_MESSAGE       VARCHAR,

    CREATED_AT          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);


-- ============================================================
-- 12.4 — PIPELINE FAILURE VIEW
-- ============================================================
-- Quick operational view of failed pipeline executions.

CREATE OR REPLACE VIEW DIVVY_DB.AUDIT.VW_PIPELINE_FAILURES AS
SELECT
    RUN_ID,
    PIPELINE_NAME,
    SOURCE_SYSTEM,
    START_TIME,
    END_TIME,
    STATUS,
    RECORDS_READ,
    RECORDS_PROCESSED,
    RECORDS_REJECTED,
    SOURCE_FILE,
    ERROR_CODE,
    ERROR_MESSAGE
FROM DIVVY_DB.AUDIT.PIPELINE_RUN_AUDIT
WHERE UPPER(STATUS) IN ('FAILED', 'ERROR');


-- ============================================================
-- 12.5 — RECENT PIPELINE RUNS VIEW
-- ============================================================

CREATE OR REPLACE VIEW DIVVY_DB.AUDIT.VW_RECENT_PIPELINE_RUNS AS
SELECT
    RUN_ID,
    PIPELINE_NAME,
    SOURCE_SYSTEM,
    START_TIME,
    END_TIME,
    STATUS,
    RECORDS_READ,
    RECORDS_PROCESSED,
    RECORDS_REJECTED,
    SOURCE_FILE
FROM DIVVY_DB.AUDIT.PIPELINE_RUN_AUDIT
ORDER BY START_TIME DESC;


-- ============================================================
-- 12.6 — VERIFICATION
-- ============================================================

SHOW TABLES IN SCHEMA DIVVY_DB.AUDIT;

SHOW VIEWS IN SCHEMA DIVVY_DB.AUDIT;