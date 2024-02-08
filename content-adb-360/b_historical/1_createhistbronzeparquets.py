# Databricks notebook source
# MAGIC %md
# MAGIC # Create Historical Parquet Tables on Bronze
# MAGIC ---
# MAGIC dbldatagen from databricks
# MAGIC - video : https://www.youtube.com/watch?v=fUED0reD5B8
# MAGIC - databricks labs: https://databrickslabs.github.io/dbldatagen/public_docs/index.html
# MAGIC
# MAGIC Mimesis
# MAGIC - https://mimesis.name/en/master/
# MAGIC
# MAGIC This notebook is going to create the initial tables, such as Customers, Addresses, Restaurants and Menuesconsumed
# MAGIC
# MAGIC
# MAGIC three parameters are needed:
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

catalog = dbutils.widgets.get('catalog')
schema = dbutils.widgets.get('schema')
volume = dbutils.widgets.get('volume')

# COMMAND ----------

#%fs ls /Volumes/catadb360dev/adb360devdb/bronze/historical/


# COMMAND ----------

#variables
customerTableNoOfRows = 10
restaurantsTableNoOfRows = 5
createMenuesConsumedTableNoOfRows = 100
fkMaxAddressNumber = 20

destPath = f'/Volumes/{catalog}/{schema}/{volume}/historical/'

# COMMAND ----------

#imports
import pandas as pd
from mimesis.schema import Fieldset, Generic
from mimesis.locales import Locale
from pyspark.sql import DataFrame


# COMMAND ----------

def createCustomerTable(noofrows=2, minaddress=1, maxaddress=10) -> DataFrame:
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

def createAddressTable(noofrows=2) -> DataFrame:
    fs = Fieldset(locale=Locale.EN, i=noofrows)

    df = pd.DataFrame.from_dict({
        "addressid": fs("increment"),
        "state" : fs("address.state"),
        "streetNo" : fs("address.street_number"),
        "street" : fs("address.street_name"),
        "city"  : fs("address.city"),
        "zip" : fs("address.zip_code")
    })

    return spark.createDataFrame(df)

# COMMAND ----------

def createRestaurants(noofrows=2, minaddress=1, maxaddress=fkMaxAddressNumber) -> DataFrame:
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

def createMenuesConsumed(noofrows=2, mincustid = 1, maxcustid = 10, minrestid = 1, maxrestid = 10) -> DataFrame:
    fs = Fieldset(locale=Locale.EN, i=int(noofrows/2))

    df = pd.DataFrame.from_dict({
        "menueId": fs("increment"),
        "foodName": fs("food.dish"),
        "foodCategory" : 'food',
        "cost": fs("finance.price", minimum=4.99, maximum=222.40),
        "dinnerDate" : fs("datetime.date", start=2022, end=2023),
        "fkcustomer" : fs("numeric.integer_number", start=mincustid, end=maxcustid),
        "fkrestaurant" : fs("numeric.integer_number", start=minrestid, end=maxrestid),
        "fkwaiter" : fs("numeric.integer_number", start=mincustid, end=maxcustid),
        "tableId" : fs("numeric.integer_number", start=5, end=50 )
    })

    df1 = pd.DataFrame.from_dict({
        "menueId": fs("increment"),
        "foodName": fs("food.drink"),
        "foodCategory" : 'beverage',
        "cost": fs("finance.price", minimum=4.99, maximum=222.40),
        "dinnerDate" : fs("datetime.date", start=2022, end=2023),
        "fkcustomer" : fs("numeric.integer_number", start=mincustid, end=maxcustid),
        "fkrestaurant" : fs("numeric.integer_number", start=minrestid, end=maxrestid),
        "fkwaiter" : fs("numeric.integer_number", start=mincustid, end=maxcustid),
        "tableId" : fs("numeric.integer_number", start=5, end=50 )
    })

    sdf = spark.createDataFrame(df)
    sdf1 = spark.createDataFrame(df1)
    return sdf.union(sdf1)

# COMMAND ----------

# create the customer table
cdf = createCustomerTable(customerTableNoOfRows, 1, fkMaxAddressNumber)

# COMMAND ----------

# write the customer table
cdf.write.format('parquet').mode('overwrite').save(destPath + 'customers.parquet')

# COMMAND ----------

# create the addresstable and write it
adf = createAddressTable(fkMaxAddressNumber)
adf.write.format('parquet').mode('overwrite').save(destPath + 'addresses.parquet')

# COMMAND ----------

# create the restaurants 
rdf = createRestaurants(restaurantsTableNoOfRows, 1, fkMaxAddressNumber)
rdf.write.format('parquet').save(destPath + 'restaurants.parquet')

# COMMAND ----------

# create the mneuesconsumed 
mdf = createMenuesConsumed(
    createMenuesConsumedTableNoOfRows, 
    mincustid = 1, 
    maxcustid = customerTableNoOfRows, 
    minrestid = 1, 
    maxrestid = fkMaxAddressNumber )

mdf.write.format('parquet').mode('overwrite').save(destPath + 'menuesconsumed.parquet')

# COMMAND ----------

print('finished')

# COMMAND ----------

# MAGIC %fs ls /Volumes/catadb360dev/schemaadb360dev/bronze/historical
