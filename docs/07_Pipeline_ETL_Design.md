# 07 — Pipeline / ETL Design

**Version:** 1.0  
**Status:** Final Baseline — Detailed Implementation to Follow  
**Primary Platform:** Snowflake  
**Cloud Landing:** Azure ADLS Gen2  
**Automation:** Python + Linux/Bash

## 1. Purpose

Defines the logical pipeline and ELT design for historical batch ingestion, GBFS API ingestion, Snowflake processing, incremental processing, validation, error handling, and delivery to analytical marts.

## 2. Design Principles

- Snowflake is the primary processing platform.
- The project follows ELT: Extract → Load → Transform.
- RAW is preserved before business transformation.
- Python focuses on external API extraction and validation.
- Linux/Bash supports operational execution.
- Power BI consumes curated marts.

## 3. Pipeline Categories

1. Historical Trip Batch Pipeline
2. GBFS Automated JSON Pipeline

## 4. Historical Batch Pipeline

```text
Divvy Historical File
 → ADLS Gen2
 → Snowflake External Stage
 → COPY INTO
 → RAW
 → STAGING
 → CORE
 → DATA MARTS
 → Power BI
```

### Steps

1. Obtain source file.
2. Place it in the ADLS historical landing path.
3. Validate file presence and basic properties.
4. Access it through the Snowflake External Stage.
5. Load using `COPY INTO`.
6. Record ingestion metadata and load results.
7. Validate RAW row counts and structure.
8. Transform into STAGING.
9. Apply business rules and dimensional relationships in CORE.
10. Build/update analytical marts.

## 5. Historical Ingestion Technology

Primary Snowflake mechanisms:

- External Stage
- File Format
- `COPY INTO`
- Load History
- Ingestion metadata

The exact file format is selected after profiling the actual source file.

## 6. GBFS Pipeline

```text
GBFS API
 → Python
 → Response Validation
 → Timestamped JSON
 → ADLS Gen2
 → Snowflake Stage
 → Snowpipe
 → RAW
 → Stream
 → Task
 → STAGING
 → CORE
 → DATA MART
 → Power BI
```

## 7. Python Responsibilities

Python handles:

- GBFS API requests
- HTTP response validation
- JSON validation
- Required-field/schema checks
- Bounded retries
- Timestamped file naming
- File writing
- Logging
- Controlled failure handling

Python is not the primary warehouse transformation engine.

## 8. Linux/Bash Responsibilities

Linux/Bash supports:

- Script execution
- File operations
- Log management
- Environment configuration
- Scheduling/operational commands where appropriate
- Utility functions

## 9. ADLS Landing Design

```text
historical/trips/YYYY/MM/
gbfs/station_status/YYYY/MM/DD/
gbfs/vehicle_status/YYYY/MM/DD/
archive/
quarantine/
```

## 10. File Naming

Historical files retain meaningful source names where possible.

GBFS snapshots use deterministic timestamped names such as:

```text
vehicle_status_YYYY-MM-DD_HH-MM-SS.json
station_status_YYYY-MM-DD_HH-MM-SS.json
```

## 11. RAW Design

RAW preserves source-aligned data and operational metadata such as source file, source system, ingestion timestamp, load ID, and other metadata where implemented. GBFS raw JSON uses `VARIANT`.

## 12. STAGING Design

STAGING converts raw values into typed, standardized structures. Activities include:

- Data-type conversion
- Timestamp normalization
- Naming standardization
- JSON extraction
- Basic validation
- Duplicate identification

## 13. CORE Design

CORE applies approved business definitions, dimensional relationships, keys, and trusted analytical logic. Candidate targets include:

- `FACT_TRIP`
- `FACT_STATION_STATUS`
- `FACT_VEHICLE_STATUS`
- Supporting dimensions

## 14. Incremental Processing

```text
New File
 → Snowpipe
 → RAW
 → Stream
 → Task
 → SQL Transformation
 → MERGE where required
 → STAGING / CORE
```

Exact stream/task logic is implemented after the physical model is finalized.

## 15. Snowpipe

Snowpipe is intended for automated ingestion of newly arriving recurring GBFS files. Historical bulk loading primarily uses `COPY INTO`.

## 16. Streams

Streams identify new or changed records for downstream incremental processing. Exact stream location depends on the final physical model.

## 17. Tasks

Tasks automate SQL transformations and incremental processing. Task chaining remains simple and justified by dependency requirements.

## 18. MERGE Strategy

`MERGE` may be used for upsert targets. Matching conditions must use stable business keys and the documented target grain. Duplicate source rows must be controlled before a merge.

## 19. Data Quality Gates

Pipeline quality gates include:

- File validation
- Schema checks
- Required-field checks
- Duplicate checks
- Timestamp validation
- Numeric/range checks
- Station/reference checks
- JSON validation

## 20. Error Handling

Failures are logged and isolated. Invalid source files or API responses may be quarantined. Snowflake load errors are captured through available load/execution metadata.

## 21. Retry Strategy

Python uses bounded retries for transient API/network failures. Persistent failures stop the affected flow and require investigation. Snowflake failures are corrected before controlled reruns.

## 22. Idempotency

The pipeline should avoid processing the same source file or snapshot more than once where duplicate detection is possible. File metadata, source identifiers, timestamps, or hashes may support idempotency.

## 23. Audit Metadata

Where implemented, capture:

- Pipeline/run ID
- Source file/feed
- Start/end time
- Status
- Row count
- Error count
- Processing duration

## 24. Monitoring Points

Monitor source availability, file arrival, API status, validation, Snowpipe/COPY status, task execution, quality results, row counts, processing duration, and mart refresh status.

## 25. Failure Flows

### Historical

```text
Source/File → Validation
              ├─ Valid → ADLS → Snowflake → Transformation
              └─ Invalid → Quarantine + Error Log
```

### GBFS

```text
API → Validation
       ├─ Valid → Timestamped JSON → ADLS → Snowpipe
       └─ Invalid → Bounded Retry → Log / Quarantine
```

## 26. Reprocessing

Reprocessing begins only after identifying and correcting the root cause. Source data should be recoverable from ADLS or RAW where possible and reruns must avoid duplicate analytical records.

## 27. Security

Credentials and secrets must not be stored in source code or GitHub. Use secure configuration and least-privilege permissions.

## 28. Performance and Cost

Use suitable warehouse sizing, auto-suspend, incremental processing, query optimization, and Query Profile analysis. Avoid unnecessary full-table transformations.

## 29. Status

**Version 1.0 — Final Baseline.** Detailed physical SQL, stream/task definitions, and operational commands will be added during implementation.
