# 06 — Source-to-Target Mapping

**Version:** 1.0  
**Status:** Baseline — Physical Column Mapping Pending Source Profiling  
**Direction:** Public Source → ADLS → RAW → STAGING → CORE → MART

## 1. Purpose

This document defines the logical mapping between source data and Snowflake target layers and provides traceability from source attributes to standardized structures, CORE entities, and analytical marts.

## 2. Mapping Principle

Mapping is evidence-based. Exact source column names, data types, and transformations are finalized only after profiling actual Divvy historical files and GBFS responses. No unavailable source fields are invented.

## 3. End-to-End Mapping

```text
Public Source
 → Azure ADLS Gen2
 → Snowflake External Stage
 → RAW
 → STAGING
 → CORE
 → DATA MART
 → Power BI
```

## 4. Historical Trip Mapping

| Layer | Logical Object |
|---|---|
| Source | Divvy Historical Trip Data |
| Landing | `historical/trips/YYYY/MM/` |
| RAW | `RAW_TRIPS` or equivalent |
| STAGING | `STG_TRIPS` or equivalent |
| CORE | `FACT_TRIP` + dimensions |
| MART | `MART_OPERATIONS`, `MART_STATION`, `MART_RIDER` |

## 5. Historical Logical Mapping

| Source Concept | Target Concept | Transformation |
|---|---|---|
| Trip identifier | `FACT_TRIP` business/source key | Preserve source value |
| Trip start timestamp | Date/time relationships | Standardize timestamp |
| Trip end timestamp | Date/time relationships | Standardize timestamp |
| Start station identifier | Origin station relationship | Standardize key |
| End station identifier | Destination relationship | Standardize key |
| Rider category | `DIM_RIDER` | Standardize category |
| Trip duration | `FACT_TRIP` measure | Preserve or derive according to verified source |
| Geographic attributes | Station/location attributes | Validate and standardize where supplied |

## 6. Historical Transformation Rules

**RAW:** preserve source-aligned values.  
**STAGING:** standardize names and types, normalize timestamps, and apply basic validation.  
**CORE:** apply approved business definitions and dimensional relationships.  
**MART:** aggregate or reshape trusted CORE data for reporting.

## 7. GBFS Source Mapping

| Layer | Logical Object |
|---|---|
| Source | Divvy GBFS JSON feeds |
| Landing | `gbfs/YYYY/MM/DD/` feed-specific paths |
| RAW | `RAW_GBFS` with metadata + raw JSON |
| STAGING | Feed-specific typed structures |
| CORE | `FACT_STATION_STATUS`, `FACT_VEHICLE_STATUS`, supported dimensions |
| MART | `MART_FLEET`, `MART_STATION`, `MART_OPERATIONS` |

## 8. GBFS Logical Mapping

| GBFS Concept | Target |
|---|---|
| `station_id` | `DIM_STATION` business key / relationship |
| `vehicle_id` | `DIM_VEHICLE` business key where available |
| `vehicle_type` | `DIM_VEHICLE_TYPE` where available |
| Availability metrics | Snapshot fact measures |
| Latitude / longitude | Station or vehicle location attributes |
| Status flags | Snapshot fact attributes |
| Snapshot timestamp | Date/time analytical relationship |

## 9. JSON Transformation

```text
RAW_GBFS.RAW_JSON
 → VARIANT
 → JSON path extraction
 → FLATTEN() for arrays
 → Typed STAGING columns
 → CORE facts/dimensions
```

## 10. Metadata Mapping

| Metadata | Target Purpose |
|---|---|
| Source system | `SOURCE_SYSTEM` |
| Source file/path | `SOURCE_FILE` / `SOURCE_PATH` |
| Feed name | Feed identification |
| Ingestion timestamp | `INGESTION_TIMESTAMP` |
| Load identifier | `LOAD_ID` |
| Pipeline/run ID | Operational traceability |
| File hash | Duplicate/idempotency support where implemented |
| Record count | Audit metadata |
| Load status | Audit metadata |

## 11. RAW-to-STAGING

RAW retains source-aligned values. STAGING converts data types, standardizes names, extracts JSON fields, handles basic null/format rules, and identifies duplicates. STAGING remains close enough to source structure to preserve traceability.

## 12. STAGING-to-CORE

```text
STG_TRIPS → FACT_TRIP + DIM_DATE + DIM_TIME + DIM_STATION + DIM_RIDER

STG_STATION_STATUS → FACT_STATION_STATUS + DIM_STATION + DATE/TIME

STG_VEHICLE_STATUS → FACT_VEHICLE_STATUS + DIM_VEHICLE + DIM_VEHICLE_TYPE + DIM_STATION + DATE/TIME
```

Exact relationships depend on verified source fields.

## 13. CORE-to-MART

```text
FACT_TRIP + Dimensions
        ↓
MART_OPERATIONS / MART_STATION / MART_RIDER

FACT_STATION_STATUS + Dimensions
        ↓
MART_STATION / MART_OPERATIONS

FACT_VEHICLE_STATUS + Dimensions
        ↓
MART_FLEET / MART_OPERATIONS
```

## 14. Mapping Validation

Before final physical mapping, validate:

- Source column existence
- Observed data type
- Nullability
- Key uniqueness
- Source grain
- Transformation logic
- Target grain
- Referential relationships
- Business-rule assumptions

## 15. Status

**Version 1.0 — Baseline.** Field-level physical mapping will be updated after actual source profiling and physical Snowflake implementation.
