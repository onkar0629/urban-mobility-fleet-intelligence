-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 10 — STREAMS & TASKS
-- ============================================================
-- Purpose:
--   Define incremental processing using Snowflake Streams
--   and Tasks.
--
-- Flow:
--   RAW → STREAM → TASK → STAGING/CORE
--
-- Note:
--   Exact transformation logic will be finalized after
--   ingestion and physical model validation.
-- ============================================================

USE DATABASE DIVVY_DB;


-- ============================================================
-- 10.1 — RAW TRIPS STREAM
-- ============================================================

CREATE STREAM IF NOT EXISTS DIVVY_DB.RAW.STREAM_RAW_TRIPS
    ON TABLE DIVVY_DB.RAW.RAW_TRIPS;


-- ============================================================
-- 10.2 — RAW GBFS STREAM
-- ============================================================

CREATE STREAM IF NOT EXISTS DIVVY_DB.RAW.STREAM_RAW_GBFS
    ON TABLE DIVVY_DB.RAW.RAW_GBFS;


-- ============================================================
-- 10.3 — TRIPS INCREMENTAL TASK
-- ============================================================
-- Transformation/MERGE logic will be added after the
-- RAW → STAGING transformation is finalized.

CREATE TASK IF NOT EXISTS DIVVY_DB.CORE.TASK_PROCESS_TRIPS
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 0 * * * * UTC'
AS
    SELECT CURRENT_TIMESTAMP() AS TASK_EXECUTION_TIME;


-- ============================================================
-- 10.4 — GBFS INCREMENTAL TASK
-- ============================================================

CREATE TASK IF NOT EXISTS DIVVY_DB.CORE.TASK_PROCESS_GBFS
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 5 * * * * UTC'
AS
    SELECT CURRENT_TIMESTAMP() AS TASK_EXECUTION_TIME;


-- ============================================================
-- 10.5 — VERIFY STREAMS
-- ============================================================

SHOW STREAMS IN SCHEMA DIVVY_DB.RAW;


-- ============================================================
-- 10.6 — VERIFY TASKS
-- ============================================================

SHOW TASKS IN SCHEMA DIVVY_DB.CORE;


-- ============================================================
-- NOTE
-- ============================================================
-- Tasks should NOT be resumed until their final transformation
-- logic and dependencies have been validated.
--
-- Example:
--
-- ALTER TASK DIVVY_DB.CORE.TASK_PROCESS_TRIPS RESUME;
--
-- ALTER TASK DIVVY_DB.CORE.TASK_PROCESS_GBFS RESUME;