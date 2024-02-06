#!/bin/bash

resourcegroupname=$1 #'rg-wus3-adbmidp0912-dev'
echo "$resourcegroupname as parm 1"
tenantid=$2 #'12ce7121-18c7-4841-98f9-3b26fc8af34f'
echo "$tenantid as parm 2"
# client-id
clientid=$3 #'a439677f-074f-4dbe-9af3-b9f39fb74ba0'
echo "$clientid as parm 3"
clientsecret=$4 #'<<none>>'
echo "$clientsecret as parm 4"
clusterconf=$5
echo "$clusterconf as parm 5"

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


# create the cluster if not exists
databricks clusters list --output json | jq .[].cluster_name
cluster=$(databricks clusters list --output json | jq .[].cluster_name)
cat "helpers/$clusterconf.json"
configCluster=$(cat "helpers/$clusterconf.json" | jq .cluster_name)
echo "found cluster $cluster"
echo "desired cluster $configCluster"

if [ "$cluster" != "$configCluster" ]
    then
        echo 'cluster does not exist, create it'
        databricks clusters create --json "@iac-adb-360/helpers/$clusterconf.json"
    else
        echo 'cluster exists, do not do a thing'
fi

# we need to set user isolation to get it to be uc enabled !!!
#databricks clusters edit 0929-013020-kl6wbmd1  13.3.x-scala2.12 --data-security-mode USER_ISOLATION --num-workers 1 --node-type-id Standard_E4ads_v5 --cluster-name $cluster
echo 'finished creating cluster'