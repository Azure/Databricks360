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

# MAGIC %md
# MAGIC ## Gold Tables Historical

# COMMAND ----------

dbutils.widgets.text('catalog', 'catadb360dev')
dbutils.widgets.text('schema', 'golddb')
dbutils.widgets.text('tablelist', 'dimaddress,dimcustomer,dimfood,dimrestaurant,factmenues')

# COMMAND ----------

catalog = dbutils.widgets.get('catalog')
schema = dbutils.widgets.get('schema')
tlist = dbutils.widgets.get('tablelist')


# COMMAND ----------

tables = tlist.split(",")

# COMMAND ----------

spark.sql(f"use catalog {catalog}")

# COMMAND ----------

tablesDfArr = []
for table in tables:
    tempDf = spark.sql(f"select * from golddb.{table}")
    tablesDfArr.append(tempDf)

# COMMAND ----------

# MAGIC %md
# MAGIC ### Dimcustomer

# COMMAND ----------

display(tablesDfArr[1])

# COMMAND ----------

# MAGIC %md
# MAGIC ### Dimaddress

# COMMAND ----------

display(tablesDfArr[0])

# COMMAND ----------

# MAGIC %md
# MAGIC ### Dimfood

# COMMAND ----------

display(tablesDfArr[2])

# COMMAND ----------

# MAGIC %md
# MAGIC ### Dimrestaurant

# COMMAND ----------

display(tablesDfArr[3])

# COMMAND ----------

# MAGIC %md
# MAGIC ### Factsmenues

# COMMAND ----------

display(tablesDfArr[4])
