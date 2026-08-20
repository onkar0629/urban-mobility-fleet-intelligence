# 02 — Source & Data Dictionary

**Version:** 1.0  
**Status:** Draft — Source Inventory Final, Column Dictionary Pending Profiling  
**Primary Platform:** Snowflake  
**Cloud:** Microsoft Azure

## 1. Purpose

This document defines the source systems, datasets, formats, refresh characteristics, and logical data elements used by the platform. Exact column-level definitions are finalized only after profiling the actual source files and GBFS responses.

## 2. Source System Overview

```text
Divvy Public Data
      ├── Historical Trip Data
      └── GBFS Feeds
              ↓
       Azure ADLS Gen2
              ↓
          Snowflake
```

## 3. Source Inventory

| ID | Source | Type | Format | Primary Use |
|---|---|---|---|---|
| SRC-001 | Divvy Historical Trip Data | Historical | CSV/Parquet* | Trip analytics |
| SRC-002 | Divvy GBFS | Near-real-time | JSON | Fleet/station availability |

\* Actual historical format is recorded after validation.

## 4. Divvy Historical Trip Data

Historical trip data supports:

- Trip demand
- Trip duration
- Rider behaviour
- Station demand
- Temporal analysis
- Origin/destination analysis

Logical ingestion:

```text
Historical File
 → ADLS historical/trips/YYYY/MM/
 → Snowflake External Stage
 → COPY INTO
 → RAW_TRIPS
```

Expected logical elements include a trip identifier, start/end timestamps, start/end station information, rider category, and geographic information where provided. These are candidate concepts, not assumed physical columns.

## 5. Divvy GBFS

GBFS provides machine-readable JSON mobility information used for:

- Station availability
- Vehicle availability
- Vehicle status
- Mobility snapshots
- Near-real-time operational analysis

Logical ingestion:

```text
GBFS API
 → Python
 → JSON Validation
 → Timestamped JSON
 → ADLS
 → Snowflake
```

## 6. GBFS Processing

```text
RAW JSON
   ↓
VARIANT
   ↓
JSON Path Extraction
   ↓
FLATTEN() where arrays exist
   ↓
Typed STAGING structures
   ↓
CORE facts/dimensions
```

## 7. GBFS Feed Categories

Potential categories include system information, station information, station status, vehicle status, vehicle types, pricing, alerts, and geographic/system information. Only feeds actually available from the selected public source will be incorporated.

## 8. Logical Data Elements

| Logical Element | Source | Intended Use |
|---|---|---|
| Trip identifier | Historical | Trip business/source key |
| Trip start timestamp | Historical | Start date/time analysis |
| Trip end timestamp | Historical | End date/time analysis |
| Start station | Historical / GBFS | Origin station relationship |
| End station | Historical | Destination relationship |
| Rider category | Historical | Rider analysis |
| Trip duration | Historical, supplied or derived | Trip measure |
| Station identifier | GBFS | Station business key |
| Vehicle identifier | GBFS, where available | Vehicle business key |
| Vehicle type | GBFS, where available | Vehicle classification |
| Availability metrics | GBFS | Snapshot measures |
| Latitude / longitude | Source, where available | Geographic analysis |
| Status flags | GBFS, where available | Operational snapshot attributes |
| Snapshot timestamp | GBFS | Time-based analysis |

## 9. Ingestion Metadata

The platform may retain:

- `SOURCE_SYSTEM`
- `SOURCE_FILE`
- `SOURCE_PATH`
- `FEED_NAME`
- `INGESTION_TIMESTAMP`
- `LOAD_ID`
- `PIPELINE_RUN_ID`
- `FILE_HASH`, where implemented
- Processing status and record counts

## 10. Source Profiling Requirements

Before physical DDL and field-level mapping are finalized, profile:

- File format and encoding
- Column names and observed data types
- Row counts
- Date coverage
- Null patterns
- Duplicate patterns
- Timestamp validity
- Duration validity
- Station relationships
- Geographic values
- Rider categories
- GBFS feed structure
- Required JSON attributes
- Source limitations

## 11. Source Limitations

Public source schemas can change. Historical and GBFS datasets can have different structures. The project will document observed source behavior and will not invent fields that are not present in verified data.

## 12. Status

**Version 1.0 — Baseline.** Source inventory is defined. Column-level definitions remain pending actual source profiling and implementation.
