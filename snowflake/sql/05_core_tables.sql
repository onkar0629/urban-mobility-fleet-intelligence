-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 05 — CORE TABLES
-- ============================================================
-- Purpose:
--   Create the trusted dimensional model used by analytical
--   marts and downstream reporting.
--
-- Modeling approach:
--   Star Schema / Dimensional Model
--
-- Dimensions:
--   DIM_DATE
--   DIM_TIME
--   DIM_STATION
--   DIM_RIDER
--   DIM_VEHICLE
--   DIM_VEHICLE_TYPE
--
-- Facts:
--   FACT_TRIP
--   FACT_STATION_STATUS
--   FACT_VEHICLE_STATUS
--
-- Note:
--   Snowflake PRIMARY KEY / FOREIGN KEY constraints are
--   informational. Data quality validation is handled
--   separately in the DQ layer.
-- ============================================================

USE DATABASE DIVVY_DB;


-- ============================================================
-- 05.1 — DIM_DATE
-- ============================================================
-- One row = one calendar date.
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.CORE.DIM_DATE
(
    DATE_KEY        NUMBER PRIMARY KEY,
    FULL_DATE       DATE,

    DAY_OF_MONTH    NUMBER,
    DAY_OF_WEEK     NUMBER,
    DAY_NAME        VARCHAR,

    WEEK_OF_YEAR    NUMBER,

    MONTH_NUMBER    NUMBER,
    MONTH_NAME      VARCHAR,

    QUARTER_NUMBER  NUMBER,
    YEAR_NUMBER     NUMBER,

    IS_WEEKEND      BOOLEAN
);


-- ============================================================
-- 05.2 — DIM_TIME
-- ============================================================
-- One row = one time-of-day value used for analysis.
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.CORE.DIM_TIME
(
    TIME_KEY        NUMBER PRIMARY KEY,
    FULL_TIME       TIME,

    HOUR_NUMBER     NUMBER,
    MINUTE_NUMBER   NUMBER,

    PERIOD_NAME     VARCHAR
);


-- ============================================================
-- 05.3 — DIM_STATION
-- ============================================================
-- One row = one unique station.
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.CORE.DIM_STATION
(
    STATION_KEY     NUMBER AUTOINCREMENT,
    STATION_ID      VARCHAR,
    STATION_NAME    VARCHAR,

    LATITUDE        NUMBER(10,7),
    LONGITUDE       NUMBER(10,7),

    CREATED_AT      TIMESTAMP_NTZ,
    UPDATED_AT      TIMESTAMP_NTZ,

    CONSTRAINT PK_DIM_STATION
    PRIMARY KEY (STATION_KEY)
    );


-- ============================================================
-- 05.4 — DIM_RIDER
-- ============================================================
-- One row = one rider category.
-- Current source categories include:
--   member
--   casual
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.CORE.DIM_RIDER
(
    RIDER_KEY       NUMBER AUTOINCREMENT,
    RIDER_CATEGORY  VARCHAR,

    CREATED_AT      TIMESTAMP_NTZ,
    UPDATED_AT      TIMESTAMP_NTZ,

    CONSTRAINT PK_DIM_RIDER
    PRIMARY KEY (RIDER_KEY)
    );


-- ============================================================
-- 05.5 — DIM_VEHICLE
-- ============================================================
-- One row = one unique vehicle.
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.CORE.DIM_VEHICLE
(
    VEHICLE_KEY     NUMBER AUTOINCREMENT,
    VEHICLE_ID      VARCHAR,
    VEHICLE_TYPE_ID VARCHAR,

    CREATED_AT      TIMESTAMP_NTZ,
    UPDATED_AT      TIMESTAMP_NTZ,

    CONSTRAINT PK_DIM_VEHICLE
    PRIMARY KEY (VEHICLE_KEY)
    );


