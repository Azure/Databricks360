#!/bin/bash

# params
project=$1
echo "got project: $project"
env=$2
echo "got env: $env"
tenantid=$3
echo "got tenantid: $tenantid"
ghpat=$4
echo "got ghpat"
resourcegroupname=$5
echo "got resourcegroupname: $resourcegroupname"
metastorename=$6
echo "got metastorename: $metastorename"
clientid=$7
echo "got clientid: $clientid"
cliensecret=$8
echo "got clientsecret"
repourl=$9
echo "got repourl: $repourl"

vgname="vg$env-adb360"

# get all values from resourcegroup
resjson=$(az resource list -g $resourcegroupname)

accessconnectorid=$(echo $resjson | jq -r ".[] | select(.type==\"Microsoft.Databricks/accessConnectors\") | .id"))
bronzestorageaccountname=$(echo $resjson | jq -r ".[] | select((.type==\"Microsoft.Storage/storageAccounts\") and (.name | contains(\"adb360\"))) | .name"))
catalogstorageaccountname=$(echo $resjson | jq -r ".[] | select((.type==\"Microsoft.Storage/storageAccounts\") and (.name | contains(\"metastore\"))) | .name"))

groupid=$(az pipelines variable-group create \
    --name $vgname \
    --authorize true \
    --variables \
        "accessconnectorid=$accessconnectorid" \
        "bronzestorageaccountname=$bronzestroageaccountname" \
        "catalogstorageaccountname=$catalogstorageaccountname" \
        "clientid=$clientid" \
        'clusterconf=sharedcluster' \
        "credname=$envcreds" \
        "env=$env" \
        'ghuser=chrey-gh' \
        "metastorename=$metastorename" \
        "repourl=$repourl" \
        "resourcegroupname=$resourcegroupname" \
        "tenantid=$tenantid" \
    --org https://dev.azure.com/alzkram \
    --project $project \
    --query id \
    --output tsv)

    # the two secrets
    az pipelines variable-group variable create \
        --id $groupid \
        --name 'clientsecret' \
        --secret true \
        --org https://dev.azure.com/hdikram \
        --project $project \
        --value $clientsecret

    az pipelines variable-group variable create \
        --id $groupid \
        --name 'ghpat' \
        --secret true \
        --org https://dev.azure.com/hdikram \
        --project $project \
        --value $ghpat 
