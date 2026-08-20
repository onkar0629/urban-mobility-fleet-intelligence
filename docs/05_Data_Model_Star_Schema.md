# 05 — Data Model / Star Schema

**Version:** 1.0  
**Status:** Final Baseline — Logical Model; Physical Columns Pending Source Profiling  
**Modeling:** Dimensional / Star Schema

## 1. Purpose

The analytical model organizes mobility events into fact tables and descriptive entities into dimensions so curated Snowflake data marts can support Power BI.

## 2. Modeling Principles

- Facts represent measurable events or periodic snapshots.
- Dimensions provide descriptive context.
- Every fact has an explicit grain.
- Source/business keys are retained where useful for traceability.
- Surrogate keys may be introduced for warehouse dimensions.
- Frequently changing operational values belong in time-stamped facts when appropriate.

## 3. Candidate Dimensions

| Dimension | Purpose |
|---|---|
| `DIM_DATE` | Calendar and period analysis |
| `DIM_TIME` | Time-of-day and peak-period analysis |
| `DIM_STATION` | Station identity and descriptive attributes |
| `DIM_VEHICLE` | Vehicle identity where supported |
| `DIM_RIDER` | Rider/customer categories supported by source |
| `DIM_VEHICLE_TYPE` | Vehicle-type classifications where supported |

## 4. Candidate Facts

| Fact | Proposed Grain |
|---|---|
| `FACT_TRIP` | One completed/source trip record |
| `FACT_STATION_STATUS` | One station observation at one snapshot timestamp |
| `FACT_VEHICLE_STATUS` | One vehicle observation at one snapshot timestamp |

## 5. FACT_TRIP

### Grain

One row represents one completed/source trip record. This must be validated against the actual historical dataset before physical implementation.

### Candidate Measures

- Trip duration
- Trip count, derived by counting fact rows
- Other measurable trip attributes actually supplied by the source

### Relationships

Conceptually references:

- `DIM_DATE` for start/end dates
- `DIM_TIME` for start/end times
- `DIM_STATION` for origin/destination
- `DIM_RIDER` for rider category

Exact foreign-key design depends on verified source fields.

## 6. FACT_STATION_STATUS

### Grain

One row represents one station-status observation for one station at one captured snapshot timestamp.

### Candidate Attributes / Measures

- Station identifier
- Snapshot timestamp
- Available bikes/vehicles
- Available docks
- Station status
- Other availability metrics actually supplied by GBFS

## 7. FACT_VEHICLE_STATUS

### Grain

One row represents one vehicle-status observation for one vehicle at one captured snapshot timestamp.

### Candidate Attributes

- Vehicle identifier
- Vehicle type
- Station/location information
- Latitude/longitude where available
- Status flags
- Snapshot timestamp

Only source-supported fields will be implemented.

## 8. Dimension Design

### DIM_DATE

Candidate attributes include date, day, week, month, quarter, year, weekday, and weekend indicator.

### DIM_TIME

Candidate attributes include hour, minute, and business/peak-period classifications where useful.

### DIM_STATION

Stable station attributes may include station business identifier, station name, location, latitude, and longitude. Snapshot measures belong in `FACT_STATION_STATUS`.

### DIM_RIDER

Represents rider categories available in the verified historical source. Categories must not be invented.

### DIM_VEHICLE

Represents vehicle identity and stable descriptive attributes only where GBFS provides sufficient information. Changing status belongs in `FACT_VEHICLE_STATUS`.

### DIM_VEHICLE_TYPE

Represents stable vehicle-type classifications where the source supports them.

## 9. Conceptual Star Schema

```text
                    DIM_DATE
                       |
                    DIM_TIME
                       |
DIM_STATION ---- FACT_TRIP ---- DIM_RIDER
                       |
                origin / destination

DIM_DATE ---- FACT_STATION_STATUS ---- DIM_STATION
   |
DIM_TIME

DIM_DATE ---- FACT_VEHICLE_STATUS ---- DIM_VEHICLE ---- DIM_VEHICLE_TYPE
                         |
                    DIM_STATION
                    DIM_TIME
```

## 10. Fact vs Dimension Rules

Facts contain measurable events or periodic snapshots. Dimensions contain descriptive context. Frequently changing operational values should not be stored as static dimension attributes when a time-stamped fact is more appropriate.

## 11. Keys

Source/business identifiers are retained for traceability. Surrogate keys may be used for dimensions where appropriate. Facts reference dimension keys only where the relationship is established and supported by source data.

## 12. Slowly Changing Dimensions

SCD Type 2 may be considered when a dimension genuinely changes over time and historical state must be preserved. It will only be implemented when source and business requirements justify it.

## 13. Historical vs Snapshot Data

Historical trips are event data. GBFS station and vehicle status are snapshot data. They are modeled separately because their grains and analytical semantics differ.

## 14. Data Mart Relationship

CORE facts and dimensions feed business-specific marts such as fleet, station, rider, and operations analytics. Marts may aggregate, filter, or reshape trusted CORE data.

## 15. Power BI Consumption

Power BI should consume curated data marts or governed analytical views, not raw source tables. Measures must have consistent business definitions across dashboards.

## 16. Physical Organization

Candidate organization:

```text
DIVVY_DB.CORE.DIM_DATE
DIVVY_DB.CORE.DIM_TIME
DIVVY_DB.CORE.DIM_STATION
DIVVY_DB.CORE.DIM_RIDER
DIVVY_DB.CORE.DIM_VEHICLE
DIVVY_DB.CORE.DIM_VEHICLE_TYPE
DIVVY_DB.CORE.FACT_TRIP
DIVVY_DB.CORE.FACT_STATION_STATUS
DIVVY_DB.CORE.FACT_VEHICLE_STATUS
```

Actual physical DDL, data types, keys, and relationships are finalized after source profiling.

## 17. Model Quality Requirements

The model should have explicit grain, consistent keys, documented relationships, reusable dimensions, clear business definitions, and no unnecessary duplication. Facts should support incremental loading where applicable.

## 18. Status

**Version 1.0 — Logical baseline.** Physical columns and relationships remain dependent on verified source data and implementation.
