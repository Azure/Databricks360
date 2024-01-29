#!/bin/bash


# parameters
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
env=$6
echo "$env as parm 6"
storageaccountname=$7
echo "$storageaccountname as parm 7"
credname=$8
echo "$credname as parm 8"

# calculate catalog name
extlocationname="bronzextloc$env"
extlocationurl="abfss://bronze@$storageaccountname.dfs.core.windows.net/"


# get token
#az login --service-principal -u $clientid -p $clientsecret -t $tenantid
#at=$(az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d --query accessToken --output tsv)

# get workspace url and id
workspacestuff=$(az databricks workspace list -g $resourcegroupname --query "[].{url:workspaceUrl, id:id}" -o tsv)
workspaceUrl=$(echo $workspacestuff | cut -d " " -f 1)
workspaceId=$(echo $workspacestuff | cut -d " " -f 2)
echo "$workspaceUrl"
echo "$workspaceId"


# set env variables for auth
export ARM_CLIENT_ID=$clientid
export ARM_CLIENT_SECRET=$clientsecret
export ARM_TENANT_ID=$tenantid
# this is going to add ths sp to the workspace
export DATABRICKS_AZURE_RESOURCE_ID=$workspaceId

# getting the external locations from metastore
exts=$(databricks external-locations list  --output json | jq -r ".[] | select(.name==\"$extlocationname\") | .name")
echo "found: $exts"


if [ -z "$exts" ]
then
    echo "external location $extlocationname not found, creating it"
    # getting the credentialname
    $cred=$(databricks storage-credentials list --output json | jq -r ".[] | select(.name==\"$credname\") | .name")
    #credname=$(curl X GET -H 'Content-Type: application/json' -H "Authorization: Bearer $at" "https://$workspaceUrl/api/2.1/unity-catalog/storage-credentials" | jq -r .[][].name)
    # if we don't have the credential, create it
    if [ -z "$cred" ]
    then
        echo "credential $credname not found, create it and rerun this script"
        exit 1
    else
        echo "credential $credname found, skipping "
    fi
   
    # create external location
    extloc=$(databricks external-locations create  $extlocationname $extlocationurl $credname )
    # sp needs to be the owner of the storage credentials
    echo "external location created: $extloc"
    # add all privileges to devcat-admins
    databricks grants update external_location $extlocationname --json '{ "changes": [{"principal": "devcat-admins", "add" : ["ALL_PRIVILEGES"]}] }'
else
    echo "external location $extlocationname found, skipping creation"
fi

echo 'finished !'