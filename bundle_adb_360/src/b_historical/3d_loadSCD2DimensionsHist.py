# Databricks notebook source
# MAGIC %md
# MAGIC ## Load SCD Type 2
# MAGIC ---
# MAGIC This notebook loads the customers table to DimCustomers with come reformatting, since
# MAGIC it's going to be an scd type 2 dimension
# MAGIC
# MAGIC Parameters:
# MAGIC * catalog (default catadb360dev)
# MAGIC * sourcedbname (default silverdb)
# MAGIC * destdbname (default golddb)
# MAGIC * tablename (default customers)

# COMMAND ----------

dbutils.widgets.text('catalog', 'catadb360dev')
dbutils.widgets.text('sourcedbname', 'silverdb')
dbutils.widgets.text('destdbname', 'golddb')
dbutils.widgets.text('tablename', 'customers')

# COMMAND ----------

# variables
catalog = dbutils.widgets.get('catalog')
sourcedbname = dbutils.widgets.get('sourcedbname')
destdbname = dbutils.widgets.get('destdbname')
tablename = dbutils.widgets.get('tablename')
destTableName = 'dimcustomer'
watermarktable = 'watermarktable'

# COMMAND ----------

from pyspark.sql.functions import lit, monotonically_increasing_id, row_number
from pyspark.sql.types import LongType
from pyspark.sql.window import Window
from delta.tables import DeltaTable
from time import sleep

# COMMAND ----------

spark.sql(f"use catalog {catalog}")

# COMMAND ----------

# load data for table customers
cdf = spark.read.format('delta').option('readChangeFeed', 'true').option('startingVersion', 0).table(f'silverdb.{tablename}')

# COMMAND ----------

# calculate watermark record
wmdf = cdf.selectExpr(
    'max(_commit_version) as lastCommitKey',
    'max(_commit_timestamp) as lastTimeStamp',
    ).withColumn('tablename', lit(tablename))


# COMMAND ----------

# create target data frame
customerupserts = cdf.selectExpr(
    'customerId',
    'monotonically_increasing_id() as prekey',
    'firstName',
    'lastName',
    'customerType',
    'birthDate',
    'ssn',
    'email',
    'phone',
    'fkaddress',
    'cast(1 as boolean) as current',
    "cast('1900-01-01' as timestamp) as validfrom",
    "cast('9999-12-31' as timestamp) as validto"
).withColumn('dimcustomerkey', (row_number().over(Window.orderBy('prekey')).cast('bigint'))).drop('prekey')
customerupserts.write.mode('overwrite').format('delta').saveAsTable(f'golddb.{destTableName}')

# COMMAND ----------

#merge to watermark
tDelta = DeltaTable.forName(spark, destdbname + '.' + watermarktable)
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

print('finished')

# COMMAND ----------


