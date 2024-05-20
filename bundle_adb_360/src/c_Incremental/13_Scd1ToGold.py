# Databricks notebook source
# MAGIC %md
# MAGIC ## Incremental Load of SCD Type 1 to Gold
# MAGIC ---
# MAGIC This notebooks applies the scd type 1 load for the restaurants table and the scd type 2 load for the customers table to gold
# MAGIC using the tablechanges from the change data feed and the watermark table
# MAGIC
# MAGIC Parameters:
# MAGIC * catalog (default catadb360dev)
# MAGIC * schema (default schemadb360dev)
# MAGIC * sourcedb(default silverdb)
# MAGIC * destdb(default golddb)
# MAGIC * tablename (default restaurants)

# COMMAND ----------

dbutils.widgets.text('catalog', 'catadb360dev')
dbutils.widgets.text('schema', 'schemaadb360dev')
dbutils.widgets.text('volume', 'bronze')
dbutils.widgets.text('destdb', 'silverdb')
dbutils.widgets.text('tablename', 'restaurants')

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

# create the update/insert set
# first the updates with the postimage and the surrogatekey being null
updatesdf = tcdf.selectExpr(
        'cast(null as bigint) as restaurantkey',
        'restaurantId', 
        'restaurantName', 
        'noOfTables', 
        'staffCount', 
        'phone', 
        'email',
        'fkaddress').where("_change_type in ('update_postimage')")

# COMMAND ----------

# get the max surrogate key from dimrestaurants
maxkey = spark.sql(f"select max(restaurantkey) as restaurantkey from golddb.dimrestaurant").collect()[0][0]

# COMMAND ----------

# first we get the new columns and calculate first the identity column and then adding the max existing
# surrogate key
insertsdf = tcdf.where("_change_type in ('insert')").selectExpr(
        'restaurantId', 
        'monotonically_increasing_id() as prekey',
        'restaurantName', 
        'noOfTables', 
        'staffCount', 
        'phone', 
        'email',
        'fkaddress') \
        .withColumn('restaurantkey', (row_number().over(Window.orderBy('prekey')).cast('bigint') + maxkey)) \
        .drop('prekey') \
        .selectExpr(
            'restaurantkey',
            'restaurantId', 
            'restaurantName', 
            'noOfTables', 
            'staffCount', 
            'phone', 
            'email',
            'fkaddress'
        )

# COMMAND ----------

# now unionize with updates
upsertsdf = updatesdf.union(insertsdf)

# COMMAND ----------

display(upsertsdf)

# COMMAND ----------

# prepare the merge by loading target table as a deltatable
deltaF = DeltaTable.forName(spark, 'golddb.dimrestaurant')


# COMMAND ----------

# upsert
deltaF.alias('t') \
    .merge(
        upsertsdf.alias('u'),
        't.restaurantid = u.restaurantId'
    ) \
    .whenMatchedUpdate(set = {
        'email' : 'u.email'
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
