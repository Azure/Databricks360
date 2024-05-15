#!/bin/bash
adoorg="https://dev.azure.com/hdikram"
adoproject="adb360-0514"


az pipelines variable-group create \
    --name vgdevadb360 \
    --variables accessconnectorid="/subscriptions/3d11a8f9-16c2-438e-bbed-3b23505340ec/resourceGroups/rg-wus2-adb3600514-dev/providers/Microsoft.Databricks/accessConnectors/adbac-wus2-adb3600514-dev" \
                bronzestorageaccountname="dlg2westus2adb360051gclk" \
                catalogstorageaccountname="dlg2metastoredevwestgdth" \
                clientid="ee429c67-2078-47b5-8bcb-b4c66b02bb24" \
                clusterconf="sharedcluster" \
                credname="decvreds" \
                env="dev" \
                ghuser="chrey-gh" \
                metastorename="metawus2" \
                repourl="https://github.com/chrey-gh/Databricks360.git" \
                resourcegroupname="rg-wus2-adb3600514-dev" \
                tenantid="12ce7121-18c7-4841-98f9-3b26fc8af34f" \
    --organization $adoorg \
    --project $adoproject

    