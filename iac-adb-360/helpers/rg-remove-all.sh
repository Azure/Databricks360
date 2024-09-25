#!/bin/bash

resourcegroupname=$1
clientid=$2
clientsecret=$3
tenant=$4
metastoreid=$5


# get workspace url and id
workspacestuff=$(az databricks workspace list -g $resourcegroupname --query "[].{url:workspaceUrl, id:id}" -o tsv)
workspaceUrl=$(echo $workspacestuff | cut -d " " -f 1)
workspaceId=$(echo $workspacestuff | cut -d " " -f 2)
echo "$workspaceUrl"
echo "$workspaceId"


# set env variables
export ARM_CLIENT_ID=$clientid
export ARM_CLIENT_SECRET=$clientsecret
export ARM_TENANT_ID=$tenantid
# this is going to add ths sp to the workspace
export DATABRICKS_AZURE_RESOURCE_ID=$workspaceId

# delete bronze volume
databricks volumes delete catadb360dev.schemaadb360dev.bronze
# delete external location bronzeextlocdev after taking ownership
databricks external-locations delete bronzextlocdev
# delete golddb tables and golddb
databricks tables delete catadb360dev.golddb.dimaddress
databricks tables delete catadb360dev.golddb.dimcustomer
databricks tables delete catadb360dev.golddb.dimfood
databricks tables delete catadb360dev.golddb.dimrestaurant
databricks tables delete catadb360dev.golddb.factmenues
databricks tables delete catadb360dev.golddb.watermarktable 
databricks schemas delete catadb360dev.golddb
# delete silverdb tables and silverdb
databricks tables delete catadb360dev.silverdb.addresses
databricks tables delete catadb360dev.silverdb.customers
databricks tables delete catadb360dev.silverdb.menuesconsumed
databricks tables delete catadb360dev.silverdb.restaurants 
databricks schemas delete catadb360dev.silverdb
# delete schemaadb360dev
databricks schemas delete catadb360dev.schemaadb360dev
# delete catadb360dev.default
databricks schemas delete catadb360dev.default
# delete catadb360dev
databricks catalogs delete catadb360dev
# delete catextlocdev with force
databricks external-locations delete catextlocdev --force
# delete devcreds after taking ownership
databricks storage-credentials delete devcreds
# remove workspace from metastore

# delete metastore
# delete resource groups