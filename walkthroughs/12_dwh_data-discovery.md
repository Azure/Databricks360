This exercise uses an Azure Open Dataset 

https://learn.microsoft.com/en-us/azure/open-datasets/dataset-taxi-yellow?tabs=azureml-opendatasets

Files are downloaded from https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page for 2023 month Jan to April.

CREATE TABLE default.nyc_yellow_taxi1 (
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

CREATE TABLE default.nyc_yellow_taxi2 (
VendorID BIGINT, 
tpep_pickup_datetime TIMESTAMP, 
tpep_dropoff_datetime TIMESTAMP,
passenger_count DOUBLE, 
trip_distance DOUBLE, 
RatecodeID DOUBLE, 
store_and_fwd_flag STRING, 
PULocationID BIGINT, 
DOLocationID BIGINT, 
payment_type BIGINT, 
fare_amount DOUBLE, 
extra DOUBLE, 
mta_tax DOUBLE,
tip_amount DOUBLE, 
tolls_amount DOUBLE, 
improvement_surcharge DOUBLE, 
total_amount DOUBLE, 
congestion_surcharge DOUBLE, 
airport_fee DOUBLE
);


COPY INTO  default.nyc_yellow_taxi2
FROM 'dbfs:/Workspace/Users/admin@mngenvmcap230221.onmicrosoft.com/data/yellow_tripdata_2023-01.parquet'
FILEFORMAT = PARQUET
FORMAT_OPTIONS ('mergeSchema' = 'true')
COPY_OPTIONS ('mergeSchema' = 'true');
