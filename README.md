# 🚲 Urban Mobility & Fleet Intelligence

### ❄️ Snowflake-Centric Data Engineering Project

An end-to-end Data Engineering platform for urban mobility analytics, built around **Snowflake** with **Azure ADLS Gen2, Python, SQL, Linux, and Power BI**.

---

## 🏗️ Solution Architecture

![Project Architecture](assets/project_architecture.png)

**Divvy Historical Data + GBFS Feeds → Azure ADLS Gen2 → Snowflake → Data Marts → Power BI**

---

## ❄️ Snowflake-Centric Pipeline

```text
Sources
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

Snowflake is the central platform for **ingestion, transformation, data modeling, quality, and analytics**.

---

## 🧰 Technology Stack

| Layer | Technology |
|---|---|
| Cloud | Microsoft Azure |
| Storage | Azure ADLS Gen2 |
| Data Warehouse | Snowflake |
| Transformation | SQL / ELT |
| Programming | Python |
| Automation | Linux / Bash |
| BI | Power BI |
| Version Control | Git / GitHub |

---

## ⚙️ Key Data Engineering Concepts

- Batch & incremental data ingestion
- Snowflake layered architecture
- Semi-structured JSON processing
- Dimensional / Star Schema modeling
- Data quality validation
- Data lineage & auditability
- Monitoring & error handling
- Python API ingestion
- Cloud data lake integration

---

## 📚 Project Documentation

| Documentation | Focus |
|---|---|
| [Business Requirements](docs/01_Business_Requirements.md) | Business objectives & scope |
| [Source & Data Dictionary](docs/02_Source_and_Data_Dictionary.md) | Source data & definitions |
| [Architecture](docs/03_HLD_Architecture.md) | High-level architecture |
| [Data Flow](docs/04_Data_Flow_Diagram.md) | End-to-end data movement |
| [Data Model](docs/05_Data_Model_Star_Schema.md) | Facts & dimensions |
| [Source-to-Target Mapping](docs/06_Source_to_Target_Mapping.md) | Transformation mapping |
| [Pipeline / ETL Design](docs/07_Pipeline_ETL_Design.md) | Ingestion & ELT design |
| [Data Quality](docs/08_Data_Quality_Validation.md) | Validation framework |
| [Data Lineage](docs/09_Data_Lineage.md) | Source-to-report lineage |
| [Monitoring & Error Handling](docs/10_Monitoring_Error_Handling.md) | Operational monitoring |
| [Deployment Runbook](docs/11_Deployment_Runbook.md) | Deployment process |

---

## 🚧 Project Status

**Phase 1 — Repository & Development Environment Setup**

Next: **Source acquisition → profiling → Azure ADLS Gen2 → Snowflake ingestion → transformations → data marts → data quality → Power BI**

---

## 🌿 Development Workflow

```text
main
  │
  └── onkar
       │
       └── Pull Request → main
```

`main` is kept as the stable branch while development takes place on `onkar`.

---

## 👨‍💻 Author

**Onkar Jadhav**

Aspiring Data Engineer

**SQL • Snowflake • Azure • Python • Data Engineering**
