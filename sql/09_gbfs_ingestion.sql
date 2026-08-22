-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 09 — GBFS INGESTION / SNOWPIPE
-- ============================================================
-- Flow:
--   Python → ADLS gbfs/ → Snowpipe → RAW_GBFS
--
-- AUTO_INGEST is intentionally FALSE because Azure event
-- notification wiring is not part of the current integration.
-- ALTER PIPE ... REFRESH provides controlled ingestion and can
-- be replaced by event-driven auto-ingest later without changing
-- the RAW model.
-- ============================================================

USE DATABASE DIVVY_DB;
USE SCHEMA RAW;

CREATE PIPE IF NOT EXISTS DIVVY_DB.RAW.PIPE_GBFS
    AUTO_INGEST = FALSE
AS
COPY INTO DIVVY_DB.RAW.RAW_GBFS
(
    SOURCE_SYSTEM,
    SOURCE_FILE,
    SOURCE_PATH,
    FEED_NAME,
    LOAD_ID,
    INGESTION_TIMESTAMP,
    RAW_JSON
)
FROM
(
    SELECT
        'DIVVY_GBFS',
        METADATA$FILENAME,
        METADATA$FILENAME,
        REGEXP_SUBSTR(METADATA$FILENAME, '(station_status|vehicle_status)', 1, 1, 'i'),
        METADATA$FILE_CONTENT_KEY,
        CURRENT_TIMESTAMP(),
        $1
    FROM @DIVVY_DB.RAW.STG_GBFS
)
FILE_FORMAT = DIVVY_DB.RAW.FF_GBFS_JSON
ON_ERROR = 'ABORT_STATEMENT';

-- Controlled load of files currently present in ADLS.
ALTER PIPE DIVVY_DB.RAW.PIPE_GBFS REFRESH;

SHOW PIPES IN SCHEMA DIVVY_DB.RAW;

SELECT COUNT(*) AS RAW_GBFS_COUNT
FROM DIVVY_DB.RAW.RAW_GBFS;
