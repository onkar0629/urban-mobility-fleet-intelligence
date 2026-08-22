// Paste into Power Query Advanced Editor once for each view.
// Replace <snowflake-server> and <warehouse> with your Snowflake values.
let
    Source = Snowflake.Databases("<snowflake-server>", "<warehouse>"),
    DIVVY_DB = Source{[Name = "DIVVY_DB", Kind = "Database"]}[Data],
    MART = DIVVY_DB{[Name = "MART", Kind = "Schema"]}[Data],
    Operations = MART{[Name = "VW_POWERBI_OPERATIONS", Kind = "View"]}[Data]
in
    Operations
