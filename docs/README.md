# 12 — Main Project README

**Project:** Urban Mobility & Fleet Intelligence  
**Version:** 1.0  
**Status:** Final Baseline  
**Project Type:** Snowflake-Centric Data Engineering Portfolio Project

## 1. Project Overview

Urban Mobility & Fleet Intelligence is an end-to-end data engineering project that builds an analytical platform for urban shared mobility. It integrates historical Divvy trip data and Divvy GBFS mobility information using Microsoft Azure, Snowflake, Python, Linux/Bash, SQL, and Power BI.

## 2. Business Problem

The platform centralizes trip, station, fleet, and rider information so mobility demand, station activity, fleet availability, rider behavior, and operational trends can be analyzed consistently.

## 3. Key Objectives

- Centralize historical mobility data
- Integrate GBFS mobility snapshots
- Build a reliable Snowflake analytical platform
- Demonstrate batch and incremental ingestion
- Implement ELT
- Automate external ingestion with Python/Linux
- Implement data quality and monitoring
- Create analytical data marts
- Deliver business insights through Power BI

## 4. Architecture

```text
Public Mobility Data
        ↓
Azure ADLS Gen2
        ↓
Snowflake External Stage
        ↓
RAW → STAGING → CORE → DATA MARTS
        ↓
Power BI
```

Python + Linux/Bash provide supporting automation. Snowpipe + Streams + Tasks support recurring/incremental processing where justified.

## 5. Technology Stack

| Category | Technology |
|---|---|
| Cloud | Microsoft Azure |
| Storage | Azure ADLS Gen2 |
| Data Warehouse | Snowflake |
| Transformation | Snowflake SQL / ELT |
| Programming | Python |
| Operating Environment | Linux/Bash |
| Analytics | Power BI |
| Version Control | Git/GitHub |

## 6. Snowflake Architecture

```text
DIVVY_DB
├── RAW
├── STAGING
├── CORE
├── MART
└── AUDIT
```

### Data Layers

- **RAW:** source-aligned data and ingestion metadata
- **STAGING:** typed, cleaned, standardized data
- **CORE:** trusted facts and dimensions
- **MART:** business-ready analytical datasets
- **AUDIT:** pipeline and operational metadata

## 7. Candidate Data Model

```text
Dimensions
├── DIM_DATE
├── DIM_TIME
├── DIM_STATION
├── DIM_RIDER
├── DIM_VEHICLE
└── DIM_VEHICLE_TYPE

Facts
├── FACT_TRIP
├── FACT_STATION_STATUS
└── FACT_VEHICLE_STATUS
```

Exact physical columns and relationships are finalized from verified source data.

## 8. Pipelines

### Historical

```text
Divvy File → ADLS → External Stage → COPY INTO → RAW
→ STAGING → CORE → MART → Power BI
```

### GBFS

```text
API → Python → Validation → JSON Snapshot → ADLS
→ Snowpipe → RAW → Stream → Task → STAGING
→ CORE → MART → Power BI
```

## 9. Data Quality

The project evaluates completeness, uniqueness, validity, consistency, reasonableness, timeliness, and referential integrity where applicable. Invalid data is logged, isolated, quarantined, or rejected according to severity.

## 10. Monitoring & Error Handling

Pipeline runs, source availability, ingestion, Snowpipe, Streams, Tasks, quality checks, transformations, and marts are monitored. Failures are classified, logged, investigated, corrected, and reprocessed in a controlled manner.

## 11. Automation

Python handles GBFS extraction, API validation, retries, JSON creation, timestamped files, and logging. Linux/Bash supports execution, file operations, environment configuration, and operational utilities.

## 12. Analytics

Power BI consumes curated Snowflake data marts. Planned analytical areas:

- Mobility Overview
- Fleet & Station Intelligence
- Rider Analytics
- Operations Analytics

## 13. Documentation Map

| Document | Purpose |
|---|---|
| [01 Business Requirements](01_Business_Requirements.md) | Business problem, objectives, KPIs, scope |
| [02 Source & Data Dictionary](02_Source_and_Data_Dictionary.md) | Source inventory and logical data elements |
| [03 HLD / Architecture](03_HLD_Architecture.md) | Technical architecture and responsibilities |
| [04 Data Flow](04_Data_Flow_Diagram.md) | End-to-end data movement |
| [05 Data Model](05_Data_Model_Star_Schema.md) | Facts, dimensions, grains, relationships |
| [06 Source-to-Target Mapping](06_Source_to_Target_Mapping.md) | Logical source/target traceability |
| [07 Pipeline / ETL Design](07_Pipeline_ETL_Design.md) | Batch, GBFS, incremental and ELT design |
| [08 Data Quality](08_Data_Quality_Validation.md) | Validation framework and quality gates |
| [09 Data Lineage](09_Data_Lineage.md) | Source-to-BI lineage |
| [10 Monitoring & Error Handling](10_Monitoring_Error_Handling.md) | Observability and recovery |
| [11 Deployment / Runbook](11_Deployment_Runbook.md) | Deployment and operational procedures |

## 14. Repository Structure

```text
urban-mobility-fleet-intelligence/
├── README.md
├── docs/
│   ├── 01_Business_Requirements.md
│   ├── 02_Source_and_Data_Dictionary.md
│   ├── 03_HLD_Architecture.md
│   ├── 04_Data_Flow_Diagram.md
│   ├── 05_Data_Model_Star_Schema.md
│   ├── 06_Source_to_Target_Mapping.md
│   ├── 07_Pipeline_ETL_Design.md
│   ├── 08_Data_Quality_Validation.md
│   ├── 09_Data_Lineage.md
│   ├── 10_Monitoring_Error_Handling.md
│   ├── 11_Deployment_Runbook.md
│   └── 12_Main_README.md
├── sql/
├── python/
├── linux/
├── powerbi/
├── tests/
└── assets/
```

## 15. Project Workflow

```text
Business Requirements
 → Source Profiling
 → Architecture
 → Data Flow
 → Data Model
 → Source-to-Target Mapping
 → Pipeline Design
 → Data Quality
 → Lineage
 → Monitoring
 → Deployment
 → Analytics
```

## 16. Interview Value

The project demonstrates practical Data Engineering concepts including:

- Snowflake architecture
- Azure cloud storage
- External stages
- `COPY INTO`
- Snowpipe
- Streams and Tasks
- Semi-structured JSON
- `VARIANT` and `FLATTEN()`
- Dimensional modeling
- SQL/ELT
- Python automation
- Linux operations
- Data quality
- Monitoring
- Lineage
- Power BI delivery

## 17. Important Design Principle

The project does not attempt to use every available technology. Each component has a defined responsibility, and advanced features are introduced only when they solve a real technical or business requirement.

## 18. Scope Boundaries

Hadoop and AWS are intentionally excluded. Proprietary mobility-company systems are not assumed, and unavailable proprietary data will not be fabricated.

## 19. Project Status

The architecture and documentation baseline is locked. Implementation proceeds using verified public source data. Source-specific details are updated only when actual profiling or implementation requires them.

## 20. Recommended Implementation Sequence

1. GitHub and project setup
2. Source acquisition and profiling
3. Azure ADLS setup
4. Snowflake foundation
5. Historical batch ingestion
6. Snowflake ELT and data model
7. Python GBFS automation
8. Snowpipe / Streams / Tasks
9. Data quality and monitoring
10. Data marts
11. Power BI
12. Testing, optimization, documentation, and interview preparation

## 21. Final Status

**Version 1.0 — Final Baseline.** This document defines the project's public-facing technical direction. Changes require a significant technical, business, data-source, or architectural requirement.
