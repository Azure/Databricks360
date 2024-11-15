This exercise uses the NYC Taxi Open Dataset that cound be found at [NYC Taxi and Limousine yellow dataset - Azure Open Datasets | Microsoft Learn](https://learn.microsoft.com/en-us/azure/open-datasets/dataset-taxi-yellow?tabs=azureml-opendatasets).

For this specific example we are using the Janaury-April 2023 Yellow Taxi Trip Records (Parquet) files that can be found at [TLC Trip Record Data - TLC] (https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page).

1) Our first step is to add the January - April 2023 Yellow Taxi Trip Records files to the Databricks File Store (DBFS).  To do so, go to Catalog and click + (Add Data) <BR>
![picture alt](/imagery/dwh_04_all_sql_warehouse.jpeg)


2) Now the Add Data screen will

```sql
CREATE TABLE default.nyc_yellow_taxi (
doLocationId string,
endLat double,
endLon double,
extra double,
fareAmount double,
improvementSurcharge string,
mtaTax double,
passengerCount int,
paymentType string,
puLocationId string,
puMonth int,
puYear int,
rateCodeId int,
startLat double,
startLon double,
storeAndFwdFlag string,
tipAmount double,
tollsAmount double,
totalAmount double,
tpepDropoffDateTime timestamp,
tpepPickupDateTime timestamp,
tripDistance double,
vendorID int
);
```

```sql

COPY INTO  default.nyc_yellow_taxi2
FROM 'dbfs:/Workspace/Users/admin@mngenvmcap230221.onmicrosoft.com/data/yellow_tripdata_2023-01.parquet'
FILEFORMAT = PARQUET
FORMAT_OPTIONS ('mergeSchema' = 'true')
COPY_OPTIONS ('mergeSchema' = 'true');
```