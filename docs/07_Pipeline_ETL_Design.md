# 07 — Pipeline / ETL Design

**Version:** 1.1
**Status:** Existing Snowflake flow + optional Databricks starter path
**Cloud Landing:** Azure ADLS Gen2
**Warehouse:** Snowflake
**Distributed Processing:** Azure Databricks / PySpark (optional)

## 1. Purpose

Defines the repeatable ingestion and transformation approach for historical trip CSV files and GBFS JSON snapshots, retaining the current Snowflake-first process while introducing an optional Databricks path for scalable file transformation.

## 2. Pipeline Choices

Use one of the following paths per source batch and record the selected path in run metadata.

### A. Existing Snowflake pipeline

```text
ADLS source file → Snowflake stage / COPY INTO or Snowpipe
                → RAW → STAGING → CORE → MART → Power BI
```

### B. Optional Databricks transformation pipeline

```text
ADLS Bronze → Databricks / PySpark
            → schema enforcement and quality checks
            → Silver Parquet or Delta output
            → controlled Snowflake ingestion
            → CORE / MART → Power BI
```

Do not load both routes into the same target for the same source batch without an explicit deduplication/merge plan.

## 3. Databricks Starter Jobs

The `databricks/` directory contains illustrative PySpark batch jobs:
- `trip_bronze_to_silver.py`: reads historical CSV, casts/normalizes fields, checks required values, and writes valid/invalid outputs separately.
- `gbfs_bronze_to_silver.py`: reads GBFS JSON snapshots, standardizes common station/vehicle fields where present, and writes curated/rejected outputs.
- `README.md`: setup, parameters, storage access and deployment notes.

The scripts are starter examples: validate column names, timestamp formats, trip-duration units, and source-specific deduplication keys against actual files before production use.

## 4. Source and Output Contract

Configure paths per environment through job parameters instead of hardcoding Azure account names or credentials. Suggested defaults:

```text
Input trips:      abfss://<container>@<storage-account>.dfs.core.windows.net/bronze/historical/trips/
Input GBFS:       abfss://<container>@<storage-account>.dfs.core.windows.net/bronze/gbfs/
Silver trips:     abfss://<container>@<storage-account>.dfs.core.windows.net/silver/trips/
Silver GBFS:      abfss://<container>@<storage-account>.dfs.core.windows.net/silver/gbfs/
Quarantine:       abfss://<container>@<storage-account>.dfs.core.windows.net/quarantine/
```

Actual paths and authentication must be configured in the Databricks workspace. Never put secrets in job parameters committed to Git.

## 5. Historical Trip Rules

1. Read CSV with a header and an explicit or carefully inferred schema.
2. Standardize column names and parse timestamps.
3. Check required fields available in the source (for example trip start/end and station identifiers); adapt names to the dataset version.
4. Apply numeric and duration checks only after confirming the source format and units.
5. Separate rejected records with a reason code.
6. Write clean data to Silver in Parquet or Delta format.
7. Compare input, accepted, and rejected counts.
8. Load curated data into Snowflake using the repository's governed ingestion approach and reconcile before publishing marts.

## 6. GBFS JSON Rules

1. Read timestamped JSON snapshots with Spark's JSON reader.
2. Inspect the envelope and nested schema before extracting fields.
3. Preserve snapshot timestamp and source-file lineage.
4. Normalize station/vehicle records only for fields found in the actual feed version.
5. Apply required-field and duplicate checks using feed-specific identifiers.
6. Write curated and rejected records separately.
7. Reconcile the processed snapshot counts to source and target counts.

GBFS feeds can change structure, so production code should validate the feed schema rather than assume every station and vehicle feed uses the same fields.

## 7. Data Quality and Observability

Record, at minimum:
- Run ID, source path, start/end time and status.
- Source/input count, accepted count, rejected count.
- Validation rule failures and failure reason.
- Output path and format.
- Runtime and Spark application/job URL where available.

A run should fail visibly on missing input, missing required columns, or a write failure. Do not silently treat an empty input as a successful full refresh.

## 8. Security

Use managed identity, service principal or approved secret-scope configuration as appropriate for the workspace. Grant minimum required storage permissions. Keep credentials out of source control and logs.

## 9. Snowflake Handoff

Silver outputs are not yet part of the existing production ingestion unless the target Snowflake stage, file format, load logic, schema mapping and deduplication strategy are configured. Validate row counts and key business metrics before switching a workload from the current route.

## 10. Test Plan

- [ ] Configure a small test dataset and a test ADLS path.
- [ ] Verify Databricks can read Bronze.
- [ ] Validate inferred/explicit schema against source columns.
- [ ] Confirm expected records land in Silver.
- [ ] Verify rejects include actionable reason codes.
- [ ] Reconcile input = accepted + rejected (with parse failures accounted for).
- [ ] Repeat the job and test idempotency/overwrite behavior on the test path.
- [ ] Load a sample into Snowflake and validate row counts and measures.
- [ ] Only then schedule or promote the job.

## 11. Status

The scripts are starter code, not evidence of a deployed workspace or a production job. The existing Snowflake pipeline remains the validated baseline.
