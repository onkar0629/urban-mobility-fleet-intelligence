-- ============================================================
-- URBAN MOBILITY & FLEET INTELLIGENCE
-- 01 — DATABASE & SCHEMA SETUP
-- ============================================================
-- Primary Platform : Snowflake
-- Cloud Landing    : Azure Data Lake Storage Gen2
-- Architecture     : RAW → STAGING → CORE → MART
-- ============================================================


-- ============================================================
-- 01.1 — DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS DIVVY_DB;


-- ============================================================
-- 01.2 — RAW SCHEMA
-- Source-aligned data preservation layer
-- ============================================================

CREATE SCHEMA IF NOT EXISTS DIVVY_DB.RAW;


-- ============================================================
-- 01.3 — STAGING SCHEMA
-- Cleansing, standardization and type conversion layer
-- ============================================================

CREATE SCHEMA IF NOT EXISTS DIVVY_DB.STAGING;


-- ============================================================
-- 01.4 — CORE SCHEMA
-- Trusted dimensional model / business logic layer
-- ============================================================

CREATE SCHEMA IF NOT EXISTS DIVVY_DB.CORE;


-- ============================================================
-- 01.5 — MART SCHEMA
-- Curated analytical data marts for Power BI
-- ============================================================

CREATE SCHEMA IF NOT EXISTS DIVVY_DB.MART;


-- ============================================================
-- 01.6 — AUDIT SCHEMA
-- Pipeline execution and operational metadata
-- ============================================================

CREATE SCHEMA IF NOT EXISTS DIVVY_DB.AUDIT;


-- ============================================================
-- 01.7 — USE DATABASE
-- ============================================================

USE DATABASE DIVVY_DB;


-- ============================================================
-- 01.8 — VERIFICATION
-- ============================================================

SHOW SCHEMAS IN DATABASE DIVVY_DB;