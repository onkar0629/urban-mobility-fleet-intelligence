# 🚲 Urban Mobility & Fleet Intelligence

### ❄️ End-to-End Data Engineering Project

A production-oriented Data Engineering project for urban mobility analytics, combining **Azure, ADLS Gen2, Snowflake, Python, SQL, Linux, and Power BI**.

---

## 🏗️ Architecture

![Project Architecture](assets/project_architecture.png)

**Divvy Data → Azure ADLS Gen2 → Snowflake → Data Marts → Power BI**

---

## 🔄 Data Engineering Flow

![Data Flow](assets/data_flow.png)

The platform brings together historical mobility data and GBFS mobility feeds through a cloud-based data engineering pipeline.

---

## ❄️ Platform Layers

```text
Source
  ↓
Azure ADLS Gen2
  ↓
Snowflake
  ↓
RAW → STAGING → CORE → DATA MARTS
  ↓
Power BI
```

---

## 🧰 Technology Stack

| Area | Technology |
|---|---|
| Cloud | Microsoft Azure |
| Cloud Storage | ADLS Gen2 |
| Data Warehouse | Snowflake |
| Transformation | SQL / ELT |
| Programming | Python |
| Automation | Linux / Bash |
| BI | Power BI |
| Version Control | Git / GitHub |

---

## ⚙️ Key Data Engineering Concepts

- Batch and incremental data ingestion
- Snowflake layered data architecture
- SQL-based ELT transformations
- Semi-structured JSON processing
- Dimensional data modeling
- Data quality validation
- Data lineage
- Monitoring and error handling
- Cloud data lake integration
- Role-based access and secure configuration

---

## 📊 Analytics

The platform is designed to support:

**Trips • Stations • Fleet • Riders • Operations**

Power BI will consume curated analytical data from Snowflake.

---

## 📚 Project Documentation

| Document | Description |
|---|---|
| [Business Requirements](docs/01_Business_Requirements.md) | Business objectives and KPIs |
| [Source & Data Dictionary](docs/02_Source_and_Data_Dictionary.md) | Source datasets and definitions |
| [HLD Architecture](docs/03_HLD_Architecture.md) | High-level architecture |
| [Data Flow](docs/04_Data_Flow_Diagram.md) | End-to-end data movement |
| [Data Model](docs/05_Data_Model_Star_Schema.md) | Dimensional model |
| [Source-to-Target Mapping](docs/06_Source_to_Target_Mapping.md) | Transformation mapping |
| [ETL Design](docs/07_Pipeline_ETL_Design.md) | Ingestion and transformation |
| [Data Quality](docs/08_Data_Quality_Validation.md) | Validation framework |
| [Data Lineage](docs/09_Data_Lineage.md) | Source-to-report lineage |
| [Monitoring & Error Handling](docs/10_Monitoring_Error_Handling.md) | Operational design |
| [Deployment Runbook](docs/11_Deployment_Runbook.md) | Deployment procedures |

---

## 📈 Project Status

**Phase 1 — Project Foundation**

- [x] Repository initialized
- [x] Project structure created
- [x] Python virtual environment configured
- [x] Documentation structure created
- [x] Git branching strategy established
- [ ] Source data profiling
- [ ] Azure ADLS Gen2 implementation
- [ ] Snowflake implementation
- [ ] Python ingestion pipeline
- [ ] Data quality framework
- [ ] Monitoring
- [ ] Power BI dashboards
- [ ] Deployment

---

## 🌿 Development Workflow

```text
main
  ↑
Pull Request
  ↑
onkar
  ↑
Development
```

`main` is maintained as the stable branch. Development work is performed on feature/developer branches and merged through Pull Requests.

---

## 👨‍💻 Author

**Onkar Jadhav**  
Aspiring Data Engineer

**SQL • Snowflake • Azure • Python • Data Engineering**

---

> ❄️ **Build. Validate. Monitor. Deliver.**
>
> A portfolio project focused on practical Data Engineering rather than dashboard-only development.
