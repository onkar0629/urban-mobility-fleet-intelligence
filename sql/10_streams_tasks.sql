-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 10 — STREAMS & TASKS
-- ============================================================
-- Purpose:
--   Detect new RAW GBFS records and provide the incremental
--   processing framework.
--
-- The task is created suspended by default. It is resumed only
-- after STAGING/CORE processing is validated end-to-end.
-- ============================================================

USE DATABASE DIVVY_DB;

CREATE STREAM IF NOT EXISTS DIVVY_DB.RAW.STR_RAW_GBFS
    ON TABLE DIVVY_DB.RAW.RAW_GBFS
    APPEND_ONLY = TRUE;

-- Dependency required by the task action.
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

CREATE TASK IF NOT EXISTS DIVVY_DB.AUDIT.TASK_GBFS_PIPELINE
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
    SCHEDULE = 'USING CRON 0 * * * * UTC'
    WHEN SYSTEM$STREAM_HAS_DATA('DIVVY_DB.RAW.STR_RAW_GBFS')
AS
    INSERT INTO DIVVY_DB.AUDIT.PIPELINE_RUN
    (
        PIPELINE_RUN_ID,
        PIPELINE_NAME,
        SOURCE_SYSTEM,
        SOURCE_FILE,
        START_TIME,
        END_TIME,
        STATUS,
        RECORDS_PROCESSED,
        RECORDS_REJECTED,
        ERROR_MESSAGE
    )
    SELECT
        UUID_STRING(),
        'GBFS_INCREMENTAL',
        'DIVVY_GBFS',
        NULL,
        CURRENT_TIMESTAMP(),
        CURRENT_TIMESTAMP(),
        'READY_FOR_PROCESSING',
        COUNT(*),
        0,
        NULL
    FROM DIVVY_DB.RAW.STR_RAW_GBFS;

SHOW STREAMS IN SCHEMA DIVVY_DB.RAW;
SHOW TASKS IN SCHEMA DIVVY_DB.AUDIT;

-- Enable only after the incremental transformation is validated.
-- ALTER TASK DIVVY_DB.AUDIT.TASK_GBFS_PIPELINE RESUME;
