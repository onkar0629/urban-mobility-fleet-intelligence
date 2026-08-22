-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 10 — STREAMS & TASKS
-- ============================================================
-- Purpose:
--   Process newly ingested GBFS RAW records incrementally.
--
-- Flow:
--   RAW_GBFS → STREAM → TASK → STAGING → CORE → MART
--
-- The task uses Snowflake-managed serverless compute and is
-- scheduled hourly. It runs only when the stream contains data.
-- SHOW_INITIAL_ROWS preserves GBFS rows already loaded by File 09
-- so the first task execution can initialize the downstream layer.
-- ============================================================

USE DATABASE DIVVY_DB;

-- ============================================================
-- 10.1 — RAW GBFS STREAM
-- ============================================================

CREATE STREAM IF NOT EXISTS DIVVY_DB.RAW.STR_RAW_GBFS
    ON TABLE DIVVY_DB.RAW.RAW_GBFS
    APPEND_ONLY = TRUE
    SHOW_INITIAL_ROWS = TRUE;

-- ============================================================
-- 10.2 — INCREMENTAL GBFS PROCESSING PROCEDURE
-- ============================================================

CREATE OR REPLACE PROCEDURE DIVVY_DB.AUDIT.SP_PROCESS_GBFS_STREAM()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
    V_RUN_ID VARCHAR DEFAULT UUID_STRING();
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
        'GBFS_INCREMENTAL',
        'DIVVY_GBFS',
        NULL,
        CURRENT_TIMESTAMP(),
        'RUNNING',
        0,
        0
    );

    -- --------------------------------------------------------
    -- STATION STATUS: RAW VARIANT → STAGING
    -- --------------------------------------------------------

    MERGE INTO DIVVY_DB.STAGING.STG_STATION_STATUS T
    USING
    (
        SELECT *
        FROM
        (
            SELECT
                F.VALUE:station_id::VARCHAR AS STATION_ID,
                COALESCE(
                    DATEADD(
                        'second',
                        TRY_TO_NUMBER(R.RAW_JSON:last_updated),
                        TO_TIMESTAMP_NTZ('1970-01-01 00:00:00')
                    ),
                    R.INGESTION_TIMESTAMP
                ) AS SNAPSHOT_TIMESTAMP,
                CASE
                    WHEN TRY_TO_NUMBER(F.VALUE:is_installed) = 0 THEN 'NOT_INSTALLED'
                    WHEN TRY_TO_NUMBER(F.VALUE:is_renting) = 0 THEN 'NOT_RENTING'
                    WHEN TRY_TO_NUMBER(F.VALUE:is_returning) = 0 THEN 'NOT_RETURNING'
                    ELSE 'ACTIVE'
                END AS STATION_STATUS,
                COALESCE(
                    TRY_TO_NUMBER(F.VALUE:num_bikes_available),
                    TRY_TO_NUMBER(F.VALUE:num_vehicles_available),
                    0
                ) AS NUM_VEHICLES_AVAILABLE,
                COALESCE(TRY_TO_NUMBER(F.VALUE:num_docks_available), 0) AS NUM_DOCKS_AVAILABLE,
                R.SOURCE_FILE,
                R.LOAD_ID,
                CURRENT_TIMESTAMP() AS STAGING_TIMESTAMP,
                ROW_NUMBER() OVER
                (
                    PARTITION BY
                        F.VALUE:station_id::VARCHAR,
                        R.SOURCE_FILE,
                        COALESCE(
                            DATEADD('second', TRY_TO_NUMBER(R.RAW_JSON:last_updated), TO_TIMESTAMP_NTZ('1970-01-01 00:00:00')),
                            R.INGESTION_TIMESTAMP
                        )
                    ORDER BY R.INGESTION_TIMESTAMP DESC
                ) AS RN
            FROM DIVVY_DB.RAW.STR_RAW_GBFS R,
                 LATERAL FLATTEN(INPUT => R.RAW_JSON:data:stations) F
            WHERE R.METADATA$ACTION = 'INSERT'
              AND LOWER(COALESCE(R.FEED_NAME, '')) = 'station_status'
        ) X
        WHERE RN = 1
    ) S
    ON T.STATION_ID = S.STATION_ID
    AND T.SNAPSHOT_TIMESTAMP = S.SNAPSHOT_TIMESTAMP
    AND T.SOURCE_FILE = S.SOURCE_FILE
    WHEN MATCHED THEN UPDATE SET
        STATION_STATUS = S.STATION_STATUS,
        NUM_VEHICLES_AVAILABLE = S.NUM_VEHICLES_AVAILABLE,
        NUM_DOCKS_AVAILABLE = S.NUM_DOCKS_AVAILABLE,
        LOAD_ID = S.LOAD_ID,
        STAGING_TIMESTAMP = S.STAGING_TIMESTAMP
    WHEN NOT MATCHED THEN INSERT
    (
        STATION_ID, SNAPSHOT_TIMESTAMP, STATION_STATUS,
        NUM_VEHICLES_AVAILABLE, NUM_DOCKS_AVAILABLE,
        SOURCE_FILE, LOAD_ID, STAGING_TIMESTAMP
    )
    VALUES
    (
        S.STATION_ID, S.SNAPSHOT_TIMESTAMP, S.STATION_STATUS,
        S.NUM_VEHICLES_AVAILABLE, S.NUM_DOCKS_AVAILABLE,
        S.SOURCE_FILE, S.LOAD_ID, S.STAGING_TIMESTAMP
    );

    -- --------------------------------------------------------
    -- VEHICLE STATUS: RAW VARIANT → STAGING
    -- --------------------------------------------------------

    MERGE INTO DIVVY_DB.STAGING.STG_VEHICLE_STATUS T
    USING
    (
        SELECT *
        FROM
        (
            SELECT
                F.VALUE:vehicle_id::VARCHAR AS VEHICLE_ID,
                F.VALUE:vehicle_type_id::VARCHAR AS VEHICLE_TYPE_ID,
                F.VALUE:station_id::VARCHAR AS STATION_ID,
                TRY_TO_NUMBER(F.VALUE:lat) AS LATITUDE,
                TRY_TO_NUMBER(F.VALUE:lon) AS LONGITUDE,
                COALESCE(
                    F.VALUE:current_status::VARCHAR,
                    CASE
                        WHEN TRY_TO_NUMBER(F.VALUE:is_disabled) = 1 THEN 'DISABLED'
                        ELSE 'AVAILABLE'
                    END
                ) AS VEHICLE_STATUS,
                COALESCE(
                    DATEADD(
                        'second',
                        TRY_TO_NUMBER(R.RAW_JSON:last_updated),
                        TO_TIMESTAMP_NTZ('1970-01-01 00:00:00')
                    ),
                    R.INGESTION_TIMESTAMP
                ) AS SNAPSHOT_TIMESTAMP,
                R.SOURCE_FILE,
                R.LOAD_ID,
                CURRENT_TIMESTAMP() AS STAGING_TIMESTAMP,
                ROW_NUMBER() OVER
                (
                    PARTITION BY
                        F.VALUE:vehicle_id::VARCHAR,
                        R.SOURCE_FILE,
                        COALESCE(
                            DATEADD('second', TRY_TO_NUMBER(R.RAW_JSON:last_updated), TO_TIMESTAMP_NTZ('1970-01-01 00:00:00')),
                            R.INGESTION_TIMESTAMP
                        )
                    ORDER BY R.INGESTION_TIMESTAMP DESC
                ) AS RN
            FROM DIVVY_DB.RAW.STR_RAW_GBFS R,
                 LATERAL FLATTEN(INPUT => R.RAW_JSON:data:bikes) F
            WHERE R.METADATA$ACTION = 'INSERT'
              AND LOWER(COALESCE(R.FEED_NAME, '')) IN ('free_bike_status', 'vehicle_status')
        ) X
        WHERE RN = 1
    ) S
    ON T.VEHICLE_ID = S.VEHICLE_ID
    AND T.SNAPSHOT_TIMESTAMP = S.SNAPSHOT_TIMESTAMP
    AND T.SOURCE_FILE = S.SOURCE_FILE
    WHEN MATCHED THEN UPDATE SET
        VEHICLE_TYPE_ID = S.VEHICLE_TYPE_ID,
        STATION_ID = S.STATION_ID,
        LATITUDE = S.LATITUDE,
        LONGITUDE = S.LONGITUDE,
        VEHICLE_STATUS = S.VEHICLE_STATUS,
        LOAD_ID = S.LOAD_ID,
        STAGING_TIMESTAMP = S.STAGING_TIMESTAMP
    WHEN NOT MATCHED THEN INSERT
    (
        VEHICLE_ID, VEHICLE_TYPE_ID, STATION_ID,
        LATITUDE, LONGITUDE, VEHICLE_STATUS,
        SNAPSHOT_TIMESTAMP, SOURCE_FILE, LOAD_ID, STAGING_TIMESTAMP
    )
    VALUES
    (
        S.VEHICLE_ID, S.VEHICLE_TYPE_ID, S.STATION_ID,
        S.LATITUDE, S.LONGITUDE, S.VEHICLE_STATUS,
        S.SNAPSHOT_TIMESTAMP, S.SOURCE_FILE, S.LOAD_ID, S.STAGING_TIMESTAMP
    );

    -- --------------------------------------------------------
    -- DIMENSION MERGES
    -- --------------------------------------------------------

    MERGE INTO DIVVY_DB.CORE.DIM_STATION T
    USING
    (
        SELECT DISTINCT STATION_ID
        FROM DIVVY_DB.STAGING.STG_STATION_STATUS
        WHERE STATION_ID IS NOT NULL
        UNION
        SELECT DISTINCT STATION_ID
        FROM DIVVY_DB.STAGING.STG_VEHICLE_STATUS
        WHERE STATION_ID IS NOT NULL
    ) S
    ON T.STATION_ID = S.STATION_ID AND T.IS_CURRENT = TRUE
    WHEN MATCHED THEN UPDATE SET IS_CURRENT = TRUE
    WHEN NOT MATCHED THEN INSERT
    (
        STATION_ID, STATION_NAME, LATITUDE, LONGITUDE,
        SOURCE_SYSTEM, EFFECTIVE_FROM, EFFECTIVE_TO, IS_CURRENT
    )
    VALUES
    (
        S.STATION_ID, NULL, NULL, NULL,
        'DIVVY_GBFS', CURRENT_TIMESTAMP(), NULL, TRUE
    );

    MERGE INTO DIVVY_DB.CORE.DIM_VEHICLE_TYPE T
    USING
    (
        SELECT DISTINCT VEHICLE_TYPE_ID
        FROM DIVVY_DB.STAGING.STG_VEHICLE_STATUS
        WHERE VEHICLE_TYPE_ID IS NOT NULL
    ) S
    ON T.VEHICLE_TYPE_ID = S.VEHICLE_TYPE_ID
    WHEN MATCHED THEN UPDATE SET IS_CURRENT = TRUE
    WHEN NOT MATCHED THEN INSERT
    (
        VEHICLE_TYPE_ID, VEHICLE_TYPE_NAME, SOURCE_SYSTEM, IS_CURRENT
    )
    VALUES
    (
        S.VEHICLE_TYPE_ID, S.VEHICLE_TYPE_ID, 'DIVVY_GBFS', TRUE
    );

    MERGE INTO DIVVY_DB.CORE.DIM_VEHICLE T
    USING
    (
        SELECT *
        FROM
        (
            SELECT
                VEHICLE_ID,
                VEHICLE_TYPE_ID,
                STATION_ID,
                ROW_NUMBER() OVER (PARTITION BY VEHICLE_ID ORDER BY SNAPSHOT_TIMESTAMP DESC) AS RN
            FROM DIVVY_DB.STAGING.STG_VEHICLE_STATUS
            WHERE VEHICLE_ID IS NOT NULL
        ) X
        WHERE RN = 1
    ) S
    ON T.VEHICLE_ID = S.VEHICLE_ID AND T.IS_CURRENT = TRUE
    WHEN MATCHED THEN UPDATE SET
        VEHICLE_TYPE_ID = S.VEHICLE_TYPE_ID,
        STATION_ID = S.STATION_ID
    WHEN NOT MATCHED THEN INSERT
    (
        VEHICLE_ID, VEHICLE_TYPE_ID, STATION_ID, SOURCE_SYSTEM, IS_CURRENT
    )
    VALUES
    (
        S.VEHICLE_ID, S.VEHICLE_TYPE_ID, S.STATION_ID, 'DIVVY_GBFS', TRUE
    );

    -- --------------------------------------------------------
    -- SNAPSHOT FACTS
    -- --------------------------------------------------------

    INSERT INTO DIVVY_DB.CORE.FACT_STATION_STATUS
    (
        STATION_KEY, DATE_KEY, TIME_KEY, SNAPSHOT_TIMESTAMP,
        STATION_STATUS, NUM_VEHICLES_AVAILABLE, NUM_DOCKS_AVAILABLE,
        SOURCE_FILE, LOAD_ID, CREATED_AT
    )
    SELECT
        DS.STATION_KEY,
        TO_NUMBER(TO_CHAR(S.SNAPSHOT_TIMESTAMP, 'YYYYMMDD')),
        TO_NUMBER(TO_CHAR(S.SNAPSHOT_TIMESTAMP, 'HH24MISS')),
        S.SNAPSHOT_TIMESTAMP,
        S.STATION_STATUS,
        S.NUM_VEHICLES_AVAILABLE,
        S.NUM_DOCKS_AVAILABLE,
        S.SOURCE_FILE,
        S.LOAD_ID,
        CURRENT_TIMESTAMP()
    FROM DIVVY_DB.STAGING.STG_STATION_STATUS S
    LEFT JOIN DIVVY_DB.CORE.DIM_STATION DS
        ON DS.STATION_ID = S.STATION_ID AND DS.IS_CURRENT = TRUE
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM DIVVY_DB.CORE.FACT_STATION_STATUS F
        WHERE F.STATION_KEY = DS.STATION_KEY
          AND F.SNAPSHOT_TIMESTAMP = S.SNAPSHOT_TIMESTAMP
          AND F.SOURCE_FILE = S.SOURCE_FILE
    );

    INSERT INTO DIVVY_DB.CORE.FACT_VEHICLE_STATUS
    (
        VEHICLE_KEY, STATION_KEY, DATE_KEY, TIME_KEY,
        SNAPSHOT_TIMESTAMP, VEHICLE_STATUS, LATITUDE, LONGITUDE,
        SOURCE_FILE, LOAD_ID, CREATED_AT
    )
    SELECT
        DV.VEHICLE_KEY,
        DS.STATION_KEY,
        TO_NUMBER(TO_CHAR(S.SNAPSHOT_TIMESTAMP, 'YYYYMMDD')),
        TO_NUMBER(TO_CHAR(S.SNAPSHOT_TIMESTAMP, 'HH24MISS')),
        S.SNAPSHOT_TIMESTAMP,
        S.VEHICLE_STATUS,
        S.LATITUDE,
        S.LONGITUDE,
        S.SOURCE_FILE,
        S.LOAD_ID,
        CURRENT_TIMESTAMP()
    FROM DIVVY_DB.STAGING.STG_VEHICLE_STATUS S
    LEFT JOIN DIVVY_DB.CORE.DIM_VEHICLE DV
        ON DV.VEHICLE_ID = S.VEHICLE_ID AND DV.IS_CURRENT = TRUE
    LEFT JOIN DIVVY_DB.CORE.DIM_STATION DS
        ON DS.STATION_ID = S.STATION_ID AND DS.IS_CURRENT = TRUE
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM DIVVY_DB.CORE.FACT_VEHICLE_STATUS F
        WHERE F.VEHICLE_KEY = DV.VEHICLE_KEY
          AND F.SNAPSHOT_TIMESTAMP = S.SNAPSHOT_TIMESTAMP
          AND F.SOURCE_FILE = S.SOURCE_FILE
    );

    -- --------------------------------------------------------
    -- MART REFRESH + AUDIT
    -- --------------------------------------------------------

    CALL DIVVY_DB.MART.SP_REFRESH_MARTS();

    UPDATE DIVVY_DB.AUDIT.PIPELINE_RUN
    SET
        END_TIME = CURRENT_TIMESTAMP(),
        STATUS = 'SUCCESS',
        RECORDS_PROCESSED =
            (SELECT COUNT(*) FROM DIVVY_DB.CORE.FACT_STATION_STATUS)
            + (SELECT COUNT(*) FROM DIVVY_DB.CORE.FACT_VEHICLE_STATUS)
    WHERE PIPELINE_RUN_ID = :V_RUN_ID;

    RETURN 'GBFS_INCREMENTAL_COMPLETE';

