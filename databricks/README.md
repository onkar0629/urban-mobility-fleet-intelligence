# Databricks Setup

This folder contains starter PySpark jobs for processing trip CSV files and GBFS JSON snapshots.

## Files

- `trip_bronze_to_silver.py` — reads trip CSV files and separates accepted records from records that need review.
- `gbfs_bronze_to_silver.py` — reads GBFS JSON and preserves source-file information.
- `requirements.txt` — optional dependency for compatible local testing. Databricks Runtime normally includes PySpark.

## Before you start

You need:
1. An Azure Databricks workspace.
2. ADLS Gen2 paths for Bronze, Silver, and Quarantine.
3. Storage permissions configured securely in the workspace.
4. A small sample file so you can check the source schema.

Example path format:

```text
abfss://<container>@<storage-account>.dfs.core.windows.net/bronze/historical/trips/
```

Replace placeholders with your configured paths. Do not put keys, SAS tokens, or passwords in this repository.

## Run a job

Import the script into a Databricks notebook or job and provide these parameters:

- `--input-path`: source file or directory.
- `--silver-path`: output path for accepted records.
- `--quarantine-path`: output path for records that need review.
- `--write-mode`: `append` or `overwrite` (optional; defaults to `append`).

For the GBFS job, `--multiline` can be set to `true` or `false` to match the JSON file layout.

## Important notes

- Check the real column names and data types before using the jobs.
- The checks are intentionally basic; they are not a substitute for feed-specific validation.
- Test the write mode on a temporary path before using a shared destination.
- Do not process the same source batch through both the existing Snowflake route and this optional route without duplicate handling.
- Loading Silver data into Snowflake is a separate step and must be configured and tested.

These scripts are a starting point. They have not yet been run in your Azure Databricks workspace.
