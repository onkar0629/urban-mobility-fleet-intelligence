# 08 — Data Quality & Validation

**Version:** 1.0  
**Status:** Final Baseline — Rules to be Refined After Source Profiling  
**Validation:** Python + Snowflake SQL

## 1. Purpose

The data-quality framework identifies invalid, incomplete, duplicated, inconsistent, or unexpected data before it reaches trusted analytical layers.

## 2. Quality Objectives

Data should be:

- Suitable for defined analytical use cases
- Structurally valid
- Traceable to source
- Consistently transformed
- Reliable enough for Power BI reporting

## 3. Data Quality Dimensions

The project evaluates, where applicable:

1. Completeness
2. Uniqueness
3. Validity
4. Consistency
5. Accuracy / reasonableness
6. Timeliness
7. Integrity

## 4. Validation Architecture

```text
Source
 → Python Validation
 → ADLS Gen2
 → Snowflake RAW
 → STAGING Validation
 → CORE Validation
 → DATA MART Validation
 → Power BI
```

## 5. Validation Responsibilities

| Layer | Validation Focus |
|---|---|
| Python | API/file conditions |
| RAW | Ingestion completeness and structure |
| STAGING | Types, nulls, duplicates, source rules |
| CORE | Business rules, relationships, grain |
| MART | KPI integrity and reporting readiness |

## 6. File-Level Validation

Validate:

- File presence
- Expected extension/format
- Non-zero size where applicable
- Readability
- Naming convention
- Duplicate file detection
- Basic structural expectations

## 7. API-Level Validation

For GBFS:

- HTTP response status
- API availability
- Valid JSON
- Expected top-level structure
- Required feed attributes where known
- Non-empty payload where expected
- Reasonable response behavior

## 8. Schema Validation

Required source fields must exist and observed types must be compatible with processing logic. Schema changes must be detected rather than silently ignored.

## 9. Completeness Checks

Candidate checks:

- Required field null rates
- Missing source records where expected
- Empty API responses
- Expected feed sections
- Loaded versus source row counts

## 10. Uniqueness Checks

Identify:

- Duplicate source records
- Duplicate source files
- Duplicate GBFS snapshots
- Duplicate business keys
- Duplicate records before `MERGE`

## 11. Validity Checks

Validate values such as:

- Timestamps
- Trip duration
- Latitude/longitude
- Station identifiers
- Rider categories
- Availability measures
- Status values

Exact ranges are finalized after profiling actual source behavior.

## 12. Consistency Checks

Check consistency between related fields and layers, including:

- Start/end timestamps
- Station references
- Fact/dimension relationships
- Snapshot timestamps
- Source-to-target row counts
- Standardized data types

## 13. Referential Integrity

Where relationships exist, validate that fact references resolve to the appropriate dimensions. Exceptions should be logged and handled according to severity.

## 14. CORE Validation

Validate:

- Fact grain
- Dimension uniqueness
- Relationship integrity
- Duplicate behavior
- Business-rule compliance
- Expected row counts

## 15. MART Validation

Validate:

- KPI totals
- Aggregation logic
- Row counts
- Null behavior
- Reconciliation to CORE
- Reporting readiness

## 16. Severity

| Severity | Meaning |
|---|---|
| Critical | Trusted processing cannot safely continue |
| High | Significant data impact |
| Medium | Localized impact |
| Low | Informational/minor |

## 17. Quality Result Metadata

Where implemented, record:

- Pipeline/run ID
- Dataset/table
- Rule ID
- Execution timestamp
- Records checked
- Records failed
- Failure percentage
- Severity
- Quality status
- Error details

## 18. Handling Failed Quality Checks

```text
Validation
   ├── Pass → Continue
   └── Fail → Log → Isolate/Reject/Quarantine → Investigate
```

Critical failures should protect trusted downstream layers from invalid data.

## 19. Reprocessing

After correction:

```text
Failure
 → Root Cause
 → Correction
 → Revalidation
 → Reprocessing
 → Downstream Verification
```

Recovery must avoid duplicate analytical records.

## 20. Implementation Order

1. File validation
2. API validation
3. RAW load checks
4. STAGING null/duplicate/type checks
5. CORE relationship and grain checks
6. MART reconciliation
7. Quality audit logging
8. Failure/recovery testing

## 21. Status

**Version 1.0 — Final Baseline.** Exact rules and thresholds are refined after source profiling so that validations reflect verified source behavior rather than arbitrary assumptions.
