-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Catalogs
-- MAGIC ---
-- MAGIC * Catalog 'catadb360dev' should already have been created by cicd pipeline
-- MAGIC * also the external storage location bronzeextlocdev
-- MAGIC * creating a volume for bronze files
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

-- MAGIC %md
-- MAGIC ### Create Permissions in UX as follows:(moved to script catlog and external location creation)
-- MAGIC ---
-- MAGIC * create permissions for group devcat-admins on catalog
-- MAGIC * create permissions for group devcat-admins on external location bronzeextlocdev

-- COMMAND ----------

create schema if not exists catadb360dev.schemaadb360dev 

-- COMMAND ----------

use schema schemaadb360dev

-- COMMAND ----------

create external volume if not exists bronze
location 'abfss://bronze@${adb360.storageaccountname}.dfs.core.windows.net/' 

-- COMMAND ----------

show volumes

-- COMMAND ----------


