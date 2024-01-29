-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Delete All Gold

-- COMMAND ----------

-- MAGIC %python
-- MAGIC dbutils.widgets.text('catalog', 'catadb360dev')
-- MAGIC dbutils.widgets.text('dbname', 'golddb')

-- COMMAND ----------

-- MAGIC %python
-- MAGIC catalogname = dbutils.widgets.get('catalog')
-- MAGIC dbname = dbutils.widgets.get('dbname')
-- MAGIC spark.conf.set('adb360.curcatalog', catalogname)
-- MAGIC spark.conf.set('adb360.curdbname', dbname)

-- COMMAND ----------

use catalog ${adb360.curcatalog}

-- COMMAND ----------

drop schema if exists ${adb360.curdbname} cascade

-- COMMAND ----------


