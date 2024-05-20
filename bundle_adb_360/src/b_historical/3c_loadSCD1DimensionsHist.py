# Databricks notebook source
# MAGIC %md
# MAGIC ## Load SCD Type 1 Tables
# MAGIC ---
# MAGIC This notebook loads the scd type 1 dimensions like
# MAGIC - dimrestaurant
# MAGIC - dimaddress
# MAGIC - dimfood (the data for this dimension is extracted from menuesconsumed)
# MAGIC
# MAGIC it does this, by tapping into the change data feed of the silvertables and managing a watermarktable
# MAGIC for the last successfully ingested commits. Also it's calculating a surrogate key
# MAGIC
# MAGIC Parameters:
# MAGIC * catalog (default catadb360dev)
# MAGIC * sourcedbname (default silverdb)
# MAGIC * destdbname(default golddb)
# MAGIC * tablename (default menuesconsumed)
# MAGIC
# MAGIC > this notebook has to be run 3 times: for addresses, restaurants and menuesconsumed (dimfood)

# COMMAND ----------

dbutils.widgets.text('catalog', 'catadb360dev')
dbutils.widgets.text('sourcedbname', 'silverdb')
dbutils.widgets.text('destdbname', 'golddb')
dbutils.widgets.text('tablename', 'addresses')

# COMMAND ----------

catalog = dbutils.widgets.get('catalog')
sourcedbname = dbutils.widgets.get('sourcedbname')
destdbname = dbutils.widgets.get('destdbname')
tablename = dbutils.widgets.get('tablename')


# COMMAND ----------

from pyspark.sql.functions import lit, monotonically_increasing_id, row_number
from pyspark.sql.types import LongType
from pyspark.sql.window import Window
from delta.tables import DeltaTable
from time import sleep


# COMMAND ----------

#variables
if tablename == 'addresses':
    destTableName = 'dimaddress'
elif tablename == 'customers':
    destTableName = 'dimcustomer'
elif tablename == 'restaurants':
    destTableName = 'dimrestaurant'
elif tablename == 'menuesconsumed':
    destTableName = 'dimfood'
else:
    pass
watermarktable = 'watermarktable'

# COMMAND ----------

spark.sql(f"use catalog {catalog}")

# COMMAND ----------

# for tables addresses, restaurants the handling is the same
if tablename == 'addresses' or tablename == 'restaurants' or tablename == 'menuesconsumed':
    tcdf = spark.read.format('delta').option('readChangeFeed', 'true').option('startingVersion', 1).table(f'silverdb.{tablename}')

# COMMAND ----------

# calculate watermark record
wmdf = tcdf.selectExpr(
    'max(_commit_version) as lastCommitKey',
    'max(_commit_timestamp) as lastTimeStamp',
    ).withColumn('tablename', lit(tablename))


# COMMAND ----------

# create target data frame
if tablename == 'addresses':
    addressUpSerts = tcdf.selectExpr(
        'addressid',
        'monotonically_increasing_id() as prekey',
        'State',
        'StreetNo',
        'Street',
        'City',
        'Zip'
    ).withColumn('addresskey', (row_number().over(Window.orderBy('prekey')).cast('bigint'))).drop('prekey')
    display(addressUpSerts.limit(3))
    addressUpSerts.write.mode('append').format('delta').saveAsTable(f'golddb.{destTableName}')

# COMMAND ----------

if tablename == 'restaurants':
    restaurantsupserts = tcdf.selectExpr(
        'restaurantid',
        'monotonically_increasing_id() as prekey',
        'restaurantname',
        'staffCount',
        'noOfTables',
        'phone',
        'email',
        'fkaddress'
    ).withColumn('restaurantkey', (row_number().over(Window.orderBy('prekey')).cast('bigint'))).drop('prekey')
    restaurantsupserts.write.mode('append').format('delta').saveAsTable(f'golddb.{destTableName}')

# COMMAND ----------

# this is going to create the dimfood dimension
if tablename == 'menuesconsumed':
    foodupserts = tcdf.groupBy(['foodName', 'foodCategory']).count().sort("foodName").selectExpr(
        'foodName',
        'foodCategory',
        'cast(0.0 as decimal) as cost',
        'monotonically_increasing_id() as prekey'
    ).withColumn('foodKey', (row_number().over(Window.orderBy('prekey')).cast('bigint'))).drop('prekey')
    foodupserts.write.mode('append').format('delta').saveAsTable(f'golddb.{destTableName}')

# COMMAND ----------

#merge to watermark ConcurrentAppendException
tDelta = DeltaTable.forName(spark, destdbname + "." + watermarktable)
bContinue = True
while bContinue:
    try:
        tDelta.alias('t') \
            .merge(
                wmdf.alias('u'),
                't.tablename = u.tablename'
            ) \
            .whenMatchedUpdate(set=
            {
                'tablename' : 'u.tablename',
                'lastCommitKey' : 'u.lastCommitKey',
                'lastTimeStamp' : 'u.lastTimeStamp'
            }
            ) \
            .whenNotMatchedInsert(values=
            {
                'tablename' : 'u.tablename',
                'lastCommitKey' : 'u.lastCommitKey',
                'lastTimeStamp' : 'u.lastTimeStamp'
            }
            ) \
            .execute()
        bContinue = False
    except Exception as e:
        if "ConcurrentAppendException" in str(e):
            bContinue = True
            print('caught ConcurrentAppendException!')
            sleep(20)

# COMMAND ----------

print ('finished !')
