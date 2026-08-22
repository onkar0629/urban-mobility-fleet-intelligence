# Dashboard Build Specification

This is the final report design for `Urban_Mobility_Fleet_Intelligence.pbix`. It uses only `DIVVY_DB.MART` reporting views. Do not create relationships between the four imported tables: every visual stays within its source view, preventing unrelated aggregate tables from filtering each other incorrectly.

## One-time setup

1. Run [`../sql/14_powerbi_views.sql`](../sql/14_powerbi_views.sql) in Snowflake.
2. In Power BI Desktop, use **Get data > Snowflake** and import the four views below. Set `REPORT_DATE` to **Date**.
3. Apply [`theme.json`](theme.json) through **View > Themes > Browse for themes**.
4. Create a blank table named `_Measures` and add definitions from [`measures.dax`](measures.dax). Format share measures as percentages (one decimal), duration measures as decimals (one decimal), and `Latest Fleet Snapshot` as `dd mmm yyyy, hh:mm`.
5. Turn off automatic date/time in **File > Options > Data Load**. Do not create relationships among views.

| Power BI table | Snowflake object |
|---|---|
| `VW_POWERBI_OPERATIONS` | `DIVVY_DB.MART.VW_POWERBI_OPERATIONS` |
| `VW_POWERBI_STATION` | `DIVVY_DB.MART.VW_POWERBI_STATION` |
| `VW_POWERBI_RIDER` | `DIVVY_DB.MART.VW_POWERBI_RIDER` |
| `VW_POWERBI_FLEET` | `DIVVY_DB.MART.VW_POWERBI_FLEET` |

Use [`Snowflake_Connection.m`](Snowflake_Connection.m) as the Power Query starter. Change only the server, warehouse, and final view name for each query.

## Page 1 — Mobility Overview

Add a page title: **Mobility Overview**. Add a between-date slicer for `VW_POWERBI_OPERATIONS[REPORT_DATE]`.

| Visual | Fields / configuration |
|---|---|
| Cards | `[Total Trips]`, `[Member Trips]`, `[Casual Trips]`, `[Average Trip Duration (Minutes)]`, `[Active Stations]`, `[Available Vehicles]` |
| Line chart — Daily trip demand | X-axis: `REPORT_DATE` (continuous); Y-axis: `[Total Trips]` |
| Stacked column — Rider mix over time | X-axis: `REPORT_DATE`; Y-axis: `[Member Trips]`, `[Casual Trips]` |
| Line chart — Average duration | X-axis: `REPORT_DATE`; Y-axis: `[Average Trip Duration (Minutes)]` |

## Page 2 — Station Intelligence

Add a page title: **Station Intelligence**. Add dropdown slicers for `VW_POWERBI_STATION[REPORT_DATE]` and `STATION_NAME`, with search enabled.

| Visual | Fields / configuration |
|---|---|
| Cards | `[Station Trips]`, `[Origin Trips]`, `[Destination Trips]`, `[Average Station Trip Duration (Minutes)]`, `[Average Vehicles Available]`, `[Average Docks Available]` |
| Clustered bar — Top 10 stations | Y-axis: `STATION_NAME`; X-axis: `[Station Trips]`; visual-level Top N = 10 by `[Station Trips]`; descending sort |
| Clustered bar — Origin vs destination | Y-axis: `STATION_NAME`; X-axis: `[Origin Trips]`, `[Destination Trips]`; visual-level Top N = 10 by `[Station Trips]` |
| Table — Station operations | `STATION_ID`, `STATION_NAME`, `[Station Trips]`, `[Origin Trips]`, `[Destination Trips]`, `[Average Vehicles Available]`, `[Average Docks Available]` |

Apply red-to-green conditional formatting to availability columns: red at 0, amber at midpoint, green at the maximum.

## Page 3 — Rider Analytics

Add a page title: **Rider Analytics**. Add a between-date slicer for `VW_POWERBI_RIDER[REPORT_DATE]` and a dropdown slicer for `RIDER_TYPE`.

| Visual | Fields / configuration |
|---|---|
| Cards | `[Rider Trips]`, `[Average Rider Trip Duration (Minutes)]`, `[Daily Unique Start Stations]`, `[Daily Unique End Stations]` |
| Donut — Rider trip mix | Legend: `RIDER_TYPE`; Values: `[Rider Trips]`; show percent of total |
| Line chart — Daily trips by rider type | X-axis: `REPORT_DATE`; Legend: `RIDER_TYPE`; Y-axis: `[Rider Trips]` |
| Clustered column — Duration by rider type | X-axis: `RIDER_TYPE`; Y-axis: `[Average Rider Trip Duration (Minutes)]` |

The two station measures are deliberately labelled **Daily Unique** because the mart contains daily distinct counts; summing them over a period is not a period-wide distinct count.

## Page 4 — Fleet Snapshot

Add a page title: **Fleet Snapshot**. Add dropdown slicers for `VW_POWERBI_FLEET[REPORT_DATE]`, `VEHICLE_TYPE_ID`, and `VEHICLE_STATUS`.

| Visual | Fields / configuration |
|---|---|
| Cards | `[Fleet Vehicle Count]`, `[Active Vehicle Count]`, `[Active Fleet Share]`, `[Latest Fleet Snapshot]` |
| Clustered column — Fleet by vehicle type | X-axis: `VEHICLE_TYPE_ID`; Y-axis: `[Fleet Vehicle Count]` |
| Donut — Fleet by status | Legend: `VEHICLE_STATUS`; Values: `[Fleet Vehicle Count]` |
| Line chart — Active fleet trend | X-axis: `REPORT_DATE`; Y-axis: `[Active Vehicle Count]` |

## Final checks and publishing

Before publishing, check that `[Total Trips]` with no filters matches the `MART_TOTAL_TRIPS` value returned by the reconciliation in [`../sql/13_validation_queries.sql`](../sql/13_validation_queries.sql). Name the report **Urban Mobility & Fleet Intelligence**, save it as `powerbi/Urban_Mobility_Fleet_Intelligence.pbix`, and configure a scheduled refresh only after the Snowflake MART refresh completes.
