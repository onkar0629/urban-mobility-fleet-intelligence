# GBFS Ingestion

Python-based ingestion component for the **Urban Mobility & Fleet Intelligence** project.

This module retrieves real-time Divvy GBFS feeds, validates the responses, adds ingestion metadata, and stores timestamped JSON snapshots for downstream processing.

---

## Pipeline

```text
Divvy GBFS API
      ↓
GBFS Discovery
      ↓
Feed URL Resolution
      ↓
Python Extraction
      ↓
Validation
      ↓
Ingestion Metadata
      ↓
Timestamped JSON
      ↓
ADLS Gen2
      ↓
Snowflake RAW