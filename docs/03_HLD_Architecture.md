# 03 — High-Level Design / Architecture

**Version:** 1.1
**Status:** Existing Snowflake baseline + optional Databricks extension
**Primary Warehouse:** Snowflake
**Cloud:** Microsoft Azure
**Analytics:** Power BI

## 1. Purpose

The platform ingests historical Divvy trip data and recurring GBFS mobility feeds. Azure Data Lake Storage Gen2 (ADLS Gen2) is the landing zone. The established implementation uses Snowflake for ingestion and ELT. An optional Azure Databricks / PySpark layer is being introduced for scalable file-based transformation before data is loaded into Snowflake.

## 2. Architecture Objectives

- Reliable historical and GBFS ingestion
- Centralized cloud landing in ADLS Gen2
- Reproducible Spark transformations for large files
- Bronze/Silver curation with validation and quarantine
- Snowflake CORE/MART modeling and governed analytics
- Data quality, lineage, auditability, security, and cost control

## 3. Architecture Principles

### Keep the existing baseline working
The current Snowflake path remains supported. Databricks is an optional extension until cloud configuration, permissions, and reconciliation tests have been completed.

### Preserve source data
Keep source files in the landing/Bronze area and write curated outputs to a separate Silver location. Do not overwrite source files during transformation.

### Separate lake processing from warehouse modeling
Databricks handles file-oriented, distributed transformations where useful. Snowflake remains the warehouse for existing CORE facts, dimensions, MARTs, and downstream Power BI.

### Extract → Land → Transform → Serve
Files are landed first, validated and transformed, then loaded into the analytical platform.

## 4. High-Level Architecture

```text
             PUBLIC MOBILITY DATA
                 /          \\
       Historical trips     GBFS API
                |              |
                |            Python
                |       request / validate
                +--------------+
                               |
                               v
                      Azure ADLS Gen2
                    landing / Bronze zone
                               |
                    +----------+-----------+
                    |                      |
                    v                      v
           Existing Snowflake path   Optional Azure Databricks
           stage / COPY / Snowpipe    Spark / PySpark jobs
                    |                      |
                    |                validation + transform
                    |                      |
                    |                Silver Parquet / Delta
                    |                      |
                    +----------+-----------+
                               |
                     Snowflake ingestion
                   (for curated Spark outputs)
                               |
                     STAGING / CORE / MART
                               |
                            Power BI
```

The two paths are alternatives, not a requirement to process every record twice. For a run, choose and document the appropriate path, and prevent duplicate ingestion when Spark outputs are loaded into Snowflake.

## 5. Component Responsibilities

| Component | Responsibility |
|---|---|
| Divvy | Historical trip source |
| GBFS | Mobility station and vehicle feeds |
| Python | GBFS API extraction, response checks, timestamped snapshots |
| ADLS Gen2 | Durable landing, archive, quarantine, and curated file zones |
| Azure Databricks | Optional distributed batch processing using Spark / PySpark |
| Snowflake | Existing warehouse ingestion, CORE/MART models, SQL transformations and analytics |
| SQL | Warehouse transformation and business rules |
| Power BI | Visualization from curated Snowflake MARTs |
| Git / GitHub | Versioned code and documentation |

## 6. ADLS Zone Layout

Proposed layout; configure container names and permissions for the target account:

```text
divvy-data/
├── bronze/
│   ├── historical/trips/YYYY/MM/
│   └── gbfs/YYYY/MM/DD/
├── silver/
│   ├── trips/
│   ├── station_status/
│   └── vehicle_status/
├── archive/
└── quarantine/
```

Use Parquet for portable columnar outputs or Delta Lake when the Databricks workspace and downstream access pattern support it. Avoid assuming the Snowflake and Databricks environments share credentials automatically.

## 7. Processing Layers

### Lakehouse layers
- **Bronze:** source files and ingestion metadata, retained for traceability.
- **Silver:** standardized types, normalized timestamps, deduplicated records, and quality flags.
- **Quarantine:** invalid rows/files with reason codes for review.

### Snowflake layers

```text
DIVVY_DB
├── RAW
├── STAGING
├── CORE
├── MART
└── AUDIT
```

- **RAW:** source-aligned records and load metadata.
- **STAGING:** typed and standardized warehouse records.
- **CORE:** trusted facts and dimensions.
- **MART:** business-ready analytical datasets.
- **AUDIT:** pipeline and operational metadata.

## 8. Historical Trip Flow

Existing path:
```text
Divvy CSV → ADLS → Snowflake Stage → COPY INTO → RAW
          → STAGING → CORE → MART → Power BI
```

Optional Spark path:
```text
Divvy CSV → ADLS Bronze → Databricks / PySpark
          → schema + quality checks → Silver Parquet/Delta
          → Snowflake load → CORE/MART → Power BI
```

Use only one active route for each source batch, or define an explicit control table/file ledger to prevent duplicated business records.

## 9. GBFS Flow

Existing path:
```text
GBFS API → Python → timestamped JSON → ADLS
         → Snowpipe / Snowflake → STAGING → CORE → MART
```

Optional Spark path:
```text
GBFS API → Python → timestamped JSON → ADLS Bronze
         → Databricks PySpark JSON parsing and validation
         → Silver → Snowflake → CORE/MART
```

## 10. Databricks Job Responsibilities

The starter jobs under `databricks/` show the intended implementation:
- Read trip CSV and/or GBFS JSON from ADLS paths supplied via parameters.
- Enforce explicit schemas where practical.
- Normalize columns and timestamps.
- Apply deterministic duplicate checks using documented source keys.
- Separate rejected records and report counts.
- Write Silver outputs to a distinct location.
- Emit basic run metrics (input, valid, rejected row counts).

Workspace setup, storage access, job scheduling, identity/secret configuration, and production run history must be implemented and tested in Azure.

## 11. Data Quality and Reconciliation

Minimum checks:
- Required columns and parseable types.
- Null checks for required identifiers/timestamps.
- Duplicate checks using source identifiers and target grain.
- Trip duration sanity checks after confirming source units.
- Valid station/feed fields for GBFS.
- Input = accepted + rejected rows, accounting for parse failures explicitly.
- Reconcile Databricks Silver counts against Snowflake load and target counts.

## 12. Security

- Do not commit keys, SAS tokens, connection strings, or credentials.
- Use managed identity / workspace identity or a secrets scope where configured.
- Apply least-privilege access to only the required ADLS paths.
- Prefer non-production data and a limited test path for initial validation.

## 13. Performance and Cost

Use job clusters or serverless options available in the target workspace, right-size compute, avoid repeated full scans, partition only when access patterns justify it, and stop compute when no longer required. Measure performance before making claims about improvement.

## 14. Boundaries and Status

AWS, Hadoop, Kafka, and Airflow are not part of this project's current scope. Databricks is an optional extension and has not been represented as deployed or validated in the cloud. Snowflake remains the established warehouse and serving layer.
