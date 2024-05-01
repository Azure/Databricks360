#!/bin/bash
project='adb360-0501'

export AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY=
# azure rm
az devops service-endpoint azurerm create --azure-rm-service-principal-id 2732c10d-18e1-4749-a855-3b47daf5dfe1 --azure-rm-subscription-id 3d11a8f9-16c2-438e-bbed-3b23505340ec --azure-rm-subscription-name ME-MngEnv289593-chrey --azure-rm-tenant-id 12ce7121-18c7-4841-98f9-3b26fc8af34f --name ado-sc --org https://dev.azure.com/hdikram --project $project
# github
export AZURE_DEVOPS_EXT_GITHUB_PAT=
az devops service-endpoint github create --github-url https://github.com/chrey-gh/Databricks360.git --name adb-sc --org https://dev.azure.com/hdikram --project $project

