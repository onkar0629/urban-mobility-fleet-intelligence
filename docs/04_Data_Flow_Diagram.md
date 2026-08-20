# 04 — Data Flow Diagram (DFD)

**Version:** 1.0  
**Status:** Final Baseline

## 1. Purpose

This document describes how data moves through the Urban Mobility & Fleet Intelligence platform, covering historical batch ingestion and GBFS recurring ingestion.

## 2. End-to-End Flow

```text
Divvy Public Data
      ↓
Historical Trips + GBFS API
      ↓
Azure ADLS Gen2
      ↓
Snowflake External Stage
      ↓
RAW
      ↓
STAGING
      ↓
CORE
      ↓
DATA MARTS
      ↓
Power BI
```

## 3. Data Flow Components

| Component | Responsibility |
|---|---|
| Historical Trips | Historical batch source |
| GBFS | JSON mobility source |
| Python | GBFS extraction and validation |
| ADLS Gen2 | Cloud landing |
| Snowflake Stage | Access to ADLS |
| RAW | Source preservation |
| STAGING | Cleaning and standardization |
| CORE | Trusted business model |
| DATA MARTS | Analytical layer |
| Power BI | Visualization |

## 4. Historical Trip Flow

```text
Divvy Historical File
 → ADLS Gen2
 → External Stage
 → COPY INTO
 → RAW_TRIPS
 → STAGING
 → CORE
 → DATA MARTS
 → Power BI
```

### Step-by-Step

1. Obtain the historical source file.
2. Place it in the ADLS historical directory.
3. Access it through the Snowflake External Stage.
4. Load it with `COPY INTO`.
5. Preserve source data and ingestion metadata in RAW.
6. Clean and standardize in STAGING.
7. Apply trusted business logic in CORE.
8. Build analytical marts.
9. Consume curated marts in Power BI.

## 5. GBFS Flow

```text
GBFS API
 → Python
 → Validation
 → Timestamped JSON
 → ADLS Gen2
 → Snowflake Stage
 → Snowpipe
 → RAW_GBFS
 → Stream
 → Task
 → STAGING
 → CORE
 → DATA MARTS
 → Power BI
```

Python validates HTTP response, JSON validity, expected structure, and required fields before writing a timestamped snapshot.

## 6. RAW GBFS Flow

`RAW_GBFS` may contain source metadata such as source file, load timestamp, source system, load ID, and a raw JSON payload stored using Snowflake `VARIANT`.

## 7. JSON Transformation Flow

```text
RAW_JSON
 → VARIANT
 → JSON Path Extraction
 → FLATTEN()
 → STAGING
```

## 8. Incremental Processing

```text
New Data
 → Snowpipe
 → RAW
 → STREAM
 → TASK
 → SQL Transformation
 → MERGE where required
 → STAGING / CORE
```

The purpose is to avoid unnecessary full-table processing for recurring data.

## 9. Stream and Task Flow

A Snowflake Stream identifies new or changed records. A Task automates downstream SQL processing.

```text
RAW → STREAM → TASK → SQL Transformation → CORE
```

## 10. Data Quality Flow

```text
Source
 → Python Validation
 → ADLS
 → Snowflake RAW
 → SQL Validation
 → STAGING
 → CORE
```

Checks include required fields, duplicates, timestamps, durations, station references, geography, JSON validity, and schema consistency where applicable.

## 11. Error Flow

```text
Ingestion
   ├── Valid → Normal Processing
   └── Invalid → Quarantine + Error Log
```

## 12. Reprocessing Flow

```text
Quarantined / Failed Data
 → Root Cause Analysis
 → Correction
 → Revalidation
 → ADLS / Snowflake
 → Controlled Reprocessing
```

## 13. Data Mart Flow

```text
CORE
 ├── MART_FLEET
 ├── MART_STATION
 ├── MART_RIDER
 └── MART_OPERATIONS
          ↓
       Power BI
```

Power BI should not directly consume RAW source tables.

## 14. Responsibility Matrix

| Activity | Responsible Component |
|---|---|
| Source | Divvy / GBFS |
| Extraction | Python where required |
| Validation | Python + Snowflake SQL |
| Landing | ADLS Gen2 |
| External Access | Snowflake Stage |
| Initial Load | COPY INTO |
| Automated Load | Snowpipe |
| Raw Storage | RAW |
| JSON Processing | VARIANT / FLATTEN |
| Change Detection | Stream |
| Automation | Task |
| Transformation | SQL |
| Modeling | CORE |
| Analytics | DATA MART |
| Visualization | Power BI |

## 15. Data Movement Principles

- Source data lands before warehouse transformation.
- RAW remains close to source.
- Business transformations primarily occur in Snowflake.
- Python focuses on external ingestion and validation.
- Power BI consumes curated marts.
- Failures remain observable and recoverable.
- Recurring data is processed incrementally where justified.

## 16. Dependencies

```text
Source Availability
 → ADLS
 → Snowflake Stage
 → RAW
 → STAGING
 → CORE
 → DATA MART
 → Power BI
```

GBFS additionally depends on `GBFS API → Python → ADLS`.

## 17. Status

**Version 1.0 — Final Baseline.**
