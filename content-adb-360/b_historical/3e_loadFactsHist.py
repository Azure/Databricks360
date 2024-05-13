# Databricks notebook source
# MAGIC %md
# MAGIC ## Historical Load Fact Tables
# MAGIC ---
# MAGIC
# MAGIC This notebook loads the fact table, therefore, the loads of all the dimensions have to be completed.
# MAGIC
# MAGIC Parameters:
# MAGIC * catalog (default catadb360dev)
# MAGIC * sourcedbname (default silverdb)
# MAGIC * destdbname (default golddb)

# COMMAND ----------

dbutils.widgets.text('catalog', 'catadb360dev')
dbutils.widgets.text('sourcedbname', 'silverdb')
dbutils.widgets.text('destdbname', 'golddb')


# COMMAND ----------

catalog = dbutils.widgets.get('catalog')
sourcedbname = dbutils.widgets.get('sourcedbname')
destdbname = dbutils.widgets.get('destdbname')
desttablename = 'factmenues'

# COMMAND ----------

from pyspark.sql.functions import lit, monotonically_increasing_id, row_number
from pyspark.sql.types import LongType
from pyspark.sql.window import Window
from delta.tables import DeltaTable

# COMMAND ----------

spark.sql(f"use catalog {catalog}")

# COMMAND ----------

# load the menuesconsumed table
mctable = spark.sql(f"select * from {sourcedbname}.menuesconsumed")

# COMMAND ----------

mctable.createOrReplaceTempView('mctable')

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


# COMMAND ----------

factsLoad.write.mode('overwrite').format('delta').saveAsTable(f'golddb.{desttablename}')

# COMMAND ----------

print('finished')
