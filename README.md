# 🚲 Urban Mobility & Fleet Intelligence

### ❄️ Snowflake-Centric Data Engineering Project

An end-to-end Data Engineering platform built using **Snowflake, Azure ADLS Gen2, Python, SQL, Linux, and Power BI**, using real Divvy mobility data.

---

## 🏗️ Architecture

![Project Architecture](assets/project_architecture.png)

**Divvy Data → Azure ADLS Gen2 → Snowflake → Data Marts → Power BI**

---

## 🔄 Data Pipeline

![Data Pipeline](assets/data_flow.png)

The pipeline combines **historical trip data** with **GBFS mobility feeds** and processes them through the Snowflake data platform.

---

## ❄️ Snowflake Data Platform

![Snowflake Architecture](assets/snowflake_layers.png)

`RAW → STAGING → CORE → DATA MARTS`

Snowflake is the central platform for ingestion, transformation, modeling, and analytics.

---

## 🗄️ Data Model

![Star Schema](assets/star_schema.png)

Dimensional modeling supports trip, station, fleet, and rider analytics.

---

## ☁️ Azure Data Lake

![Azure ADLS](assets/adls_structure.png)

Azure **ADLS Gen2** acts as the cloud landing layer between external data sources and Snowflake.

---

## 🐍 Python Ingestion

![Python GBFS Ingestion](assets/python_ingestion.png)

Python handles GBFS API extraction, JSON processing, validation, logging, and ingestion preparation.

---

## 🧪 Data Quality

![Data Quality](assets/data_quality.png)

Validation covers:

- Null values
- Duplicates
- Invalid timestamps
- Invalid trip durations
- Invalid station references
- Malformed JSON

---

## 📊 Power BI

![Power BI Dashboard](assets/powerbi_dashboard.png)

**Trips • Stations • Fleet • Riders**

---

## 🧰 Technology Stack

| Area | Technology |
|---|---|
| Cloud | Azure |
| Storage | ADLS Gen2 |
| Data Warehouse | Snowflake |
| Transformation | SQL / ELT |
| Programming | Python |
| Automation | Linux / Bash |
| BI | Power BI |
| Version Control | Git / GitHub |

---

## 📚 Documentation

| Document | Description |
|---|---|
| [Business Requirements](docs/01_Business_Requirements.md) | Business objectives |
| [Source & Data Dictionary](docs/02_Source_and_Data_Dictionary.md) | Source data |
| [Architecture](docs/03_HLD_Architecture.md) | Technical architecture |
| [Data Flow](docs/04_Data_Flow_Diagram.md) | End-to-end pipeline |
| [Data Model](docs/05_Data_Model_Star_Schema.md) | Star schema |
| [Source-to-Target Mapping](docs/06_Source_to_Target_Mapping.md) | Transformation mapping |
| [ETL Design](docs/07_Pipeline_ETL_Design.md) | Pipeline implementation |
| [Data Quality](docs/08_Data_Quality_Validation.md) | Validation framework |
| [Data Lineage](docs/09_Data_Lineage.md) | Source-to-report lineage |
| [Monitoring](docs/10_Monitoring_Error_Handling.md) | Operational monitoring |
| [Deployment](docs/11_Deployment_Runbook.md) | Deployment process |

---

## 🌿 Development

```text
main
  │
  └── onkar
       │
       └── Pull Request → main
```

Development is performed on the `onkar` branch while `main` remains the stable branch.

---

## 👨‍💻 Author

**Onkar Jadhav**

Aspiring Data Engineer

**SQL • Snowflake • Azure • Python • Data Engineering**
