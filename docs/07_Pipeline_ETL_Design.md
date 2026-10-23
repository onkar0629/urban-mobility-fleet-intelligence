# Pipeline and ETL Design

This document describes the existing Snowflake pipeline and the optional Databricks path for the Urban Mobility & Fleet Intelligence project.

## 1. Existing Snowflake path

```text
ADLS source files
      |
Snowflake stage / COPY INTO or Snowpipe
      |
RAW → STAGING → CORE → MART
                         |
                      Power BI
```

This remains the established path for the project.

## 2. Optional Databricks path

```text
ADLS Bronze
     |
Databricks / PySpark
     |
Schema checks and standardization
     |
Silver output + quarantine
     |
Controlled load into Snowflake
     |
CORE → MART → Power BI
```

Choose one path for each source batch. Do not send the same batch through both paths unless duplicate prevention has been tested.

## 3. Starter scripts

- `databricks/trip_bronze_to_silver.py` reads historical trip CSV files, normalizes column names, applies basic required-value checks, and writes accepted and rejected records.
- `databricks/gbfs_bronze_to_silver.py` reads GBFS JSON snapshots, adds source metadata, and separates records that need review.
- `databricks/README.md` explains setup and job parameters.

These are starter examples, not production-ready jobs. Review the source schema and rules before relying on their output.

## 4. Paths and access

Pass paths as job parameters instead of hardcoding account names or credentials.

```text
Bronze trips:  abfss://<container>@<storage-account>.dfs.core.windows.net/bronze/historical/trips/
Bronze GBFS:   abfss://<container>@<storage-account>.dfs.core.windows.net/bronze/gbfs/
Silver:        abfss://<container>@<storage-account>.dfs.core.windows.net/silver/
Quarantine:    abfss://<container>@<storage-account>.dfs.core.windows.net/quarantine/
```

These are examples. Configure storage authentication and permissions in Azure Databricks; a path alone does not provide access.

## 5. Validation

Before promoting a job:
1. Test with a small source sample.
2. Confirm that the expected columns and data types are present.
3. Check required IDs and timestamps.
4. Inspect rejected rows and their reasons.
5. Reconcile input, accepted, and rejected counts.
6. Repeat the run to test duplicate handling and write behavior.
7. Load a sample into Snowflake and compare row counts and key business metrics.

Trip column names and timestamp formats can vary by dataset version. GBFS feeds have different JSON structures, so inspect each feed before adding feed-specific rules.

## 6. Snowflake handoff

Silver output is not automatically loaded into the current Snowflake pipeline. The stage, file format, column mapping, load logic, and duplicate handling must be configured and tested first.

## 7. Security and monitoring

Keep credentials out of source control and logs. Configure workspace storage access using an approved identity or secret-management approach. For scheduled runs, record the source path, run status, input/accepted/rejected counts, output location, and failure details.

## 8. Status

The current Snowflake pipeline is the validated baseline. The Databricks scripts are a starting point and still require workspace setup, source-specific testing, and end-to-end reconciliation.
