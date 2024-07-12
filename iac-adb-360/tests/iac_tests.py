import os
from dotenv import load_dotenv
import requests
from msal import ConfidentialClientApplication
import pytest







@pytest.fixture(params=['rg-wus3-adb3600614-dev'])
def rgContent(access_token, request):
    # Define the Azure Management Resource API endpoint
    subscription_id = os.getenv("AZURE_SUBSCRIPTION_ID")  # Replace with your subscription ID
    resource_group_name = request.param
    url = f"https://management.azure.com/subscriptions/{subscription_id}/resourcegroups/{resource_group_name}/resources?api-version=2020-06-01"

    # Make the API call to list resources in the specified resource group
    headers = {"Authorization": f"Bearer {access_token}"}
    response = requests.get(url, headers=headers)

    # Check if the request was successful
    if response.status_code == 200:
        resources = response.json()
        return resources
    else:
        print("Failed to retrieve resources. Status code:", response.status_code)

@pytest.fixture(params=['rg-wus3-adb3600614-dev'])
def rgJson(request)->dict:
    load_dotenv()

    # Initialize the MSAL Confidential Client
    client_id = os.getenv("AZURE_CLIENT_ID")
    client_secret = os.getenv("AZURE_CLIENT_SECRET")
    tenant_id = os.getenv("AZURE_TENANT_ID")
    authority = f"https://login.microsoftonline.com/{tenant_id}"

    app = ConfidentialClientApplication(
        client_id=client_id,
        authority=authority,
        client_credential=client_secret,
    )

    # Acquire Token
    token_response = app.acquire_token_for_client(scopes=["https://management.azure.com/.default"])

    # Extract the Access Token
    access_token = token_response.get("access_token", "")

    # Define the Azure Management Resource API endpoint
    subscription_id = os.getenv("AZURE_SUBSCRIPTION_ID")  # Replace with your subscription ID
    resource_group_name = request.param
    url = f"https://management.azure.com/subscriptions/{subscription_id}/resourcegroups/{resource_group_name}/resources?api-version=2020-06-01"

    # Make the API call to list resources in the specified resource group
    headers = {"Authorization": f"Bearer {access_token}"}
    response = requests.get(url, headers=headers)

    # Check if the request was successful
    if response.status_code == 200:
        resources = response.json()
        return resources
    else:
        print("Failed to retrieve resources. Status code:", response.status_code)



# test whether a resource group exists and has content
def test_resourceGroupExists(rgJson):
    assert rgJson["value"] != None
    assert len(rgJson["value"]) > 0
    print(f"Resource group {rgJson["value"][0]["id"].split('/')[4]} exists and contains resources")


# test has a number of resources in
def test_resourceGroupContainsNumberOfResources(rgJson):
    noResources = 5
    print(f"Resource group contains {noResources} resources")
    assert len(rgJson["value"]) == noResources



# test, that resource group is in the correct location
def test_rgLocation(rgContent):
    location = 'westus3'
    print(f"Resource group location is {rgContent['value'][0]['location']}")
    assert rgContent["value"][0]["location"] == location


def test_rgContainsResources(rgContent):
    desiredResources = {
        "values": [
            {
                "resourceName" : "adbac-wus3-adb3600614-dev",
                "type": "Microsoft.Databricks/accessConnectors",
                "verified": False
            },
            {
                "resourceName" : "law-wus3adb3600614-dev",
                "type": "Microsoft.OperationalInsights/workspaces",
                "verified": False
            },
            {
                "resourceName" : "dlg2westus3adb360061bjpy",
                "type": "Microsoft.Storage/storageAccounts",
                "verified": False
            },
            {
                "resourceName" : "dlg2metastoredevwestpt3q",
                "type": "Microsoft.Storage/storageAccounts",
                "verified": False
            },
            {
                "resourceName" : "adbws-wus3adb3600614dev",
                "type": "Microsoft.Databricks/workspaces",
                "verified": False
            }
        ]
    } 

    for resource in rgContent["value"]:
        for desiredResource in desiredResources["values"]:
            if resource["name"] == desiredResource["resourceName"] and resource["type"] == desiredResource["type"]:
                desiredResource["verified"] = True

    # final test
    for desiredResource in desiredResources["values"]:
        print(f"Resource {desiredResource['resourceName']} of type {desiredResource['type']} verified: {desiredResource['verified']}")
        assert desiredResource["verified"] == True  

# test, that IAM settings are correct
def test_getRoleAssignments(access_token, rgContent):
    #test data roledefids are Contributor and User Access Administrator
    # user principal ids are devops-sc and adb360-sp
    desiredRAs = {
        "values": [
            {
                "roleDefinitionId": "b24988ac-6180-42a0-ab88-20f7382dd24c", 
                "pids" : [
                    {
                    "pid": "73807960-2e65-4132-9e31-d6714aed4a09", 
                    "verified": False
                    }, 
                    {
                    "pid":"aff89e98-fba2-4469-864e-76e1b6a52c74", 
                    "verified": False
                    } 
                ]
            },   
            {
                "roleDefinitionId": "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9" ,
                "pids" : [
                    {
                        "pid":"73807960-2e65-4132-9e31-d6714aed4a09", 
                        "verified": False
                    }
                ]
            }
        ]
        
    }


    # Get the resource ID of the resource group
    resource_id = rgContent["value"][0]["id"]

    # Define the Azure Management Role Assignments API endpoint
    url = f"https://management.azure.com/{resource_id}/providers/Microsoft.Authorization/roleAssignments?api-version=2020-04-01-preview"

    # Make the API call to retrieve the role assignments
    headers = {"Authorization": f"Bearer {access_token}"}
    response = requests.get(url, headers=headers)

    # Check if the request was successful
    if response.status_code == 200:
        role_assignments = response.json()
        assert len(role_assignments["value"]) > 0
        print("Role assignments retrieved successfully")
        raJson = role_assignments["value"]
     
        for ra in raJson:
            roleDefId = ra["properties"]["roleDefinitionId"].split('/')[-1]
            principalId = ra["properties"]["principalId"]
            for desiredRA in desiredRAs["values"]:
                if desiredRA["roleDefinitionId"] == roleDefId:
                    for pid in desiredRA["pids"]:
                        if pid["pid"] == principalId:
                            pid["verified"] = True

        for resultRA in desiredRAs["values"]:
            for pid in resultRA["pids"]:
                print(f"roldDefId : {resultRA['roleDefinitionId']} pid: {pid['pid']} verified: {pid['verified']}")
                assert pid["verified"] == True
    else:
        assert(False)
        print("Failed to retrieve role assignments. Status code:", response.status_code)