-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 06 — MART TABLES
-- ============================================================
-- Purpose:
--   Create curated analytical tables for Power BI.
--
-- Marts:
--   MART_OPERATIONS
--   MART_STATION
--   MART_RIDER
--   MART_FLEET
--
-- Principle:
--   Power BI consumes curated analytical marts rather than
--   RAW or STAGING tables.
-- ============================================================

USE DATABASE DIVVY_DB;


-- ============================================================
-- 06.1 — MART_OPERATIONS
-- ============================================================
-- Daily operational mobility metrics.

CREATE TABLE IF NOT EXISTS DIVVY_DB.MART.MART_OPERATIONS
(
    DATE_KEY                    NUMBER,
    FULL_DATE                   DATE,

    TOTAL_TRIPS                 NUMBER,
    AVERAGE_TRIP_DURATION_MIN   NUMBER(12,2),

    PEAK_HOUR                   NUMBER,
    PEAK_HOUR_TRIPS             NUMBER,

    MEMBER_TRIPS                NUMBER,
    CASUAL_TRIPS                NUMBER,

    CREATED_AT                  TIMESTAMP_NTZ
);


-- ============================================================
-- 06.2 — MART_STATION
-- ============================================================
-- Station-level demand and availability metrics.

CREATE TABLE IF NOT EXISTS DIVVY_DB.MART.MART_STATION
(
    DATE_KEY                    NUMBER,
    STATION_KEY                 NUMBER,

    STATION_ID                  VARCHAR,
    STATION_NAME                VARCHAR,

    TRIPS_ORIGINATING           NUMBER,
    TRIPS_ENDING                NUMBER,
    TOTAL_STATION_DEMAND       NUMBER,

    AVAILABLE_VEHICLES          NUMBER,
    AVAILABLE_DOCKS             NUMBER,

    CREATED_AT                  TIMESTAMP_NTZ
);


-- ============================================================
-- 06.3 — MART_RIDER
-- ============================================================
-- Rider-category analytical metrics.

CREATE TABLE IF NOT EXISTS DIVVY_DB.MART.MART_RIDER
(
    DATE_KEY                    NUMBER,
    RIDER_KEY                   NUMBER,

    RIDER_CATEGORY              VARCHAR,

    TOTAL_TRIPS                 NUMBER,
    AVERAGE_TRIP_DURATION_MIN   NUMBER(12,2),

    CREATED_AT                  TIMESTAMP_NTZ
);


-- ============================================================
-- 06.4 — MART_FLEET
-- ============================================================
-- Fleet availability and vehicle-status metrics.

CREATE TABLE IF NOT EXISTS DIVVY_DB.MART.MART_FLEET
(
    DATE_KEY                    NUMBER,
    VEHICLE_KEY                 NUMBER,
    VEHICLE_TYPE_KEY            NUMBER,

    VEHICLE_TYPE_ID             VARCHAR,

    TOTAL_STATUS_OBSERVATIONS   NUMBER,
    AVAILABLE_VEHICLES          NUMBER,
    VEHICLE_AVAILABILITY_RATE   NUMBER(12,4),

    CREATED_AT                  TIMESTAMP_NTZ
);


-- ============================================================
-- 06.5 — VERIFICATION
-- ============================================================

SHOW TABLES IN SCHEMA DIVVY_DB.MART;