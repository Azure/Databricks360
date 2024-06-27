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
org=$10
echo "got org: $org"
ghuser=$11
echo "got ghuser: $ghuser"

vgname="vg$env"
vgname=+='adb360'

envcreds="$env"
envcreds+='creds'

# get all values from resourcegroup
resjson=$(az resource list -g $resourcegroupname)

accessconnectorid=$(echo $resjson | jq -r ".[] | select(.type==\"Microsoft.Databricks/accessConnectors\") | .id"))
bronzestorageaccountname=$(echo $resjson | jq -r ".[] | select((.type==\"Microsoft.Storage/storageAccounts\") and (.name | contains(\"adb360\"))) | .name"))
catalogstorageaccountname=$(echo $resjson | jq -r ".[] | select((.type==\"Microsoft.Storage/storageAccounts\") and (.name | contains(\"metastore\"))) | .name"))


groupid=$(az pipelines variable-group list --org $org --project $project | jq -r ".[] | select(.name==\"$vgname\") | .id" )
# if we have a group id, delete it
if [[ groupid -gt 0]]; then
    echo "deleting variable group $vgname"
    az pipelines variable-group delete --group-id $groupid --org $org --project $project -y
else
    echo "variable group $vgname not found, creating it"
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
fi
echo "finished"

