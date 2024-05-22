# Databricks notebook source
# MAGIC %md
# MAGIC ## Load Incremental to Silver
# MAGIC ---
# MAGIC This notebook loads the incremental data for customers and restaurants to silver
# MAGIC
# MAGIC Parameters:
# MAGIC * catalog (default catadb360dev)
# MAGIC * schema (default schemadb360dev)
# MAGIC * volume (default bronz)
# MAGIC * destdb (default silver)
# MAGIC * incfilename (default customers_yyyymmdd.parquet)

# COMMAND ----------

dbutils.widgets.text('catalog', 'catadb360dev')
dbutils.widgets.text('schema', 'schemaadb360dev')
dbutils.widgets.text('volume', 'bronze')
dbutils.widgets.text('destdb', 'silverdb')
dbutils.widgets.text('incfilename', 'restaurants_yyyymmdd.parquet')

# COMMAND ----------

catalog = dbutils.widgets.get('catalog')
schema = dbutils.widgets.get('schema')
volume = dbutils.widgets.get('volume')
destdb = dbutils.widgets.get('destdb')
incfilename = dbutils.widgets.get('incfilename')

# COMMAND ----------

# imports
from delta.tables import DeltaTable

# COMMAND ----------

# variables
tablename = incfilename.split('_')[0]
sourcePath = f"/Volumes/{catalog}/{schema}/{volume}/incremental/"

# COMMAND ----------

spark.sql(f"use catalog {catalog}")

# COMMAND ----------

# load delta table as DeltaTable for merge command
deltaF = DeltaTable.forName(spark, f'{destdb}.{tablename}')

# COMMAND ----------

#load updatefile
updateDf = spark.read.format('parquet').load(sourcePath + incfilename )

# COMMAND ----------

# do the merge
if tablename == 'restaurants':
    deltaF.alias('t') \
        .merge( 
            updateDf.alias('u'),
            't.restaurantId = u.restaurantId'
            ) \
        .whenMatchedUpdateAll() \
        .whenNotMatchedInsertAll() \
        .execute()
else: # it's customers
    deltaF.alias('t') \
        .merge( 
            updateDf.alias('u'),
            't.customerId = u.customerId'
            ) \
        .whenMatchedUpdateAll() \
        .whenNotMatchedInsertAll() \
        .execute()



# COMMAND ----------

print ('finished')
