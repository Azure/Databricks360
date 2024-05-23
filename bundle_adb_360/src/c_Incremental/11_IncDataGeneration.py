# Databricks notebook source
# MAGIC %md
# MAGIC ## Incremental Data Generator
# MAGIC ---
# MAGIC
# MAGIC This notebook generates the incremental data. It creates insert and update sets for customers and restaurants to be
# MAGIC able to show later the differences in scd type 1 and 2 loads
# MAGIC It creates a quarter of the rows in customer or restaurants for the upsert sets
# MAGIC
# MAGIC Parameters:
# MAGIC * catalog (default catadb360dev)
# MAGIC * schema (default schemaadb360dev)
# MAGIC * volume (default bronze)

# COMMAND ----------

dbutils.widgets.text('catalog', 'catadb360dev')
dbutils.widgets.text('schema', 'schemaadb360dev')
dbutils.widgets.text('volume', 'bronze')

# COMMAND ----------

# Install mimesis library
!pip install mimesis

# COMMAND ----------

# imports
import pandas as pd
from mimesis.schema import Fieldset, Generic
from mimesis.locales import Locale
from pyspark.sql import DataFrame
from pyspark.sql.functions import col,lit
import datetime

# COMMAND ----------

catalog = dbutils.widgets.get('catalog')
schema = dbutils.widgets.get('schema')
volume = dbutils.widgets.get('volume')

# COMMAND ----------

#variable
bronzePath = f'/Volumes/{catalog}/{schema}/{volume}/'
customerNoOfRows = 0
addressesNoOfRows = 0
dateString = ''


# COMMAND ----------

def createCustomerTable(noofrows=2, minaddress=1, maxaddress=addressesNoOfRows) -> DataFrame:
    fs = Fieldset(locale=Locale.EN, i=noofrows)

    df = pd.DataFrame.from_dict({
        "customerId": fs("increment"),
        "firstName": fs("person.first_name"),
        "lastName" : fs("person.last_name"),
        "customerType" : fs("choice", items=['customer', 'server', 'onlineagent']),
        "birthDate" : fs("person.birthdate", min_year=1960, max_year=2020),
        "ssn" : fs("code.issn", mask="###-##-####"),
        "email": fs("email"),
        "phone": fs("telephone", mask="+1 (###) #5#-7#9#"),
        "fkaddress" : fs("numeric.integer_number", start=minaddress, end=maxaddress)
    })

    return spark.createDataFrame(df)

# COMMAND ----------

def createRestaurants(noofrows=2, minaddress=1, maxaddress=addressesNoOfRows) -> DataFrame:
    fs = Fieldset(locale=Locale.EN, i=noofrows)

    df = pd.DataFrame.from_dict({
        "restaurantId": fs("increment"),
        "restaurantName" : fs("person.name"),
        "noOfTables" : fs("numeric.integer_number", start=5, end=50),
        "staffCount" : fs("numeric.integer_number", start=2, end=30),
        "phone": fs("telephone", mask="+1 (###) #5#-7#9#"),
        "email": fs("email"),
        "fkaddress" : fs("numeric.integer_number", start=minaddress, end=maxaddress)
    })

    return spark.createDataFrame(df)

# COMMAND ----------

def createUpsertTable(bpath, tablename) -> DataFrame:
    # get the number of historical customer rows
    df = spark.read.format('parquet').load(bpath + 'historical/'+ tablename +'.parquet/')
    NoOfRows = df.count()
    addressesNoOfRows = spark.read.format('parquet').load(bpath + 'historical/addresses.parquet').count()
    # now we create an insertset of a quarter for customers
    noofinsertRows = int(NoOfRows / 4)
    # create the new customers insert set with  a fourth of rows of the original created table
    # and change the customerid/restaurantId to be at the end of dataset concerning customerid, so that the records a really new/inserts
    if tablename == 'customers':
        insertDf = createCustomerTable(noofinsertRows, minaddress=1, maxaddress=addressesNoOfRows)
        newInsertCustomersDf = insertDf.withColumn('customerId', col('customerId') + NoOfRows)
    else: # it's restaurants
        insertDf = createRestaurants(noofinsertRows, minaddress=1, maxaddress=addressesNoOfRows)
        newInsertRestaurantsDf = insertDf.withColumn('restaurantId', col('restaurantId') + NoOfRows)

    # creating the updateset we get a random set of a quarter of the original ones
    generic = Generic(locale=Locale.EN)
    listIds = generic.numeric.integers(1, NoOfRows, noofinsertRows)
    # make list items unique
    listIds = list(set(listIds))
    # create where clause
    sListids = '(' + ','.join(str(x) for x in listIds) + ')'
    # mark the customer records, that are in the list of to be updated customerids as having an updated email address with a timestamp of this run
    dateString = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
    if tablename == 'customers':
        upsertDf = df.filter(f'customerid in {sListids}').withColumn('Email', lit(f'updated_{dateString}@update.com')).union(newInsertCustomersDf)
    else:
        upsertDf = df.filter(f'restaurantid in {sListids}').withColumn('Email', lit(f'updated_{dateString}@update.com')).union(newInsertRestaurantsDf)
    return upsertDf

# COMMAND ----------

# create the timestamp for this run
dateString = datetime.datetime.now().strftime('%Y%m%d%H%M%S')

# COMMAND ----------

# create table for customers
upcdf = createUpsertTable(bronzePath, 'customers')


# COMMAND ----------

display(upcdf)

# COMMAND ----------

# save it
upcdf.write.format('parquet').mode('overwrite').save(bronzePath + f'incremental/customers_yyyymmdd.parquet')

# COMMAND ----------

# create table for restaurants
upcdf = createUpsertTable(bronzePath, 'restaurants')


# COMMAND ----------

# save it too
upcdf.write.format('parquet').mode('overwrite').save(bronzePath + f'incremental/restaurants_yyyymmdd.parquet')

# COMMAND ----------

display(upcdf)

# COMMAND ----------

print ('finished')
