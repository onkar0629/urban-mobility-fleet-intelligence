-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 09 — GBFS INGESTION
-- ============================================================
-- Flow:
--   Python → ADLS gbfs/ → Snowpipe → RAW_GBFS
--
-- The pipe is created without automatic cloud notifications until
-- the Azure notification integration/Event Grid configuration is
-- completed. ALTER PIPE ... REFRESH can be used for controlled
-- loading during implementation.
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
        REGEXP_SUBSTR(METADATA$FILENAME, '[^/]+$', 1, 1),
        METADATA$FILE_CONTENT_KEY,
        CURRENT_TIMESTAMP(),
        $1
    FROM @DIVVY_DB.RAW.STG_GBFS
)
FILE_FORMAT = DIVVY_DB.RAW.FF_GBFS_JSON
ON_ERROR = 'CONTINUE';

SHOW PIPES IN SCHEMA DIVVY_DB.RAW;

SELECT COUNT(*) AS RAW_GBFS_COUNT
FROM DIVVY_DB.RAW.RAW_GBFS;
