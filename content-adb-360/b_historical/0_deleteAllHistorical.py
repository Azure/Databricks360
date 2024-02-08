# Databricks notebook source
# MAGIC %md
# MAGIC ### Delete all from historical

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
destPath = f'/Volumes/{catalog}/{schema}/{volume}/historical/'

# COMMAND ----------

dbutils.fs.rm(destPath, True)

# COMMAND ----------


