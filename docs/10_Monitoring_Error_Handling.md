# 10 — Monitoring & Error Handling

**Version:** 1.0  
**Status:** Final Baseline — Operational Thresholds to be Refined During Implementation

## 1. Purpose

Defines monitoring, observability, failure detection, logging, recovery, and error handling for the platform.

## 2. Monitoring Objectives

Detect:

- Pipeline failures
- Source/API problems
- Ingestion issues
- Data-quality failures
- Transformation failures
- Abnormal processing behavior
- Downstream reporting problems

## 3. Monitoring Architecture

```text
Source/API
 → Python Validation
 → ADLS
 → Snowflake Stage
 → RAW
 → STAGING
 → CORE
 → DATA MARTS
 → Power BI
```

Monitoring and audit metadata should be captured across the pipeline wherever practical.

## 4. Monitoring Layers

| Layer | Signals |
|---|---|
| Source | Availability and file/API arrival |
| Ingestion | COPY, Snowpipe, load errors |
| Transformation | Streams, Tasks, SQL execution, row counts |
| Data Quality | Rule execution and failures |
| Analytics | Mart refresh and reporting readiness |

## 5. Pipeline Run Metadata

Where implemented, capture:

- Pipeline/run ID
- Source system
- Source file/feed
- Start/end time
- Status
- Records processed
- Records rejected
- Processing duration
- Error details

## 6. Historical File Monitoring

Monitor expected arrival, naming, size, format, duplicate files, load status, row counts, rejected rows, and completion.

## 7. GBFS API Monitoring

Monitor HTTP status, API availability, response latency where practical, JSON validity, expected structure, empty responses, retry count, and successful snapshot creation.

## 8. ADLS Monitoring

Monitor expected paths, file presence, file timestamps, unexpected files, quarantine activity, and availability of required downstream data.

## 9. Snowflake Stage Monitoring

Monitor stage accessibility, file visibility, file-format compatibility, and external access failures.

## 10. COPY INTO Monitoring

For historical ingestion monitor execution, loaded files, loaded rows, rejected rows, and load errors. Load history supports investigation.

## 11. Snowpipe Monitoring

For recurring GBFS ingestion monitor file detection, ingestion failures, backlog, and processing latency where practical.

## 12. Stream Monitoring

Monitor whether expected changes appear in Streams and whether downstream Tasks consume them. Unusually empty or large change volumes should be investigated.

## 13. Task Monitoring

Monitor execution status, failures, duration, scheduling behavior, and dependency failures. Failed tasks must not silently appear as successful pipeline runs.

## 14. Data Quality Monitoring

Monitor rule execution, records checked, records failed, failure percentage, severity, and quality status. Critical failures should block or isolate affected downstream processing.

## 15. CORE Monitoring

Validate fact/dimension row counts, relationship integrity, expected grain, duplicate behavior, and transformation completion.

## 16. MART Monitoring

Monitor refresh status, row counts, KPI availability, and reconciliation checks before Power BI consumption.

## 17. Error Classification

- Source error
- API/network error
- File error
- Ingestion error
- Schema error
- Data-quality error
- Transformation error
- Warehouse error
- Downstream/reporting error

## 18. Severity Levels

| Severity | Meaning |
|---|---|
| CRITICAL | Trusted processing cannot safely continue |
| HIGH | Significant impact requiring prompt investigation |
| MEDIUM | Localized issue with limited downstream impact |
| LOW | Informational or minor |

## 19. Python Error Handling

Python uses bounded retries for transient API/network failures, validates responses before writing files, captures exceptions, logs meaningful details, and exits with a failure state when processing cannot safely continue.

## 20. Linux/Bash Error Handling

Shell scripts should check exit codes, avoid silently ignoring failures, write operational logs, and return a non-success status when required commands fail.

## 21. Snowflake Error Handling

Snowflake load and transformation failures should be captured through available execution/load metadata and investigated before rerunning affected processing.

## 22. Quarantine Strategy

Invalid files, malformed API responses, or data that cannot safely proceed may be placed in quarantine. Quarantine entries preserve source information and failure reason.

## 23. Retry Strategy

Retries are for transient conditions. Persistent source/schema errors stop the affected flow and require investigation rather than indefinite retries.

## 24. Idempotent Recovery

Recovery should avoid duplicates. Source file identifiers, snapshot timestamps, hashes where implemented, and documented business keys may support duplicate prevention.

## 25. Failure Flow

```text
Pipeline
 → Failure Detection
 → Log Error
 → Classify Severity
 → Quarantine / Stop if Required
 → Root Cause Analysis
 → Correction
 → Revalidation
 → Reprocess
 → Verify Downstream Results
```

## 26. Recovery Scenarios

| Scenario | Response |
|---|---|
| Missing historical file | Identify source issue and delay/retry |
| Invalid GBFS response | Retry, log, skip snapshot if necessary |
| Malformed file | Quarantine and investigate |
| Snowflake load failure | Inspect load error and correct cause |
| Transformation failure | Inspect SQL/task execution and rerun after correction |
| Data-quality failure | Isolate affected data and correct/document source issue |

## 27. Alerting

The implementation should surface meaningful failures without excessive alerts. Critical and high-severity failures must be visible to the operator. The exact notification mechanism is selected during implementation.

## 28. Audit View

A Snowflake audit structure may expose pipeline status, source, load ID, timestamps, records processed, failures, and quality status.

## 29. Candidate Metrics

- Pipeline success rate
- Pipeline duration
- Source arrival delay
- API failure rate
- Ingestion latency
- Records processed/rejected
- Data-quality failure rate
- Task failure count
- Mart refresh status
- Retry count

## 30. Threshold Principle

Operational thresholds should be defined after observing actual source behavior and pipeline performance. Avoid arbitrary thresholds unsupported by source or business requirements.

## 31. Root Cause Analysis

For a failure, identify the first failed stage, affected source/file/run, error message, downstream impact, corrective action, and reprocessing result. Recurring issues should have documented root-cause findings.

## 32. Security

Logs must not expose credentials, tokens, or sensitive configuration. Secrets remain outside source code and operational logs.

## 33. Implementation Order

1. Define audit metadata.
2. Add Python logging.
3. Add ADLS/file validation.
4. Monitor COPY/load history.
5. Monitor Snowpipe.
6. Monitor Streams and Tasks.
7. Implement data-quality results.
8. Add CORE/MART reconciliation.
9. Add operational reporting.
10. Test failure and recovery scenarios.

## 34. Status

**Version 1.0 — Final Baseline.** Exact thresholds, notification mechanisms, and operational commands are finalized during implementation.
