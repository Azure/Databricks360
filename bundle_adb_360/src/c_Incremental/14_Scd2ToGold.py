# Databricks notebook source
# MAGIC %md
# MAGIC ## Incremental Load of SCD Type 2 to Gold
# MAGIC ---
# MAGIC This notebooks applies the scd type 2 load for the customers table to gold
# MAGIC using the tablechanges from the change data feed and the watermark table
# MAGIC
# MAGIC Parameters:
# MAGIC * catalog (default catadb360dev)
# MAGIC * schema (default schemadb360dev)
# MAGIC * sourcedb(default silverdb)
# MAGIC * destdb(default golddb)
# MAGIC * tablename (default customers)

# COMMAND ----------

dbutils.widgets.text('catalog', 'catadb360dev')
dbutils.widgets.text('schema', 'schemaadb360dev')
dbutils.widgets.text('volume', 'bronze')
dbutils.widgets.text('destdb', 'golddb')
dbutils.widgets.text('tablename', 'customers')

# COMMAND ----------

catalog = dbutils.widgets.get('catalog')
schema = dbutils.widgets.get('schema')
volume = dbutils.widgets.get('volume')
destdb = dbutils.widgets.get('destdb')
tablename = dbutils.widgets.get('tablename')

# COMMAND ----------

# imports
from delta.tables import DeltaTable
from pyspark.sql.functions import lit, monotonically_increasing_id, row_number, col
from pyspark.sql.types import LongType
from pyspark.sql.window import Window

# COMMAND ----------

spark.sql(f"use catalog {catalog}")

# COMMAND ----------

# variables
maxVersion = 0

# COMMAND ----------

# load maxversion from watermarktable
maxVersion = spark.sql(f"select lastCommitKey from golddb.watermarktable where tablename = '{tablename}'" ).collect()[0][0]

# COMMAND ----------

# load the last version from table
tcdf = spark.read.format('delta').option('readChangeFeed', 'true').option('startingVersion', maxVersion + 1).table(f'silverdb.{tablename}')

# COMMAND ----------

# calculate max customerkey
maxDimCustomerKey = spark.sql(f"select max(dimcustomerkey) from golddb.dimcustomer").collect()[0][0]
maxDimCustomerKey += 1

# COMMAND ----------

# create the updates and the insert set
# first the insert set with the new records
insertdf = tcdf.where("_change_type in ('insert')").selectExpr(
        'customerId',
        'firstName', 
        'lastName', 
        'customerType', 
        'birthDate',
        'ssn',
        'email', 
        'phone', 
        'cast(1 as boolean) as current',
        "cast('1900-01-01' as timestamp) as validfrom",
        "cast('9999-12-31' as timestamp) as validto",     
        'fkaddress')

# COMMAND ----------

# calculate update sets 
# this first one is going to update the existing customers by updating the current flag to 0 and the validto to the current date
updatespredf = tcdf.selectExpr(
    'cast (null as bigint) as dimcustomerkey',
    'customerId',
    'firstName', 
    'lastName', 
    'customerType', 
    'birthDate',
    'ssn',
    'email', 
    'phone', 
    'cast(0 as boolean) as current',
    'cast(null as date) as validfrom',
    "current_date() as validto",
    'fkaddress').where("_change_type in ('update_preimage')")

# COMMAND ----------

display(updatespredf)

# COMMAND ----------

# this one is going to insert the newly updated customers
updatespostdf = tcdf.selectExpr(
    'customerId',
    'firstName', 
    'lastName', 
    'customerType', 
    'birthDate',
    'ssn',
    'email', 
    'phone', 
    'cast(1 as boolean) as current',
    "current_date() as validfrom",     
    "cast('9999-12-31' as date) as validto",
    'fkaddress').where("_change_type in ('update_postimage')")

# COMMAND ----------

display(updatespostdf)

# COMMAND ----------

# unionize  post updates and inserts (all which need a new surrogate key)
allinserts = updatespostdf.union(insertdf)

# COMMAND ----------

display(allinserts)

# COMMAND ----------

#calculate dimcustomerkey over these data
finalallinserts = allinserts.selectExpr(
    'monotonically_increasing_id() as prekey',
    'customerId',
    'firstName', 
    'lastName', 
    'customerType', 
    'birthDate',
    'ssn',
    'email', 
    'phone', 
    'current',
    "validfrom",     
    "validto",
    'fkaddress'   
) \
.withColumn('dimcustomerkey', (row_number().over(Window.orderBy('prekey')).cast('bigint') + maxDimCustomerKey)) \
.drop('prekey')

# COMMAND ----------

# reorder columns before merge
orderedfinalinserts = finalallinserts.select(
    'dimcustomerkey',
    'customerId',
    'firstName',
    'lastName',
    'customerType',
    'birthDate',
    'ssn',
    'email',
    'phone',
    'current',
    'validfrom',
    'validto',
    'fkaddress'
)

# COMMAND ----------

display(orderedfinalinserts)

# COMMAND ----------

# prepare the merge
deltaF = DeltaTable.forName(spark, 'golddb.dimcustomer')

# COMMAND ----------

# unionize finalallinserts and updatespredf
mergeupserts = orderedfinalinserts.union(updatespredf)

# COMMAND ----------

display(mergeupserts)

# COMMAND ----------

# do the merge
deltaF.alias('t') \
    .merge(
        mergeupserts.alias('u'),
        't.customerid = u.customerid and u.dimcustomerkey is null'
    ) \
    .whenMatchedUpdate(set={
        'validto' : 'u.validto',
        'current' : 'u.current'
    }) \
    .whenNotMatchedInsertAll() \
    .execute()

# COMMAND ----------


# calculate watermark record
wmdf = tcdf.selectExpr(
    'max(_commit_version) as lastCommitKey',
    'max(_commit_timestamp) as lastTimeStamp',
    ).withColumn('tablename', lit(tablename))


# COMMAND ----------

# udpate watermark table 
deltaWm = DeltaTable.forName(spark, 'golddb.watermarktable')
deltaWm.alias('t') \
.merge(
    wmdf.alias('u'),
    't.tablename = u.tablename'
) \
.whenMatchedUpdate(set=
{
    'lastCommitKey' : 'u.lastCommitKey'
}
) \
.execute()


# COMMAND ----------

print ("finished")

# COMMAND ----------


