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

# load data for table customers
cdf = spark.read.format('delta').option('readChangeFeed', 'true').option('startingVersion', 0).table(f'silverdb.{tablename}')

# COMMAND ----------

# calculate watermark record
wmdf = cdf.selectExpr(
    'max(_commit_version) as lastCommitKey',
    'max(_commit_timestamp) as lastTimeStamp',
    ).withColumn('tablename', lit(tablename))


# COMMAND ----------

fdf.createOrReplaceTempView('mctable')

# COMMAND ----------

factselectstmt = '''
    select 
        year(dinnerdate) * 10000 + month(dinnerdate) * 100 + day(dinnerdate) as fkdate,
        dc.dimcustomerkey as fkcustomer,
        dw.dimcustomerkey as fkwaiter,
        restaurantkey as fkrestaurant,
        foodkey as fkfood,
        mc.tableid as tableid,
        cast(mc.cost as decimal) as dinnercost
    from
        mctable mc
    inner join
        golddb.dimcustomer dc on dc.customerId = mc.fkcustomer
    inner join
        golddb.dimcustomer dw on dw.customerid = mc.fkwaiter
    inner join
        golddb.dimrestaurant dr on dr.restaurantid = mc.fkrestaurant
    inner join
        golddb.dimfood df on df.foodname = mc.foodName and df.foodcategory = mc.foodCategory

'''

# COMMAND ----------

factsLoad = spark.sql(factselectstmt)
display(factsLoad.limit(3))
factsLoad.write.mode('append').format('delta').saveAsTable(f'golddb.{destTableName}')

# COMMAND ----------

#merge to watermark
tDelta = DeltaTable.forPath(spark, destdbname + '.' + watermarktable)
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

# COMMAND ----------

print('finished')
