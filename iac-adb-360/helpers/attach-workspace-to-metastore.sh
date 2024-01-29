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
metastorename=$5
echo "$metastorename as parm 5"


# get workspace url and id
workspacestuff=$(az databricks workspace list -g $resourcegroupname --query "[].{url:workspaceUrl, id:id, wid:workspaceId}" -o tsv)
workspaceUrl=$(echo $workspacestuff | cut -d " " -f 1)
workspaceResId=$(echo $workspacestuff | cut -d " " -f 2)
workspaceId=$(echo $workspacestuff | cut -d " " -f 3)
echo "found workspace url: $workspaceUrl"
echo "found workspace res id: $workspaceResId"
echo "found workspace id:  $workspaceId"


# set env variables
export ARM_CLIENT_ID=$clientid
export ARM_CLIENT_SECRET=$clientsecret
export ARM_TENANT_ID=$tenantid
# this is going to add ths sp to the workspace
export DATABRICKS_AZURE_RESOURCE_ID=$workspaceResId


# list the metastores

metastorestuff=$(databricks metastores list --output json)
metastore=$(echo $metastorestuff | jq -r .[].name)
metastoreid=$(echo $metastorestuff | jq -r .[].metastore_id)

if [ "$metastore" != "$metastorename" ]
    then
        echo 'metastore does not exist, please create it manually'

    else
        echo 'metastore exists, check if this workspace is already attached'
        attached=$(databricks metastores current)
        if [ z == z"$attached" ]
            then
                echo 'workspace is not attached, attach it'
                databricks metastores assign $workspaceId $metastoreid 'main' 
            else
                echo 'workspace is already attached, do not do a thing'
        fi
fi

echo 'finished'