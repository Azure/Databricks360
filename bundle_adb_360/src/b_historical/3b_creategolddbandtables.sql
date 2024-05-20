-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Create Golddb and Tables
-- MAGIC ---
-- MAGIC This notebook creates the golddb and the dimensions as well as the fact table:
-- MAGIC - dimcustomer, 
-- MAGIC - dimaddress, 
-- MAGIC - dimfood, 
-- MAGIC - dimrestaurant, 
-- MAGIC - factmenues
-- MAGIC also
-- MAGIC - watermarktable (this table is for storing the last ingested commit from silver)
-- MAGIC
-- MAGIC parameters needed:
-- MAGIC * catalog (default catadb360)
-- MAGIC * dbname (default golddb)

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

create schema if not exists ${adb360.curdbname}

-- COMMAND ----------

use schema ${adb360.curdbname}

-- COMMAND ----------

create table if not exists golddb.dimaddress(
    addresskey bigint,
    addressid int,
    State string,
    StreetNo int,
    Street string,
    City string,
    Zip int
)
using delta

-- COMMAND ----------

create table if not exists golddb.dimcustomer (
    dimcustomerkey bigint,
    customerid int,
    firstName string,
    lastName string,
    customerType string,
    birthDate date,
    ssn string,
    Email string,
    Phone string,
    fkaddress int,
    current boolean,
    validfrom timestamp,
    validto timestamp
)
using delta

-- COMMAND ----------

create table if not exists golddb.dimrestaurant (
    restaurantkey bigint,
    restaurantid int,
    restaurantname string,
    noOfTables int,
    staffCount int,
    Phone string,
    email string,
    fkaddress int
)
using delta

-- COMMAND ----------

create table if not exists golddb.dimfood (
    foodkey bigint,
    foodname string,
    cost decimal,
    foodcategory string
)
using delta

-- COMMAND ----------

create table if not exists golddb.factmenues (
    fkdate int,
    fkcustomer bigint,
    fkwaiter bigint,
    fkrestaurant bigint,
    fkfood bigint,
    tableid int,
    dinnercost decimal
)
using delta

-- COMMAND ----------

create table if not exists golddb.watermarktable (
    lastCommitKey bigint,
    lastTimeStamp timestamp,
    tablename string
)
using delta

-- COMMAND ----------

show tables