-- ============================================================
-- 05.6 — DIM_VEHICLE_TYPE
-- ============================================================
-- One row = one vehicle type.
--
-- VEHICLE_TYPE_NAME can be populated when the GBFS vehicle
-- type information is extracted during the GBFS processing
-- phase.
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.CORE.DIM_VEHICLE_TYPE
(
    VEHICLE_TYPE_KEY    NUMBER AUTOINCREMENT,
    VEHICLE_TYPE_ID     VARCHAR,
    VEHICLE_TYPE_NAME   VARCHAR,

    CREATED_AT          TIMESTAMP_NTZ,
    UPDATED_AT          TIMESTAMP_NTZ,

    CONSTRAINT PK_DIM_VEHICLE_TYPE
    PRIMARY KEY (VEHICLE_TYPE_KEY)
    );


-- ============================================================
-- 05.7 — FACT_TRIP
-- ============================================================
-- Grain:
--   One row = one completed/source trip record.
--
-- Relationships:
--   FACT_TRIP → DIM_DATE
--   FACT_TRIP → DIM_TIME
--   FACT_TRIP → DIM_STATION
--   FACT_TRIP → DIM_RIDER
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.CORE.FACT_TRIP
(
    TRIP_KEY            NUMBER AUTOINCREMENT,

    RIDE_ID             VARCHAR,

    START_DATE_KEY      NUMBER,
    START_TIME_KEY      NUMBER,

    END_DATE_KEY        NUMBER,
    END_TIME_KEY        NUMBER,

    START_STATION_KEY   NUMBER,
    END_STATION_KEY     NUMBER,

    RIDER_KEY           NUMBER,

    RIDEABLE_TYPE       VARCHAR,

    STARTED_AT          TIMESTAMP_NTZ,
    ENDED_AT            TIMESTAMP_NTZ,

    TRIP_DURATION_MINUTES NUMBER(12,2),

    SOURCE_FILE         VARCHAR,
    LOAD_ID             VARCHAR,

    CREATED_AT          TIMESTAMP_NTZ,

    CONSTRAINT PK_FACT_TRIP
    PRIMARY KEY (TRIP_KEY),

    CONSTRAINT FK_FACT_TRIP_START_DATE
    FOREIGN KEY (START_DATE_KEY)
    REFERENCES DIVVY_DB.CORE.DIM_DATE(DATE_KEY),

    CONSTRAINT FK_FACT_TRIP_END_DATE
    FOREIGN KEY (END_DATE_KEY)
    REFERENCES DIVVY_DB.CORE.DIM_DATE(DATE_KEY),

    CONSTRAINT FK_FACT_TRIP_START_TIME
    FOREIGN KEY (START_TIME_KEY)
    REFERENCES DIVVY_DB.CORE.DIM_TIME(TIME_KEY),

    CONSTRAINT FK_FACT_TRIP_END_TIME
    FOREIGN KEY (END_TIME_KEY)
    REFERENCES DIVVY_DB.CORE.DIM_TIME(TIME_KEY),

    CONSTRAINT FK_FACT_TRIP_START_STATION
    FOREIGN KEY (START_STATION_KEY)
    REFERENCES DIVVY_DB.CORE.DIM_STATION(STATION_KEY),

    CONSTRAINT FK_FACT_TRIP_END_STATION
    FOREIGN KEY (END_STATION_KEY)
    REFERENCES DIVVY_DB.CORE.DIM_STATION(STATION_KEY),

    CONSTRAINT FK_FACT_TRIP_RIDER
    FOREIGN KEY (RIDER_KEY)
    REFERENCES DIVVY_DB.CORE.DIM_RIDER(RIDER_KEY)
    );


