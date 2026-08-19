🚲 Urban Mobility & Fleet Intelligence
❄️ Snowflake-Centric Data Engineering Project
An end-to-end Data Engineering platform built using Snowflake, Azure ADLS Gen2, Python, SQL, Linux, and Power BI, using real Divvy mobility data.
🏗️ Architecture
Divvy Data → Azure ADLS Gen2 → Snowflake → Data Marts → Power BI
🔄 Data Pipeline
The pipeline combines historical trip data with GBFS mobility feeds and processes them through the Snowflake data platform.
❄️ Snowflake Data Platform
RAW → STAGING → CORE → DATA MARTS
Snowflake is the central platform for ingestion, transformation, modeling, and analytics.
🗄️ Data Model
Dimensional modeling supports trip, station, fleet, and rider analytics.
☁️ Azure Data Lake
Azure ADLS Gen2 acts as the cloud landing layer between external data sources and Snowflake.
🐍 Python Ingestion
Python handles GBFS API extraction, JSON processing, validation, logging, and ingestion preparation.
🧪 Data Quality
Validation covers:
Null values
Duplicates
Invalid timestamps
Invalid trip durations
Invalid station references
Malformed JSON
📊 Power BI
Trips • Stations • Fleet • Riders
🧰 Technology Stack
Area	Technology
Cloud	Azure
Storage	ADLS Gen2
Data Warehouse	Snowflake
Transformation	SQL / ELT
Programming	Python
Automation	Linux / Bash
BI	Power BI
Version Control	Git / GitHub
📚 Documentation
Document	Description
Business Requirements	Business objectives
Source & Data Dictionary	Source data
Architecture	Technical architecture
Data Flow	End-to-end pipeline
Data Model	Star schema
Source-to-Target Mapping	Transformation mapping
ETL Design	Pipeline implementation
Data Quality	Validation framework
Data Lineage	Source-to-report lineage
Monitoring	Operational monitoring
Deployment	Deployment process
🌿 Development
main
  │
  └── onkar
       │
       └── Pull Request → main
Development is performed on the onkar branch while main remains the stable branch.
👨‍💻 Author
Onkar Jadhav
Aspiring Data Engineer
SQL • Snowflake • Azure • Python • Data Engineering