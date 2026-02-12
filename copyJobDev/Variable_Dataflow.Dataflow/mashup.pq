[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "holidaydatacontainer_DataDestination", IsNewTarget = true], Settings = [Kind = "Manual", AllowCreation = true, ColumnSettings = [Mappings = {[SourceColumnName = "countryOrRegion", DestinationColumnName = "countryOrRegion"], [SourceColumnName = "holidayName", DestinationColumnName = "holidayName"], [SourceColumnName = "normalizeHolidayName", DestinationColumnName = "normalizeHolidayName"], [SourceColumnName = "isPaidTimeOff", DestinationColumnName = "isPaidTimeOff"], [SourceColumnName = "countryRegionCode", DestinationColumnName = "countryRegionCode"], [SourceColumnName = "date", DestinationColumnName = "date"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared holidaydatacontainer = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = WorkspaceId]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = LakehouseID]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "holidaydatacontainer", ItemKind = "Table"]}[Data],
  #"Filtered rows" = Table.SelectRows(#"Navigation 2", each [countryOrRegion] = Region)
in
  #"Filtered rows";
shared WorkspaceId = let
  Source = Variable.ValueOrDefault("$(/**/dataflow-Variables/WorkspaceId)", "9d01388e-acbc-4a4f-9e00-d9026abd421c")
  in
  Source;
shared LakehouseID = let
Source =
  Variable.ValueOrDefault("$(/\*\*/dataflow-Variables/LakehouseID)",
  "933cab43-3c43-47ad-af02-90223eca66d9")
  in
  Source;
shared Region = let
  Source = Variable.ValueOrDefault("$(/**/dataflow-Variables/Region)", "France ")
  in
  Source;
shared holidaydatacontainer_DataDestination = let
  Pattern = Fabric.Warehouse([HierarchicalNavigation = null, CreateNavigationProperties = false]),
  Navigation_1 = Pattern{[workspaceId = "9d01388e-acbc-4a4f-9e00-d9026abd421c"]}[Data],
  Navigation_2 = Navigation_1{[warehouseId = "8f21a78a-a3fb-4f72-a156-53bc13d12502"]}[Data],
  TableNavigation = Navigation_2{[Item = "holidaydatacontainer", Schema = "dbo"]}?[Data]?
in
  TableNavigation;
