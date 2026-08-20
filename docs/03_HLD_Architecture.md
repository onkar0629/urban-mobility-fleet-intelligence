# 03 — High-Level Design / Architecture

**Version:** 1.0  
**Status:** Final Baseline  
**Primary Platform:** Snowflake  
**Cloud:** Microsoft Azure  
**Analytics:** Power BI

## 1. Purpose

The architecture provides a Snowflake-centric platform for historical batch ingestion and recurring GBFS mobility data. Azure ADLS Gen2 provides cloud landing/storage, Snowflake performs ingestion and ELT, Python/Linux support external automation, and Power BI consumes curated analytical marts.

## 2. Architecture Objectives

- Reliable historical ingestion
- Automated GBFS ingestion
- Centralized cloud landing
- Snowflake analytical processing
- RAW / STAGING / CORE / MART separation
- Incremental processing where justified
- Data quality and monitoring
- Secure access
- Performance and cost awareness
- Business-ready analytical datasets

## 3. Architecture Principles

### Snowflake-Centric
Snowflake is the primary analytical and processing platform.

### ELT Over ETL
Data is loaded before major business transformations:

```text
Extract → Load → Transform
```

### Preserve Raw Data
RAW remains close to source structure and retains ingestion metadata.

### Separation of Responsibilities

| Component | Responsibility |
|---|---|
| Divvy | Historical source data |
| GBFS | API-based mobility data |
| Python | API extraction and external validation |
| Linux/Bash | Operational scripting |
| ADLS Gen2 | Cloud landing/storage |
| Snowflake | Ingestion, transformation, modeling |
| SQL | ELT and business logic |
| Power BI | Visualization |

## 4. High-Level Architecture

```text
              PUBLIC MOBILITY DATA
                /              \
      Historical Trips       GBFS API
             |                  |
             |               Python
             |             validation
             |                  |
             +---------> Azure ADLS Gen2
                              |
                     Snowflake External Stage
                              |
                            RAW
                              |
                         STAGING
                              |
                           CORE
                              |
                         DATA MARTS
                              |
                          Power BI
```

## 5. Source Layer

Historical trips provide event-level mobility data for trip, rider, station, temporal, and origin/destination analysis. GBFS provides JSON mobility information for station/vehicle availability, status, and operational snapshots.

## 6. Azure ADLS Gen2 Layer

Proposed landing structure:

```text
divvy-data/
├── historical/
│   └── trips/YYYY/MM/
├── gbfs/
│   ├── station_status/YYYY/MM/DD/
│   └── vehicle_status/YYYY/MM/DD/
├── archive/
└── quarantine/
```

## 7. Snowflake Layers

```text
DIVVY_DB
├── RAW
├── STAGING
├── CORE
├── MART
└── AUDIT
```

- **RAW:** source-aligned data and ingestion metadata
- **STAGING:** typed, cleaned, standardized data
- **CORE:** trusted facts and dimensions
- **MART:** business-ready analytical datasets
- **AUDIT:** pipeline and operational metadata

## 8. Historical Architecture

```text
Divvy Historical File
 → ADLS
 → External Stage
 → COPY INTO
 → RAW
 → STAGING
 → CORE
 → MART
 → Power BI
```

Historical loading is batch-oriented and primarily uses Snowflake `COPY INTO`.

## 9. GBFS Architecture

```text
GBFS API
 → Python
 → Validation
 → Timestamped JSON
 → ADLS
 → Snowflake Stage
 → Snowpipe
 → RAW
 → Stream
 → Task
 → STAGING
 → CORE
 → MART
 → Power BI
```

## 10. Incremental Processing

Recurring files are candidates for Snowpipe ingestion followed by Streams and Tasks for incremental downstream processing.

```text
New File
 → Snowpipe
 → RAW
 → Stream
 → Task
 → SQL Transformation
 → MERGE where justified
 → STAGING / CORE
```

## 11. Semi-Structured Processing

GBFS JSON is retained in Snowflake `VARIANT` where appropriate. Arrays can be expanded with `FLATTEN()` and converted into typed relational structures in STAGING.

## 12. Security

- Least-privilege permissions
- Role-based access
- Secrets outside source code
- No credentials in GitHub
- Secure environment configuration
- Separation of engineering and analytical access

## 13. Performance & Cost

Use appropriate warehouse sizing, auto-suspend, incremental processing, query optimization, and Query Profile analysis. Clustering or advanced features are used only when workload evidence justifies them.

## 14. Architecture Boundary

The project intentionally excludes AWS, Hadoop, Spark, Databricks, Kafka, Airflow, and proprietary operational systems. Components are included because they solve defined project requirements.

## 15. Status

**Version 1.0 — Final Baseline.** Architecture changes require a significant technical, business, data-source, or architectural requirement.
