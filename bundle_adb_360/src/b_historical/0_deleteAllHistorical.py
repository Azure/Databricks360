# Databricks notebook source
# MAGIC %md
# MAGIC ### Delete all from historical bronze
# MAGIC ---
# MAGIC This notebook deletes all the data from the bronze volume and needs three parameters:
# MAGIC * the catalog (default catadb360dev)
# MAGIC * the schema (default schemaadb360dev)
# MAGIC * the volume name (default bronze)

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

# this is deleting everything on the volume bronze in folder historical
dbutils.fs.rm(destPath, True)

# COMMAND ----------

print('finished')
