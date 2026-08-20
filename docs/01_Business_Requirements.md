# 01 — Business Requirements

**Project:** Urban Mobility & Fleet Intelligence  
**Version:** 1.0  
**Status:** Final Baseline  
**Primary Platform:** Snowflake  
**Cloud Platform:** Microsoft Azure  
**Analytics:** Power BI  
**Data Sources:** Divvy Historical Trips + Divvy GBFS

## 1. Project Overview

Urban Mobility & Fleet Intelligence is a Snowflake-centric data engineering portfolio project for analyzing urban shared-mobility operations. It integrates historical Divvy trip data and Divvy GBFS mobility information through Azure Data Lake Storage Gen2, Snowflake SQL/ELT, Python, Linux/Bash, and Power BI.

This is an independent portfolio implementation based on publicly available data. It does not represent an internal Divvy or Lyft system and does not assume access to proprietary operational data.

## 2. Business Problem

Urban shared-mobility systems produce large volumes of trip and fleet-availability data. Without a centralized analytical platform, it is difficult to consistently answer operational questions such as:

- When is mobility demand highest?
- Which stations have the highest demand?
- Which stations are underutilized?
- Which stations frequently have limited availability?
- How does demand vary by time?
- How does rider behavior differ between rider categories?
- How does fleet availability change throughout the day?
- Which locations may require operational attention?

The project addresses this by building a reliable analytical platform that combines historical events with recurring mobility snapshots.

## 3. Business Objectives

1. Centralize historical mobility trip data.
2. Integrate near-real-time mobility information from GBFS feeds.
3. Provide a consistent analytical data model.
4. Enable trip-demand and mobility-pattern analysis.
5. Provide station and fleet availability visibility.
6. Identify high-demand and underutilized locations.
7. Support rider-behavior analysis.
8. Provide curated analytical datasets for BI.
9. Establish automated and repeatable ingestion processes.
10. Demonstrate a scalable Snowflake-centric data engineering architecture.

## 4. Conceptual Stakeholders

| Stakeholder | Analytical Need |
|---|---|
| Operations | Fleet and station availability |
| Mobility Management | Demand and utilization trends |
| Business Analysts | Curated datasets and KPIs |
| Data Analysts | Trusted analytical data |
| Data Engineers | Reliable ingestion and transformation |
| BI / Reporting | Power BI dashboards |
| Business Management | Operational performance visibility |

These are conceptual stakeholders for the portfolio project, not actual internal Divvy roles.

## 5. Business Questions

### Trip Demand
- Trips per day, week, and month
- Peak hours and periods
- Busiest days
- Highest-demand origin and destination stations

### Station Intelligence
- Highest-demand stations
- Underutilized stations
- Stations with low availability
- Changes in demand throughout the day

### Fleet Intelligence
- Vehicle availability
- Availability over time
- Vehicle-type distribution where supported
- Locations experiencing availability pressure

### Rider Behaviour
- Usage by rider category
- Average trip duration by category
- Popular periods by category
- Rider trends over time

### Operations
- Daily and monthly mobility trends
- Peak operating periods
- Geographic demand patterns
- Relationship between demand and fleet availability

## 6. Key KPIs

### Trip KPIs
- Total Trips
- Daily / Weekly / Monthly Trips
- Average Trip Duration
- Peak Hour Trip Volume

### Station KPIs
- Trips Originating from Station
- Trips Ending at Station
- Station Demand
- Station Utilization
- Station Availability

### Fleet KPIs
- Available Vehicles
- Vehicle Availability
- Vehicle Utilization
- Vehicle Type Distribution, where supported

### Rider KPIs
- Trips by Rider Category
- Rider Category Distribution
- Average Trip Duration by Rider Category
- Rider Usage Trends

## 7. Scope

### In Scope

- Divvy historical trip data
- Divvy GBFS feeds
- Azure ADLS Gen2
- Snowflake
- SQL / ELT
- Batch ingestion
- Incremental processing
- Semi-structured JSON processing
- Python
- Linux/Bash
- Data marts
- Power BI
- Data quality
- Error handling
- Monitoring
- Lineage
- Performance and cost awareness

### Out of Scope

- Hadoop
- Apache Spark
- Databricks
- Kafka
- Airflow
- AWS
- Proprietary Divvy systems
- Proprietary telemetry, maintenance, payment, or customer data
- Machine-learning prediction models
- Real-world production deployment

## 8. Data Processing Requirements

The target flow is:

```text
Public Source
    ↓
Azure ADLS Gen2
    ↓
Snowflake RAW
    ↓
STAGING
    ↓
CORE
    ↓
DATA MARTS
    ↓
Power BI
```

Historical files follow a batch pattern. GBFS follows an API-to-file pattern supported by Python.

## 9. Data Quality Requirements

The platform should identify and handle:

- Missing required values
- Duplicate records and duplicate files
- Invalid timestamps
- Invalid trip durations
- Invalid station references
- Invalid geographic values
- Unexpected categories
- Malformed JSON
- Schema changes

Quality results should be recorded for monitoring and troubleshooting.

## 10. Automation Requirements

**Python:** GBFS extraction, API validation, JSON creation, timestamped naming, retries, and logging.  
**Linux/Bash:** execution, file operations, logs, environment configuration, and utilities.  
**Snowflake:** ingestion, ELT, incremental processing, modeling, and analytical preparation.

## 11. Reporting Requirements

Power BI consumes curated Snowflake data marts rather than RAW tables.

Planned analytical areas:

1. Mobility Overview
2. Fleet & Station Intelligence
3. Rider Analytics
4. Operations Analytics

Dashboards should emphasize actionable KPIs rather than raw source data.

## 12. Security Requirements

- Role-based access control
- Separation of engineering and analytical access
- Secure credential handling
- No secrets committed to GitHub
- Environment variables or secure configuration for sensitive values
- Least-privilege Azure and Snowflake permissions

## 13. Performance & Cost Requirements

- Appropriate warehouse sizing
- Auto-suspend where appropriate
- Avoid unnecessary full-table processing
- Prefer incremental processing where justified
- Review expensive queries
- Use Query Profile during optimization
- Consider clustering only when supported by workload evidence

Advanced Snowflake features are introduced only when they solve a real requirement.

## 14. Success Criteria

The project is successful when:

- Real Divvy historical data is ingested.
- Divvy GBFS data is integrated.
- ADLS Gen2 operates as the cloud landing layer.
- Snowflake operates as the central analytical platform.
- RAW, STAGING, CORE, and MART layers are implemented.
- Batch and incremental ingestion are demonstrated.
- GBFS JSON is processed using Snowflake semi-structured capabilities.
- Python and Linux/Bash automation are implemented.
- Data-quality checks are implemented.
- Curated marts are available to Power BI.
- Failures and quality issues can be identified and recovered.
- The complete architecture can be explained in a Data Engineering interview.

## 15. Constraints

The project depends on public-source availability. Historical and GBFS schemas may differ and may contain limitations or inconsistencies. The implementation must adapt to verified public-source capabilities and must not fabricate unavailable business data.

## 16. Document Dependencies

```text
01 Business Requirements
 → 02 Source & Data Dictionary
 → 03 HLD / Architecture
 → 04 Data Flow
 → 05 Data Model
 → 06 Source-to-Target Mapping
 → 07 Pipeline Design
 → 08 Data Quality
 → 09 Data Lineage
 → 10 Monitoring & Error Handling
 → 11 Deployment / Runbook
 → 12 Main README
```

## 17. Status

**Version 1.0 — Final Baseline.** Changes should only be introduced when a significant technical, business, data-source, or architectural requirement is identified.
