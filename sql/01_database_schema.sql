-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 01 — DATABASE & SCHEMA SETUP
-- ============================================================
-- Execution order: 01 → 13
-- Primary platform : Snowflake
-- Cloud landing    : Azure Data Lake Storage Gen2
-- Architecture     : RAW → STAGING → CORE → MART
-- Operational      : AUDIT
-- ============================================================

CREATE DATABASE IF NOT EXISTS DIVVY_DB;

CREATE SCHEMA IF NOT EXISTS DIVVY_DB.RAW;
CREATE SCHEMA IF NOT EXISTS DIVVY_DB.STAGING;
CREATE SCHEMA IF NOT EXISTS DIVVY_DB.CORE;
CREATE SCHEMA IF NOT EXISTS DIVVY_DB.MART;
CREATE SCHEMA IF NOT EXISTS DIVVY_DB.AUDIT;

USE DATABASE DIVVY_DB;

SHOW SCHEMAS IN DATABASE DIVVY_DB;
