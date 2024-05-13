#!/bin/bash

vgname='vgdevadb360'
project='adb360-0501'
clientsecret=''
ghpat=''

groupid=$(az pipelines variable-group create \
    --name $vgname \
    --authorize true \
    --variables \
        'accessconnectorid=/subscriptions/3d11a8f9-16c2-438e-bbed-3b23505340ec/resourceGroups/rg-wus2-adb3600501-dev/providers/Microsoft.Databricks/accessConnectors/adbac-wus2-adb3600501-dev' \
        'bronzestorageaccountname=dlg2westus2adb360050tf2o' \
        'catalogstorageaccountname=dlg2metastoredevwestiprn' \
        'clientid=ee429c67-2078-47b5-8bcb-b4c66b02bb24' \
        'clusterconf=sharedcluster' \
        'credname=devcreds' \
        'env=dev' \
        'ghuser=chrey-gh' \
        'metastorename=metawus2' \
        'repourl=https://github.com/chrey-gh/Databricks360.git' \
        'resourcegroupname=rg-wus2-adb3600501-dev' \
        'tenantid=12ce7121-18c7-4841-98f9-3b26fc8af34f' \
    --org https://dev.azure.com/hdikram \
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
