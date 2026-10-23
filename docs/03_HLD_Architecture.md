# High-Level Design and Architecture

**Cloud:** Microsoft Azure  
**Storage:** Azure Data Lake Storage Gen2  
**Warehouse:** Snowflake  
**Reporting:** Power BI  
**Optional processing:** Azure Databricks / PySpark

## 1. Overview

This project analyzes historical Divvy trips and GBFS station/vehicle feeds. ADLS Gen2 is the landing area, Snowflake is the established data warehouse, and Power BI uses curated data marts for reporting.

Databricks is an optional extension for distributed file processing. It should only be used for a source batch after the workspace, permissions, and output checks have been configured.

## 2. Architecture

```text
Divvy historical files        GBFS API
          |                      |
          |                   Python
          +----------+-----------+
                     |
                     v
              Azure ADLS Gen2
               landing / Bronze
                     |
             +-------+--------+
             |                |
             v                v
        Snowflake        Databricks
      existing route    optional PySpark
             |                |
             |          Silver files
             |                |
             +-------+--------+
                     |
                 Snowflake
              STAGING → CORE
                     |
                   MARTS
                     |
                  Power BI
```

The two processing routes are alternatives for a given batch. Running both against the same batch can create duplicate records unless a deduplication or merge strategy is implemented.

## 3. Component responsibilities

| Component | Responsibility |
|---|---|
| Divvy | Historical trip data |
| GBFS | Station and vehicle availability feeds |
| Python | Fetches and validates API responses and writes snapshots |
| ADLS Gen2 | Stores source files, curated outputs, and quarantined data |
| Databricks / PySpark | Optional distributed file transformation |
| Snowflake | Warehouse ingestion, SQL transformations, core models, and data marts |
| Power BI | Reporting on curated data |
| GitHub | Source code and project documentation |

## 4. Storage layout

Example layout; actual container names and access settings must be configured in Azure.

```text
divvy-data/
├── bronze/
│   ├── historical/trips/
│   └── gbfs/
├── silver/
│   ├── trips/
│   ├── station_status/
│   └── vehicle_status/
├── quarantine/
└── archive/
```

Keep the source files unchanged in Bronze. Write cleaned results to Silver and records needing review to Quarantine.

## 5. Data layers

**Lake storage**
- **Bronze:** source files and traceable raw data.
- **Silver:** cleaned and standardized records.
- **Quarantine:** invalid records or files with issues to investigate.

**Snowflake**
- **RAW:** source-aligned data.
- **STAGING:** typed and standardized records.
- **CORE:** facts and dimensions.
- **MART:** datasets prepared for reporting.
- **AUDIT:** pipeline and validation information.

## 6. Databricks role

The starter jobs in `databricks/` demonstrate the intended pattern: read source files from ADLS, apply basic schema and quality checks, and write accepted and rejected outputs separately.

Before production use:
- Confirm the actual trip and GBFS schemas.
- Configure secure ADLS access in the workspace.
- Decide between Parquet and Delta based on the target setup.
- Test row counts and key metrics.
- Configure and validate the Snowflake load.
- Ensure the same source batch is not loaded twice.

## 7. Security and operations

Do not commit access keys, SAS tokens, connection strings, or passwords. Use approved workspace identity or secret-management options and grant only the required storage permissions.

Choose compute sizes based on actual workload, and measure performance before claiming a speed improvement.

## 8. Status

The Snowflake pipeline is the established project path. Databricks is an optional starter implementation; its workspace, jobs, and end-to-end results have not yet been verified.
