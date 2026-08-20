# 09 — Data Lineage

**Version:** 1.0  
**Status:** Final Baseline — Field-Level Lineage Pending Source Profiling

## 1. Purpose

Data lineage provides traceability from public source data through ADLS Gen2, Snowflake processing layers, analytical marts, and Power BI.

## 2. Lineage Objectives

- Source traceability
- Transformation visibility
- Operational auditability
- Impact analysis
- Troubleshooting support
- Confidence in analytical outputs

## 3. End-to-End Lineage

```text
Divvy Historical Trips / GBFS
 → Azure ADLS Gen2
 → Snowflake External Stage
 → RAW
 → STAGING
 → CORE
 → DATA MARTS
 → Power BI
```

## 4. Historical Trip Lineage

```text
Divvy Historical Trip File
 → historical/trips/YYYY/MM/
 → External Stage
 → RAW_TRIPS
 → STG_TRIPS
 → FACT_TRIP + Dimensions
 → MART_OPERATIONS / MART_STATION / MART_RIDER
 → Power BI
```

## 5. GBFS Lineage

```text
GBFS API
 → Python Extraction
 → Timestamped JSON
 → ADLS gbfs/YYYY/MM/DD/
 → Snowflake Stage
 → Snowpipe
 → RAW_GBFS / VARIANT
 → JSON Extraction / FLATTEN()
 → STAGING Feed Structures
 → FACT_STATION_STATUS / FACT_VEHICLE_STATUS + Dimensions
 → MART_FLEET / MART_STATION / MART_OPERATIONS
 → Power BI
```

## 6. Source-to-Landing

Source file names, paths, feed names, timestamps, and ingestion metadata should be preserved where implemented so a target record can be associated with its source file or API snapshot.

## 7. Landing-to-RAW

ADLS files are accessed through Snowflake external stages. Historical files use `COPY INTO`; recurring GBFS files may use Snowpipe. RAW retains source-aligned values and ingestion metadata.

## 8. RAW-to-STAGING

Transformations include:

- Data-type conversion
- Timestamp normalization
- Naming standardization
- JSON path extraction
- `FLATTEN()` for arrays
- Basic validation

## 9. STAGING-to-CORE

STAGING feeds trusted CORE facts and dimensions. Business rules, keys, grain, and approved derived attributes are applied at this stage.

## 10. CORE-to-MART

CORE feeds business-specific marts such as:

- `MART_FLEET`
- `MART_STATION`
- `MART_RIDER`
- `MART_OPERATIONS`

Marts may aggregate, filter, or reshape CORE data for reporting.

## 11. MART-to-Power BI

Power BI consumes curated analytical marts. Dashboard metrics should be traceable through the mart and CORE layers to source data.

## 12. Metadata for Traceability

Useful metadata includes:

- Source system
- Source file name
- Source path
- Feed name
- Ingestion timestamp
- Load ID
- Pipeline/run ID
- File hash where implemented
- Processing timestamp
- Target object

## 13. Transformation Categories

| Category | Meaning |
|---|---|
| Direct mapping | Source value carried forward |
| Standardization | Type/name/format normalization |
| Derived | Value calculated from one or more fields |
| Aggregation | Multiple records summarized |
| Business rule | Defined condition changes classification/inclusion |

## 14. Example Lineage — Trip

```text
Source Trip ID
 → RAW source identifier
 → STAGING trip identifier
 → FACT_TRIP business/source key
```

Start/end timestamps flow into standardized timestamps and date/time analytical attributes.

## 15. Example Lineage — Station

```text
Station ID
 → RAW station identifier
 → STAGING station identifier
 → DIM_STATION business key

Station availability snapshot
 → RAW JSON
 → STAGING availability fields
 → FACT_STATION_STATUS
 → MART_STATION metrics
```

## 16. Example Lineage — Vehicle

```text
Vehicle ID
 → RAW JSON
 → STAGING vehicle identifier
 → DIM_VEHICLE where supported

Vehicle status snapshot
 → FACT_VEHICLE_STATUS
 → MART_FLEET metrics
```

## 17. Derived Metric Lineage

Metrics such as total trips, average trip duration, station demand, station utilization, vehicle availability, and rider distribution should be traceable to the fact records and dimensions used to calculate them.

## 18. Quality and Error Lineage

Quality results should be associated with the relevant dataset, pipeline run, and source where practical. Quarantined files retain source metadata so failures can be investigated.

## 19. Impact Analysis

Before changing a source field, staging transformation, CORE object, or MART definition, use lineage to identify downstream dependencies, including Power BI datasets and KPIs.

## 20. Lineage Granularity

Object-level lineage is the minimum committed baseline. Field-level lineage is finalized for important analytical attributes after actual source profiling and physical implementation.

## 21. Candidate Lineage Matrix

| Source | RAW | STAGING | CORE | MART |
|---|---|---|---|---|
| Historical Trip | RAW_TRIPS | STG_TRIPS | FACT_TRIP | Operations / Station / Rider |
| GBFS Station | RAW_GBFS | STG_STATION_STATUS | FACT_STATION_STATUS | Station |
| GBFS Vehicle | RAW_GBFS | STG_VEHICLE_STATUS | FACT_VEHICLE_STATUS | Fleet |

## 22. Principles

- Preserve source traceability.
- Document transformations.
- Distinguish source and derived fields.
- Maintain reproducible relationships.
- Do not claim lineage for unverified fields.
- Keep documentation aligned with the implemented physical model.

## 23. Status

**Version 1.0 — Final Baseline.** Object-level lineage is locked. Field-level lineage remains dependent on source profiling and physical implementation.
