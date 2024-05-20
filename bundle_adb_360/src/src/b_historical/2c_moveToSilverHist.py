# Databricks notebook source
# MAGIC %md
# MAGIC ### Historical Load To Silver
# MAGIC ---
# MAGIC This notebook moves the tables found in the parameter 'listoftables' (default customers, restaurants, addresses, menuesconsumed)
# MAGIC to silver as Delta.
# MAGIC (Optionally this would be the place to apply some data quality rules.)
# MAGIC
# MAGIC The parameters are as follows:
# MAGIC * catalog (default catadb360dev)
# MAGIC * sourceschema (default schemaadb360dev)
# MAGIC * volume (default bronze)
# MAGIC * listoftables (default customers, restaurants, addresses, menuesconsumed)

# COMMAND ----------

dbutils.widgets.text('catalog', 'catadb360dev')
dbutils.widgets.text('sourceschema', 'schemaadb360dev')
dbutils.widgets.text('destschema', 'silverdb')
dbutils.widgets.text('volume', 'bronze')
dbutils.widgets.text('listoftables', 'customers,restaurants,addresses,menuesconsumed')

# COMMAND ----------

catalog = dbutils.widgets.get('catalog')
sourceschema = dbutils.widgets.get('sourceschema')
destschema = dbutils.widgets.get('destschema')
volume = dbutils.widgets.get('volume')
listoftables = dbutils.widgets.get('listoftables').split(',')

# COMMAND ----------

#variables
sourcePath = f'/Volumes/{catalog}/{sourceschema}/{volume}/historical/'
destdb = f'{destschema}'

# COMMAND ----------

spark.sql(f'use catalog {catalog}')

# COMMAND ----------

for table in listoftables:
    df = spark.read.format('parquet').load(sourcePath + table + '.parquet')
    df.createOrReplaceTempView('t')
    spark.sql(f'insert overwrite {destdb}.{table} select * from t')

# COMMAND ----------


