#!/bin/bash
adoproject='adb360-011024'

export AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY=''
# azure rm ado-sc
az devops service-endpoint azurerm create --azure-rm-service-principal-id ec29e4e4-744b-44bf-bfab-7d42f22658b7 --azure-rm-subscription-id c34026fc-b157-458c-b191-6e699909523c --azure-rm-subscription-name Visual Studio Enterprise Subscription --azure-rm-tenant-id 9dfc6589-1b35-45e9-9855-379ff3fab2dc --name ado-sc --org https://dev.azure.com/medagan0807 --project $adoproject

export AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY=''
# azure rm adb-sc
az devops service-endpoint azurerm create --azure-rm-service-principal-id c6a00277-af50-4767-9614-8314402e5d64 --azure-rm-subscription-id c34026fc-b157-458c-b191-6e699909523c --azure-rm-subscription-name Visual Studio Enterprise Subscription --azure-rm-tenant-id 9dfc6589-1b35-45e9-9855-379ff3fab2dc --name adb-sc --org https://dev.azure.com/medagan0807 --project $adoproject

# github
export AZURE_DEVOPS_EXT_GITHUB_PAT=''
az devops service-endpoint github create --github-url https://github.com/belifakbar/Databricks360.git --name gh-sc --org https://dev.azure.com/medagan0807 --project $adoproject
