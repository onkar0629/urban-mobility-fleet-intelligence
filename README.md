# Urban Mobility & Fleet Intelligence

An end-to-end data engineering project that turns bike-share trip and station data into useful insights about demand, fleet availability, and usage patterns.

![Project Architecture](assets/project_architecture.png)

**Azure ADLS Gen2 · Snowflake · Python · SQL · Power BI · Databricks / PySpark (optional)**

## What the project does

The project works with historical Divvy trip data and GBFS mobility feeds. Data is landed, cleaned, validated, and prepared for reporting.

The existing pipeline uses ADLS Gen2 for storage and Snowflake for data processing and analytics. Databricks is being added as an optional way to process larger files with PySpark.

## Architecture

```text
Divvy trip files / GBFS feeds
            |
            v
     Azure ADLS Gen2
            |
      +-----+------+
      |            |
      v            v
  Snowflake    Databricks
  current path  optional PySpark path
      |            |
      |       curated Silver files
      |            |
      +-----+------+
            |
         Snowflake
      CORE → MARTS
            |
         Power BI
```

The Snowflake and Databricks routes are alternatives for a given batch. Avoid loading the same source batch through both routes unless duplicate handling has been designed and tested.

## Technology

| Area | Tools |
|---|---|
| Cloud storage | Azure Data Lake Storage Gen2 |
| Data warehouse | Snowflake |
| Distributed processing | Azure Databricks, PySpark (optional) |
| Programming | Python, SQL |
| Automation | Linux, Bash |
| Reporting | Power BI |
| Version control | Git, GitHub |

## Databricks starter jobs

The `databricks/` folder contains starter PySpark scripts for:
- Reading historical trip CSV files and applying basic checks.
- Reading GBFS JSON snapshots and preserving source-file information.
- Separating records that need review from the accepted output.

Start with the [Databricks setup guide](databricks/README.md). Review the source columns and test the jobs on a small sample before using them on real data.

## Repository guide

- [High-level architecture](docs/03_HLD_Architecture.md)
- [Pipeline and ETL design](docs/07_Pipeline_ETL_Design.md)
- [Data dictionary](docs/02_Source_and_Data_Dictionary.md)
- [Data model / star schema](docs/05_Data_Model_Star_Schema.md)
- [Data quality and validation](docs/08_Data_Quality_Validation.md)
- [Monitoring and error handling](docs/10_Monitoring_Error_Handling.md)
- [Deployment runbook](docs/11_Deployment_Runbook.md)
- [Databricks setup](databricks/README.md)

## Current status

The existing Snowflake pipeline has been validated, including trip and GBFS processing, core tables, data marts, and quality checks. The row counts below describe that existing Snowflake run, not Databricks results.

| Object | Validated row count |
|---|---:|
| RAW_TRIPS | 869,051 |
| STG_TRIPS | 869,051 |
| FACT_TRIP | 565,273 |
| RAW_GBFS | 10 |
| STG_STATION_STATUS | 10,243 |
| STG_VEHICLE_STATUS | 15,588 |
| FACT_STATION_STATUS | 10,243 |
| FACT_VEHICLE_STATUS | 15,588 |
| MART_FLEET | 6 |

**Databricks status:** starter code and documentation are in the repository. A workspace, ADLS permissions, scheduled jobs, and the Snowflake handoff still need to be configured and tested.

## Author

**Onkar Jadhav**  
Aspiring Data Engineer
