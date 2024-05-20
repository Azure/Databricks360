# Databricks notebook source
# MAGIC %md
# MAGIC # View Tables on Historical Silver

# COMMAND ----------

dbutils.widgets.text('catalog', 'catadb360dev')
dbutils.widgets.text('schema', 'silverdb')
dbutils.widgets.text('tableslist', 'customers,addresses,menuesconsumed,restaurants')

# COMMAND ----------

catalog = dbutils.widgets.get('catalog')
schema = dbutils.widgets.get('schema')
tlist = dbutils.widgets.get('tableslist')

# COMMAND ----------

#variables
historicalSilverTables = tlist.split(",")


# COMMAND ----------

spark.sql(f"use catalog {catalog}")

# COMMAND ----------

tablesDfArr = []
for table in historicalSilverTables:
    tempDf = spark.sql(f"select * from silverdb.{table}")
    tablesDfArr.append(tempDf)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Customers

# COMMAND ----------

# customers
display(tablesDfArr[0])

# COMMAND ----------

# MAGIC %md
# MAGIC ## Addresses

# COMMAND ----------

display(tablesDfArr[1])

# COMMAND ----------

# MAGIC %md 
# MAGIC ## Restaurants

# COMMAND ----------

display(tablesDfArr[3])

# COMMAND ----------

# MAGIC %md
# MAGIC ## MenuesConsumed

# COMMAND ----------

display(tablesDfArr[2])

# COMMAND ----------


