-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Create Silverdb and Tables

-- COMMAND ----------

-- MAGIC %python
-- MAGIC dbutils.widgets.text('catalog', 'catadb360dev')
-- MAGIC dbutils.widgets.text('dbname', 'silverdb')

-- COMMAND ----------

-- MAGIC %python
-- MAGIC catalogname = dbutils.widgets.get('catalog')
-- MAGIC dbname = dbutils.widgets.get('dbname')
-- MAGIC spark.conf.set('adb360.curcatalog', catalogname)
-- MAGIC spark.conf.set('adb360.curdbname', dbname)

-- COMMAND ----------

use catalog ${adb360.curcatalog}

-- COMMAND ----------

create schema if not exists ${adb360.curdbname}

-- COMMAND ----------

use schema ${adb360.curdbname}

-- COMMAND ----------

create table if not exists ${adb360.curdbname}.addresses (
    addressId int,
    state string,
    streetno int,
    street string,
    city string,
    zip int
)
using delta
TBLProperties (delta.enableChangeDataFeed = true)

-- COMMAND ----------

create table if not exists ${adb360.curdbname}.customers (
    customerid int,
    firstName string,
    lastName string,
    customerType string,
    email string,
    phone string,
    fkaddress int
)
using delta
TBLProperties (delta.enableChangeDataFeed = true)

-- COMMAND ----------

create table if not exists  ${adb360.curdbname}.menuesconsumed (
    menueId int,
    foodName string,
    foodCategory string,
    cost double,
    dinnerDate date,
    fkcustomer int,
    fkrestaurant int,
    fkwaiter int,
    tableId int
)
using delta
TBLProperties (delta.enableChangeDataFeed = true)

-- COMMAND ----------

create table if not exists ${adb360.curdbname}.restaurants (
    restaurantId int,
    restaurantName string,
    noOfTables int,
    staffCount int,
    phone string,
    email string,
    fkaddress int
)
using delta
TBLProperties (delta.enableChangeDataFeed = true)

-- COMMAND ----------