-- ============================================================
-- 05.8 — FACT_STATION_STATUS
-- ============================================================
-- Grain:
--   One row = one station-status observation for one snapshot.
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.CORE.FACT_STATION_STATUS
(
    STATION_STATUS_KEY      NUMBER AUTOINCREMENT,

    STATION_KEY             NUMBER,
    DATE_KEY                NUMBER,
    TIME_KEY                NUMBER,

    SNAPSHOT_TIMESTAMP      TIMESTAMP_NTZ,

    STATION_STATUS          VARCHAR,

    NUM_VEHICLES_AVAILABLE  NUMBER,
    NUM_DOCKS_AVAILABLE     NUMBER,

    SOURCE_FILE             VARCHAR,
    LOAD_ID                 VARCHAR,

    CREATED_AT              TIMESTAMP_NTZ,

    CONSTRAINT PK_FACT_STATION_STATUS
    PRIMARY KEY (STATION_STATUS_KEY),

    CONSTRAINT FK_FACT_STATION_STATUS_STATION
    FOREIGN KEY (STATION_KEY)
    REFERENCES DIVVY_DB.CORE.DIM_STATION(STATION_KEY),

    CONSTRAINT FK_FACT_STATION_STATUS_DATE
    FOREIGN KEY (DATE_KEY)
    REFERENCES DIVVY_DB.CORE.DIM_DATE(DATE_KEY),

    CONSTRAINT FK_FACT_STATION_STATUS_TIME
    FOREIGN KEY (TIME_KEY)
    REFERENCES DIVVY_DB.CORE.DIM_TIME(TIME_KEY)
    );


-- ============================================================
-- 05.9 — FACT_VEHICLE_STATUS
-- ============================================================
-- Grain:
--   One row = one vehicle-status observation for one snapshot.
-- ============================================================

CREATE TABLE IF NOT EXISTS DIVVY_DB.CORE.FACT_VEHICLE_STATUS
(
    VEHICLE_STATUS_KEY  NUMBER AUTOINCREMENT,

    VEHICLE_KEY         NUMBER,
    VEHICLE_TYPE_KEY    NUMBER,
    STATION_KEY         NUMBER,

    DATE_KEY            NUMBER,
    TIME_KEY            NUMBER,

    SNAPSHOT_TIMESTAMP  TIMESTAMP_NTZ,

    VEHICLE_STATUS      VARCHAR,

    LATITUDE            NUMBER(10,7),
    LONGITUDE           NUMBER(10,7),

    SOURCE_FILE         VARCHAR,
    LOAD_ID             VARCHAR,

    CREATED_AT          TIMESTAMP_NTZ,

    CONSTRAINT PK_FACT_VEHICLE_STATUS
    PRIMARY KEY (VEHICLE_STATUS_KEY),

    CONSTRAINT FK_FACT_VEHICLE_STATUS_VEHICLE
    FOREIGN KEY (VEHICLE_KEY)
    REFERENCES DIVVY_DB.CORE.DIM_VEHICLE(VEHICLE_KEY),

    CONSTRAINT FK_FACT_VEHICLE_STATUS_TYPE
    FOREIGN KEY (VEHICLE_TYPE_KEY)
    REFERENCES DIVVY_DB.CORE.DIM_VEHICLE_TYPE(VEHICLE_TYPE_KEY),

    CONSTRAINT FK_FACT_VEHICLE_STATUS_STATION
    FOREIGN KEY (STATION_KEY)
    REFERENCES DIVVY_DB.CORE.DIM_STATION(STATION_KEY),

    CONSTRAINT FK_FACT_VEHICLE_STATUS_DATE
    FOREIGN KEY (DATE_KEY)
    REFERENCES DIVVY_DB.CORE.DIM_DATE(DATE_KEY),

    CONSTRAINT FK_FACT_VEHICLE_STATUS_TIME
    FOREIGN KEY (TIME_KEY)
    REFERENCES DIVVY_DB.CORE.DIM_TIME(TIME_KEY)
    );


-- ============================================================
-- 05.10 — VERIFICATION
-- ============================================================

SHOW TABLES IN SCHEMA DIVVY_DB.CORE;