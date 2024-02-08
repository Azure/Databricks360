# Databricks notebook source
dbutils.widgets.text('catalog', 'catadb360dev')
dbutils.widgets.text('sourcedbname', 'silverdb')
dbutils.widgets.text('destdbname', 'golddb')
dbutils.widgets.text('tablename', 'menuesconsumed')

# COMMAND ----------

catalog = dbutils.widgets.get('catalog')
sourcedbname = dbutils.widgets.text('sourcedbname')
destdbname = dbutils.widgets.get('destdbname')
tablename = dbutils.widgets.get('tablename')


# COMMAND ----------

from pyspark.sql.functions import lit, monotonically_increasing_id, row_number
from pyspark.sql.types import LongType
from pyspark.sql.window import Window
from delta.tables import DeltaTable

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
tDelta = DeltaTable.forPath(spark, destdbname + "." + watermarktable)
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
    except ConcurrentAppendException:
        bContinue = True
        print('caught ConcurrentAppendException!')

# COMMAND ----------

print ('finished !')
