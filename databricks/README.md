# Azure Databricks / PySpark Integration

Starter batch jobs for an optional Databricks processing path in Urban Mobility & Fleet Intelligence.

## Files

- `trip_bronze_to_silver.py` — standardizes historical trip CSV data and separates rejected rows.
- `gbfs_bronze_to_silver.py` — reads GBFS JSON snapshots and separates records requiring review.
- `requirements.txt` — optional local-testing dependency note. Databricks Runtime typically supplies PySpark.

## Prerequisites

1. An Azure Databricks workspace and supported runtime.
2. ADLS Gen2 Bronze, Silver, and quarantine locations.
3. Secure storage access configured in the workspace (managed identity/access connector, service principal, or approved secret scope).
4. Job parameters for input and output paths.
5. A sample file whose schema can be inspected and validated.

Example path pattern:

```text
abfss://<container>@<storage-account>.dfs.core.windows.net/bronze/historical/trips/
abfss://<container>@<storage-account>.dfs.core.windows.net/silver/trips/
abfss://<container>@<storage-account>.dfs.core.windows.net/quarantine/trips/
```

No real account names, tokens, keys, or secrets belong in these files. An ABFSS path alone does not grant access; configure authentication in the workspace.

## Run from a Databricks notebook or job

Import the script, configure job parameters, and pass the required path parameters. Review the real source schema before production use.

Trip job parameters:
- `--input-path`: Bronze trip CSV directory or file.
- `--silver-path`: Silver output directory.
- `--quarantine-path`: rejected-record output directory.

GBFS job parameters:
- `--input-path`: Bronze GBFS JSON directory or file.
- `--silver-path`: Silver output directory.
- `--quarantine-path`: rejected-record output directory.

```text
ADLS Bronze → Databricks / PySpark → Silver Parquet
                            └─────→ Quarantine
Silver → controlled Snowflake ingestion → CORE/MART → Power BI
```

## Implementation notes

- Inspect and validate the source schema before trusting the transformations.
- The starter scripts print basic count summaries. Persistent audit storage and job monitoring still need configuration.
- Test with a small input before using a production path.
- Do not run this route alongside the existing Snowflake route for the same batch unless downstream deduplication is deliberate.
- Existing Snowflake row counts in the main README are not Databricks test results.
