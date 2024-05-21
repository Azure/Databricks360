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
echo "metastorename: $metastorename as parm 5"
env=$6
echo "environment: $env as parm 6"
storageaccountname=$7
echo "$storageaccountname as parm 7"
credname=$8
echo "$credname as parm 8"
accessconnectorid=$9
echo "$accessconnectorid as parm 9"

# variables
extlocationname="catextloc$env"
extlocationurl="abfss://fsms@$storageaccountname.dfs.core.windows.net/"

# catalog name
catname="catadb360$env"
echo "catalog name: $catname"
schemaname="schemaadb360$env"
echo "schema name: $schemaname"

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
    cred=$(databricks storage-credentials list --output json | jq -r ".[] | select(.name==\"$credname\") | .name")
    # if we don't have the credential, create it
    if [ -z "$cred" ]
    then
        echo "credential $credname not found, creating"
        databricks storage-credentials create  --json '{ "name" : "'$credname'",  "azure_managed_identity" : { "access_connector_id" : "'$accessconnectorid'" }}'
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




# getting the catalogs from metastore
cats=$(databricks catalogs list --output json | jq -r ".[] | select(.full_name==\"$catname\") | .full_name")
echo "found: $cats"

if [ -z "$cats" ]
then
    echo "catalog $catname not found, creating it"
    cat=$(databricks catalogs create  $catname --storage-root $extlocationurl --output json)
    # granting devcat-admins all privileges
    databricks grants update catalog $catname --json '{ "changes": [{"principal": "devcat-admins", "add" : ["ALL_PRIVILEGES"]}] }'
    
    echo "creating schema $schemaname"
    databricks schemas create  $schemaname $catname --output json
else
    echo "catalog $catname found, skipping creation"
    # check for schema
    schems=$(databricks schemas list catadb360dev --output json | jq -r ".[] | select(.name==\"$schemaname\") | .name")
    if [ -z "$schems" ]
    then
        echo "schema $schemaname not found, creating it"
        databricks schemas create  $schemaname $catname --output json
    else
        echo "schema $schemaname found, skipping creation"
    fi
fi


echo 'finished !'