-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 15 — OPTIONAL AUTOMATED HISTORICAL INGESTION
-- ============================================================
-- Purpose:
--   Automate processing when new historical CSV files arrive in
--   ADLS. This complements the manual bulk-load script:
--
--      sql/08_historical_ingestion.sql
--
-- Modes:
--   1. Controlled mode:
--        Run ALTER PIPE ... REFRESH after uploading files.
--   2. Event-driven mode:
--        Configure Azure Event Grid + Snowflake notification
--        integration, then set AUTO_INGEST = TRUE.
--
-- This file is safe to deploy after files 01 through 07.
-- ============================================================

USE DATABASE DIVVY_DB;

-- ============================================================
-- 15.1 — STREAM CONSUMPTION AUDIT
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.AUDIT.HISTORICAL_STREAM_CONSUMPTION
(
    CONSUMPTION_ID        VARCHAR,
    PIPELINE_RUN_ID       VARCHAR,
    SOURCE_FILE           VARCHAR,
    LOAD_ID               VARCHAR,
    STREAM_ACTION         VARCHAR,
    CONSUMED_AT           TIMESTAMP_NTZ
);

-- ============================================================
-- 15.2 — HISTORICAL RAW STREAM
-- ============================================================
-- The stream tracks newly loaded RAW_TRIPS rows from Snowpipe.
-- SHOW_INITIAL_ROWS is FALSE so only future/new RAW rows trigger
-- the task after this object is created.

CREATE STREAM IF NOT EXISTS DIVVY_DB.RAW.STR_RAW_TRIPS
    ON TABLE DIVVY_DB.RAW.RAW_TRIPS
    APPEND_ONLY = TRUE
    SHOW_INITIAL_ROWS = FALSE;

-- ============================================================
-- 15.3 — HISTORICAL SNOWPIPE
-- ============================================================
-- Controlled mode uses AUTO_INGEST = FALSE. After uploading new
-- CSV files to ADLS, run:
--
--   ALTER PIPE DIVVY_DB.RAW.PIPE_HISTORICAL_TRIPS REFRESH;
--
-- For fully event-driven mode, configure Azure notification
-- integration first, then recreate this pipe with AUTO_INGEST =
-- TRUE and NOTIFICATION_INTEGRATION = <integration_name>.

CREATE OR REPLACE PIPE DIVVY_DB.RAW.PIPE_HISTORICAL_TRIPS
    AUTO_INGEST = FALSE
AS
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
        TRY_TO_TIMESTAMP_NTZ($3),
        TRY_TO_TIMESTAMP_NTZ($4),
        $5,
        $6,
        $7,
        $8,
        TRY_TO_DECIMAL($9, 10, 7),
        TRY_TO_DECIMAL($10, 10, 7),
        TRY_TO_DECIMAL($11, 10, 7),
        TRY_TO_DECIMAL($12, 10, 7),
        $13,
        'DIVVY',
        METADATA$FILENAME,
        METADATA$FILENAME,
        METADATA$FILE_CONTENT_KEY,
        CURRENT_TIMESTAMP()
    FROM @DIVVY_DB.RAW.STG_HISTORICAL_TRIPS
)
FILE_FORMAT = (
    FORMAT_NAME = DIVVY_DB.RAW.FF_DIVVY_TRIPS
)
ON_ERROR = 'ABORT_STATEMENT';

-- ============================================================
-- 15.4 — STREAM PROCESSING PROCEDURE
-- ============================================================
-- The existing STAGING, CORE and MART procedures are idempotent.
-- This procedure consumes the RAW stream for task control, then
-- refreshes the trusted layers.

CREATE OR REPLACE PROCEDURE DIVVY_DB.AUDIT.SP_PROCESS_HISTORICAL_STREAM()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
    V_RUN_ID VARCHAR DEFAULT UUID_STRING();
    V_ERROR_MESSAGE VARCHAR;
BEGIN
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
        :V_RUN_ID,
        'HISTORICAL_INCREMENTAL',
        'DIVVY',
        NULL,
        CURRENT_TIMESTAMP(),
        'RUNNING',
        0,
        0
    );

    INSERT INTO DIVVY_DB.AUDIT.HISTORICAL_STREAM_CONSUMPTION
    (
        CONSUMPTION_ID,
        PIPELINE_RUN_ID,
        SOURCE_FILE,
        LOAD_ID,
        STREAM_ACTION,
        CONSUMED_AT
    )
    SELECT
        UUID_STRING(),
        :V_RUN_ID,
        SOURCE_FILE,
        LOAD_ID,
        METADATA$ACTION,
        CURRENT_TIMESTAMP()
    FROM DIVVY_DB.RAW.STR_RAW_TRIPS
    WHERE METADATA$ACTION = 'INSERT';

    CALL DIVVY_DB.STAGING.SP_LOAD_HISTORICAL_STAGING();
    CALL DIVVY_DB.CORE.SP_LOAD_HISTORICAL_CORE();
    CALL DIVVY_DB.MART.SP_REFRESH_MARTS();

    UPDATE DIVVY_DB.AUDIT.PIPELINE_RUN
    SET
        END_TIME = CURRENT_TIMESTAMP(),
        STATUS = 'SUCCESS',
        RECORDS_PROCESSED = (SELECT COUNT(*) FROM DIVVY_DB.CORE.FACT_TRIP)
    WHERE PIPELINE_RUN_ID = :V_RUN_ID;

    RETURN 'HISTORICAL_INCREMENTAL_COMPLETE';

EXCEPTION
    WHEN OTHER THEN
        V_ERROR_MESSAGE := SQLERRM;

        UPDATE DIVVY_DB.AUDIT.PIPELINE_RUN
        SET
            END_TIME = CURRENT_TIMESTAMP(),
            STATUS = 'FAILED',
            ERROR_MESSAGE = :V_ERROR_MESSAGE
        WHERE PIPELINE_RUN_ID = :V_RUN_ID;

        RETURN 'HISTORICAL_INCREMENTAL_FAILED: ' || V_ERROR_MESSAGE;
END;
$$;

-- ============================================================
-- 15.5 — HISTORICAL PROCESSING TASK
-- ============================================================
-- The task runs only when STR_RAW_TRIPS has unprocessed rows.

CREATE TASK IF NOT EXISTS DIVVY_DB.AUDIT.TASK_HISTORICAL_PIPELINE
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
    SCHEDULE = 'USING CRON 15 * * * * UTC'
    WHEN SYSTEM$STREAM_HAS_DATA('DIVVY_DB.RAW.STR_RAW_TRIPS')
AS
    CALL DIVVY_DB.AUDIT.SP_PROCESS_HISTORICAL_STREAM();

ALTER TASK DIVVY_DB.AUDIT.TASK_HISTORICAL_PIPELINE RESUME;

-- ============================================================
-- 15.6 — CONTROLLED MODE REFRESH COMMAND
-- ============================================================
-- Uncomment this after uploading new historical files if you are
-- not using Azure Event Grid auto-ingest.
--
-- ALTER PIPE DIVVY_DB.RAW.PIPE_HISTORICAL_TRIPS REFRESH;

SHOW PIPES IN SCHEMA DIVVY_DB.RAW;
SHOW STREAMS IN SCHEMA DIVVY_DB.RAW;
SHOW TASKS IN SCHEMA DIVVY_DB.AUDIT;
