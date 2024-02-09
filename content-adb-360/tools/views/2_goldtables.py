# Databricks notebook source
# MAGIC %md
# MAGIC ## View of GoldTables
# MAGIC ---
# MAGIC This notebook displays the gold tables after scd type 1 and 2, fact historical loads.
# MAGIC
# MAGIC Parameters:
# MAGIC * catalog (default catadb360dev)
# MAGIC * dbname (default golddb)
# MAGIC * tablelist (default dimaddress,dimcustomer,dimfood,dimrestaurant,factsmenues)

# COMMAND ----------

dbutils.widgets.text('catalog', 'catadb360dev')
dbutils.widgets.text('schema', 'golddb')
dbutils.widgets.text('tablelist', 'dimaddress,dimcustomer,dimfood,dimrestaurant,factsmenues')

# COMMAND ----------

catalog = dbutils.widgets.get('catalog')
schema = dbutils.widgets.get('schema')
tlist = dbutils.widgets.get('tablesist')


# COMMAND ----------

tables = tlist.split(",")

# COMMAND ----------

spark.sql(f"use catalog {catalog}")

# COMMAND ----------

tablesDfArr = []
for table in historicalSilverTables:
    tempDf = spark.sql(f"select * from golddb.{table}")
    tablesDfArr.append(tempDf)

# COMMAND ----------


