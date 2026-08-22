# 11 — Deployment / Runbook

**Version:** 1.0  
**Status:** Final Baseline — Operational Commands to be Added During Implementation  
**Primary Platform:** Snowflake  
**Cloud:** Azure ADLS Gen2

## 1. Purpose

Defines deployment sequence, operational procedures, validation checks, recovery, and day-to-day runbook activities for the platform.

## 2. Deployment Principles

- Deploy in dependency order.
- Validate each layer before moving downstream.
- Keep configuration separate from code.
- Never commit credentials or secrets to GitHub.
- Prefer repeatable and documented deployment steps.

## 3. Deployment Scope

Deployment covers:

- Azure ADLS Gen2 landing
- Snowflake database and schemas
- File formats and stages
- RAW/STAGING/CORE/MART structures
- Historical ingestion
- Python GBFS automation
- Linux/Bash operations
- Snowpipe
- Streams and Tasks
- Data-quality checks
- Monitoring/audit objects
- Data marts
- Power BI connectivity
- End-to-end testing

## 4. Deployment Order

```text
1. Azure storage
2. Snowflake account/database/schema
3. File formats and stages
4. RAW tables
5. Historical ingestion
6. STAGING transformations
7. CORE model
8. Python GBFS ingestion
9. Snowpipe
10. Streams and Tasks
11. Data-quality and audit objects
12. Data marts
13. Power BI connection
14. End-to-end testing
```

## 5. Environment Preparation

Confirm:

- Azure access
- ADLS container/path availability
- Snowflake access
- Required roles
- Warehouse availability
- Python runtime
- Linux environment
- Required Python packages
- Secure configuration

## 6. Azure ADLS Setup

Create the storage account with hierarchical namespace enabled, create the project container, and establish the landing structure:

```text
historical/trips/YYYY/MM/
gbfs/station_status/YYYY/MM/DD/
gbfs/vehicle_status/YYYY/MM/DD/
archive/
quarantine/
```

Validate that files can be uploaded and accessed using the intended permissions.

## 7. Snowflake Foundation

Create and validate the required:

- Database
- Schemas
- Warehouses
- Roles
- File formats
- External stages

Candidate logical schemas:

```text
RAW
STAGING
CORE
MART
AUDIT
```

Run the Snowflake setup files in dependency order:

```sql
-- Execute from the repository sql/ directory in Snowflake, Snowsight, or DataGrip.
01_database_schema.sql
02_file_formats.sql
03_raw_tables.sql
04_staging_tables.sql
05_core_tables.sql
06_mart_tables.sql
07_external_stages.sql
```

## 8. Historical Deployment

```text
ADLS File
 → External Stage
 → COPY INTO
 → RAW
 → Validation
 → STAGING
 → CORE
 → MART
```

Validation gates:

- File visible through stage
- File format works
- Load succeeds
- Row counts are reasonable
- Load errors reviewed
- RAW data exists
- STAGING transformations succeed
- CORE grain/relationships validate
- MART reconciles to CORE

Operational command:

```sql
08_historical_ingestion.sql
```

## 9. GBFS Deployment

```text
GBFS API
 → Python
 → Validation
 → Timestamped JSON
 → ADLS
 → Snowpipe
 → RAW
 → Stream
 → Task
 → STAGING
 → CORE
 → MART
```

Validate API response, JSON structure, file creation, ADLS arrival, Snowpipe ingestion, stream changes, task execution, and downstream data.

Current implementation boundary:

- Python writes validated GBFS JSON snapshots locally under `python/gbfs_ingestion/output/`.
- Upload those files to the configured ADLS `gbfs/` path.
- Snowflake loads the files through `PIPE_GBFS`.
- The stream/task procedure transforms GBFS RAW rows into STAGING, CORE, and MART.

Operational commands:

```bash
cd python/gbfs_ingestion
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python main.py
```

After the generated JSON files are uploaded to ADLS:

```sql
09_gbfs_ingestion.sql
10_streams_tasks.sql
```

## 10. Python Environment

Create a project virtual environment and install only required packages. Configuration and credentials remain outside source code.

The GBFS script should support controlled retries, validation, timestamped file creation, logging, and meaningful exit status.

## 11. Linux/Bash Operations

Operational scripts should:

- Use explicit paths/configuration
- Check command exit codes
- Write useful logs
- Fail visibly when required commands fail
- Avoid printing secrets

## 12. Data Quality Deployment

Deploy validation rules after RAW/STAGING/CORE objects exist. Store quality results where implemented and define severity handling before enabling downstream consumption.

Operational command:

```sql
11_quality_audit_validation.sql
```

## 13. Monitoring Deployment

Add audit/monitoring structures for:

- Pipeline runs
- Source/file arrival
- Load status
- Snowpipe
- Streams
- Tasks
- Quality checks
- CORE/MART reconciliation

Operational commands:

```sql
12_audit_monitoring.sql
13_validation_queries.sql
```

## 14. Power BI Deployment

Connect Power BI only to curated marts or governed analytical views. Validate KPI totals against Snowflake before publishing dashboards.

## 15. Pre-Deployment Checklist

- [ ] Azure access verified
- [ ] ADLS paths created
- [ ] Snowflake access verified
- [ ] Roles configured
- [ ] Warehouse available
- [ ] File formats created
- [ ] Stages created
- [ ] RAW tables created
- [ ] Historical load tested
- [ ] STAGING tested
- [ ] CORE tested
- [ ] Python environment tested
- [ ] GBFS ingestion tested
- [ ] Snowpipe tested
- [ ] Streams/Tasks tested
- [ ] Quality checks tested
- [ ] Audit/monitoring tested
- [ ] MARTs validated
- [ ] Power BI connectivity validated

## 15.1 Full Execution Order

Use this order for a full rebuild or first deployment:

```text
sql/01_database_schema.sql
sql/02_file_formats.sql
sql/03_raw_tables.sql
sql/04_staging_tables.sql
sql/05_core_tables.sql
sql/06_mart_tables.sql
sql/07_external_stages.sql
sql/08_historical_ingestion.sql
python/gbfs_ingestion/main.py
sql/09_gbfs_ingestion.sql
sql/10_streams_tasks.sql
sql/11_quality_audit_validation.sql
sql/12_audit_monitoring.sql
sql/13_validation_queries.sql
```

## 16. Failure Recovery

```text
Failure
 → Identify First Failed Stage
 → Inspect Logs / Metadata
 → Correct Root Cause
 → Revalidate
 → Reprocess
 → Check Idempotency
 → Reconcile Downstream
```

Source data should be recoverable from ADLS or RAW where possible.

## 17. Reprocessing Rules

- Do not rerun blindly.
- Identify the failure first.
- Correct the underlying issue.
- Preserve source traceability.
- Prevent duplicate analytical records.
- Verify downstream row counts and KPIs.

## 18. Security Checklist

- [ ] No credentials in GitHub
- [ ] Secrets outside source code
- [ ] Least-privilege permissions
- [ ] Logs contain no tokens/secrets
- [ ] Production-like access separation is documented where applicable

## 19. Operational Commands

Exact Azure CLI, SnowSQL, Python, Linux, Snowpipe, Stream, Task, and validation commands will be added alongside the implementation so the runbook reflects the actual deployed project rather than hypothetical commands.

## 20. Status

**Version 1.0 — Final Baseline.** Operational commands and restart procedures are implementation-dependent and will be added as the corresponding components are built.
