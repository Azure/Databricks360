# Databricks notebook source
# MAGIC %md
# MAGIC # View Tables on Historical Bronze

# COMMAND ----------

dbutils.widgets.text('catalog', 'catadb360dev')
dbutils.widgets.text('schema', 'schemaadb360dev')
dbutils.widgets.text('volume', 'bronze')

# COMMAND ----------

catalog = dbutils.widgets.get('catalog')
schema = dbutils.widgets.get('schema')
volume = dbutils.widgets.get('volume')

# COMMAND ----------

#variables
historicalBronzeTables = ['customers', 'addresses', 'menuesconsumed', 'restaurants']
sourcePath = f'/Volumes/{catalog}/{schema}/{volume}/historical/'

# COMMAND ----------

tablesDfArr = []
for table in historicalBronzeTables:
    tempDf = spark.read.format('parquet').load(sourcePath + table +'.parquet')
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


