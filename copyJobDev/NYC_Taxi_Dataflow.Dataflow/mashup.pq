[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared green_tripdata_2022 = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "9d01388e-acbc-4a4f-9e00-d9026abd421c"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "933cab43-3c43-47ad-af02-90223eca66d9"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "green_tripdata_2022", ItemKind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 2", {{"lpep_pickup_datetime", type date}}),
  #"Filtered rows" = Table.SelectRows(#"Changed column type", each ([store_and_fwd_flag] = "Y")),
  #"Filtered rows 1" = Table.SelectRows(#"Filtered rows", each [lpep_pickup_datetime] >= #date(2022, 1, 1) and [lpep_pickup_datetime] <= #date(2022, 1, 31)),
  #"Filtered rows 2" = Table.SelectRows(#"Filtered rows 1", each [PULocationID] > PUlocationID)
in
  #"Filtered rows 2";
shared nyc_taxi_green_discounts = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "9d01388e-acbc-4a4f-9e00-d9026abd421c"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "933cab43-3c43-47ad-af02-90223eca66d9"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "nyc_taxi_green_discounts", ItemKind = "Table"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(#"Navigation 2", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"VendorID", Int64.Type}, {"2015-01-01", Int64.Type}, {"2015-01-02", Int64.Type}, {"2015-01-03", Int64.Type}, {"2015-01-04", Int64.Type}, {"2015-01-05", Int64.Type}, {"2015-01-06", Int64.Type}, {"2015-01-07", Int64.Type}, {"2015-01-08", Int64.Type}, {"2015-01-09", Int64.Type}, {"2015-01-10", Int64.Type}, {"2015-01-11", Int64.Type}, {"2015-01-12", Int64.Type}, {"2015-01-13", Int64.Type}, {"2015-01-14", Int64.Type}, {"2015-01-15", Int64.Type}, {"2015-01-16", Int64.Type}, {"2015-01-17", Int64.Type}, {"2015-01-18", Int64.Type}, {"2015-01-19", Int64.Type}, {"2015-01-20", Int64.Type}, {"2015-01-21", Int64.Type}, {"2015-01-22", Int64.Type}, {"2015-01-23", Int64.Type}, {"2015-01-24", Int64.Type}, {"2015-01-25", Int64.Type}, {"2015-01-26", Int64.Type}, {"2015-01-27", Int64.Type}, {"2015-01-28", Int64.Type}, {"2015-01-29", Int64.Type}, {"2015-01-30", Int64.Type}, {"2015-01-31", Int64.Type}}),
  #"Unpivoted other columns" = Table.UnpivotOtherColumns(#"Changed column type", {"VendorID"}, "Date", "Discount"),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Unpivoted other columns", {{"Date", type date}}),
  #"Inserted division" = Table.AddColumn(#"Changed column type 1", "Division", each [Discount] / 100, type number)

in
  #"Inserted division";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "output_DataDestination", IsNewTarget = true], Settings = [Kind = "Manual", AllowCreation = true, ColumnSettings = [Mappings = {[SourceColumnName = "VendorID", DestinationColumnName = "VendorID"], [SourceColumnName = "lpep_pickup_datetime", DestinationColumnName = "lpep_pickup_datetime"], [SourceColumnName = "fare_amount", DestinationColumnName = "fare_amount"], [SourceColumnName = "Count", DestinationColumnName = "Count"], [SourceColumnName = "File", DestinationColumnName = "File"]}], DynamicSchema = true, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared output = let
  Source = Table.NestedJoin(green_tripdata_2022, {"VendorID"}, nyc_taxi_green_discounts, {"VendorID"}, "nyc_taxi_green_discounts", JoinKind.LeftOuter),
  #"Expanded nyc_taxi_green_discounts" = Table.ExpandTableColumn(Source, "nyc_taxi_green_discounts", {"Date", "Discount", "Division"}, {"Date", "Discount", "Division"}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Expanded nyc_taxi_green_discounts", {{"lpep_dropoff_datetime", type date}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Changed column type 1", "TotalAfterDiscount", each if [tolls_amount] >  0 then [tolls_amount] * ( 1 - [Discount] ) else [tolls_amount]), {{"TotalAfterDiscount", Currency.Type}}),
  #"Inserted rounding" = Table.AddColumn(#"Added custom", "Inserted rounding", each Number.Round([TotalAfterDiscount], 2), type number),
  #"Changed column type" = Table.TransformColumnTypes(#"Inserted rounding", {{"lpep_pickup_datetime", type datetime}}),
  #"Choose columns" = Table.SelectColumns(#"Changed column type", {"VendorID", "lpep_pickup_datetime", "lpep_dropoff_datetime", "store_and_fwd_flag", "PULocationID", "DOLocationID", "passenger_count", "fare_amount", "extra", "mta_tax", "tip_amount", "tolls_amount", "ehail_fee", "improvement_surcharge", "total_amount", "payment_type", "trip_type", "congestion_surcharge", "source_file", "Date", "Discount", "Division", "TotalAfterDiscount", "Inserted rounding"}),
  #"Removed columns" = Table.RemoveColumns(#"Choose columns", {"passenger_count"}),
  #"Grouped rows" = Table.Group(#"Removed columns", {"VendorID", "lpep_pickup_datetime", "fare_amount"}, {{"Count", each List.Sum([tip_amount]), type nullable number}, {"File", each List.Count(List.Distinct([source_file])), Int64.Type}})
in
  #"Grouped rows";
shared PUlocationID = 200 meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type number];
shared output_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "9d01388e-acbc-4a4f-9e00-d9026abd421c"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "933cab43-3c43-47ad-af02-90223eca66d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "output", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
