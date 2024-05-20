# Databricks notebook source
# MAGIC %md
# MAGIC ## Delete Incremental Data on Bronze
# MAGIC ---
# MAGIC
# MAGIC This notebook deletes the bronze incremental data
# MAGIC
# MAGIC Parameters:
# MAGIC
# MAGIC * catalog (default catadb360dev)
# MAGIC * schema (default schemadb360dev)
# MAGIC * volume (default bronze)

# COMMAND ----------

dbutils.widgets.text('catalog', 'catadb360dev')
dbutils.widgets.text('schema', 'schemaadb360dev')
dbutils.widgets.text('volume', 'bronze')

# COMMAND ----------

catalog = dbutils.widgets.get('catalog')
schema = dbutils.widgets.get('schema')
volume = dbutils.widgets.get('volume')

# COMMAND ----------

# variables
bronzePath = f'/Volumes/{catalog}/{schema}/{volume}/incremental/'

# COMMAND ----------

dbutils.fs.rm(bronzePath, True)

# COMMAND ----------