EXCEPTION
    WHEN OTHER THEN
        UPDATE DIVVY_DB.AUDIT.PIPELINE_RUN
        SET
            END_TIME = CURRENT_TIMESTAMP(),
            STATUS = 'FAILED',
            ERROR_MESSAGE = SQLERRM
        WHERE PIPELINE_RUN_ID = :V_RUN_ID;
        RETURN 'GBFS_INCREMENTAL_FAILED: ' || SQLERRM;
END;
$$;

-- ============================================================
-- 10.3 — HOURLY TASK
-- ============================================================

CREATE TASK IF NOT EXISTS DIVVY_DB.AUDIT.TASK_GBFS_PIPELINE
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
    SCHEDULE = 'USING CRON 0 * * * * UTC'
    WHEN SYSTEM$STREAM_HAS_DATA('DIVVY_DB.RAW.STR_RAW_GBFS')
AS
    CALL DIVVY_DB.AUDIT.SP_PROCESS_GBFS_STREAM();

-- The task is resumed here so recurring GBFS files are processed
-- without manual intervention. It consumes compute only when the
-- stream contains data.
ALTER TASK DIVVY_DB.AUDIT.TASK_GBFS_PIPELINE RESUME;

SHOW STREAMS IN SCHEMA DIVVY_DB.RAW;
SHOW TASKS IN SCHEMA DIVVY_DB.AUDIT;
