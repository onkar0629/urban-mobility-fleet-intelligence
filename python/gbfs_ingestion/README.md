# GBFS Ingestion

Python-based ingestion component for the **Urban Mobility & Fleet Intelligence** project.

This module retrieves real-time Divvy GBFS feeds, validates the responses, adds ingestion metadata, and stores timestamped JSON snapshots for downstream processing.

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
```

> ADLS Gen2 integration will be enabled when Azure access is available.

## Feeds

| Feed | Purpose |
|---|---|
| `station_status` | Station availability and dock information |
| `free_bike_status` | Individual bike availability and location |

Feed URLs are discovered dynamically through the GBFS discovery document rather than being hard-coded.

## Project Structure

```text
gbfs_ingestion/
│
├── main.py
├── config.py
├── gbfs_client.py
├── validator.py
├── file_writer.py
├── requirements.txt
├── README.md
│
└── output/
    └── *.json
```

### Components

**`main.py`**
- Controls the ingestion workflow
- Retrieves configured feeds
- Runs validation
- Saves JSON snapshots

**`gbfs_client.py`**
- Connects to the GBFS discovery endpoint
- Resolves current feed URLs
- Retrieves individual feeds

**`validator.py`**
- Validates GBFS responses
- Checks expected feed structures and records

**`file_writer.py`**
- Creates timestamped JSON files
- Generates a unique `load_id`
- Stores ingestion timestamp and source URL
- Preserves the raw feed payload

**`config.py`**
- Stores GBFS discovery configuration
- Defines feeds to ingest
- Defines the local output directory

## Output

Each successful ingestion creates a timestamped snapshot.

Example:

```text
output/
├── station_status_20260820T060426Z.json
└── free_bike_status_20260820T060427Z.json
```

The generated JSON contains ingestion metadata such as:

```json
{
  "ingestion_metadata": {
    "source_system": "DIVVY_GBFS",
    "feed_name": "station_status",
    "source_url": "...",
    "load_id": "...",
    "ingestion_timestamp": "..."
  },
  "last_updated": 1787215466,
  "ttl": 30,
  "data": {
    "stations": []
  }
}
```

The original GBFS payload is preserved rather than flattened during extraction.

## Setup

Create and activate a virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

## Run

From the `gbfs_ingestion` directory:

```bash
python main.py
```

Expected output:

```text
Fetching station_status...
Successfully saved: .../station_status_<timestamp>.json

Fetching free_bike_status...
Successfully saved: .../free_bike_status_<timestamp>.json
```

## Design Principles

- Dynamic GBFS feed discovery
- Raw payload preservation
- Timestamped snapshots
- Unique load identifiers
- Source URL traceability
- Basic feed validation
- Separation of extraction and downstream transformation
- Ready for ADLS Gen2 integration

## Downstream Integration

The generated JSON snapshots are designed to become the source files for the next stage of the pipeline:

```text
Python
  ↓
ADLS Gen2
  ↓
Snowflake External Stage
  ↓
RAW_GBFS
  ↓
STAGING
  ↓
CORE
  ↓
MART
  ↓
Power BI
```
