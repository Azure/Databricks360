-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Verifying Catalog/Schema and Creating Volume on Bronze
-- MAGIC ---
-- MAGIC * Catalog 'catadb360dev' with schema 'schemaadb360dev' should already have been created by cicd pipeline
-- MAGIC * also the external storage location 'bronzeextlocdev' with the asscociated storage credentials
-- MAGIC
-- MAGIC finally this notebook is creating a volume for bronze files
-- MAGIC >The parameter needed is the storage account name

-- COMMAND ----------

-- DBTITLE 1,Parameters
-- MAGIC %python
-- MAGIC dbutils.widgets.text('storageaccountname', '')

-- COMMAND ----------

-- MAGIC %python
-- MAGIC storageaccountname = dbutils.widgets.get('storageaccountname')
-- MAGIC spark.conf.set('adb360.storageaccountname', storageaccountname)

-- COMMAND ----------

show catalogs

-- COMMAND ----------

use catalog catadb360dev

-- COMMAND ----------

show schemas

-- COMMAND ----------

create schema if not exists catadb360dev.schemaadb360dev 

-- COMMAND ----------

use schema schemaadb360dev

-- COMMAND ----------

create external volume if not exists bronze
location 'abfss://bronze@${adb360.storageaccountname}.dfs.core.windows.net/' 

-- COMMAND ----------

show volumes
