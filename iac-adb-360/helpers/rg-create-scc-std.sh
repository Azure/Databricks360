#!/bin/bash

solutionname='adbsccstd'
location='westus2'
locationshortname='wus2'
subscriptionid='<subscriptionid>'
serviceprincipalname='devops-sc'
adbinteractprincipalname='adb360-sp'


month=$(date -d "$D" '+%m')
day=$(date -d "$D" '+%d')

dailysolutionname="$solutionname$month$day"
echo "solution name: $dailysolutionname"

# creating 3 resource groups for databricks, the networks and the transit network
rgDev="rg-$locationshortname-$dailysolutionname-dev"
rgDevNet="rg-$locationshortname-$dailysolutionname-net-dev"
rgDevTrans="rg-$locationshortname-$dailysolutionname-trans-dev"

# get service principal object id
serviceprincipaloid=$(az ad sp list --display-name $serviceprincipalname --query "[].id" -o tsv)
echo "found $serviceprincipaloid for devops-sc"

adbspoid=$(az ad sp list --display-name $adbinteractprincipalname --query "[].id" -o tsv)
echo "found $adbspoid for adb-sp"

erg=$(az group list --query "[?name=='$rgDev'].name" -o tsv)
if [ -z "$erg" ] 
    then 
        echo 'resourcegroup does not exist, create it'
        az group create -n $rgDev -l $location
        az role assignment create --role 'Contributor' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDev"
        az role assignment create --role 'Contributor' --assignee $adbspoid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDev"
        az role assignment create --role 'User Access Administrator' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDev"
    else
        echo 'resourcegroup exists, delete and recreate it'
        az group delete -n $rgDev -y
        az group create -n $rgDev -l $location
        az role assignment create --role 'Contributor' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDev"
        az role assignment create --role 'Contributor' --assignee $adbspoid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDev"
        az role assignment create --role 'User Access Administrator' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDev"
fi

erg=$(az group list --query "[?name=='$rgDevNet'].name" -o tsv)
if [ -z "$erg" ] 
    then 
        echo 'resourcegroup does not exist, create it'
        az group create -n $rgDevNet -l $location
        az role assignment create --role 'Contributor' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDevNet"
        az role assignment create --role 'User Access Administrator' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDevNet"
    else
        echo 'resourcegroup exists, delete and recreate it'
        az group delete -n $rgPrd -y
        az group create -n $rgPrd -l $location
        az role assignment create --role 'Contributor' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDevNet"
        az role assignment create --role 'User Access Administrator' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDevNet"
fi

erg=$(az group list --query "[?name=='$rgDevTrans'].name" -o tsv)
if [ -z "$erg" ] 
    then 
        echo 'resourcegroup does not exist, create it'
        az group create -n $rgDevTrans -l $location
        az role assignment create --role 'Contributor' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDevTrans"
        az role assignment create --role 'User Access Administrator' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDevTrans"
    else
        echo 'resourcegroup exists, delete and recreate it'
        az group delete -n $rgDevTrans -y
        az group create -n $rgDevTrans -l $location
        az role assignment create --role 'Contributor' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDevTrans"
        az role assignment create --role 'User Access Administrator' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDevTrans"
fi

echo 'finished'