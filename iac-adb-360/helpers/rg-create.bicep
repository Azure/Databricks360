targetScope='subscription'

param solutionname string = 'adb360'
param location string = 'eastus2'
param serviceprincipalname string = 'devops-sc'
param serviceprincipaloid string = '964741c1-cfc7-4c7f-b944-1f6db16d3509' //Service Principal Object ID
param adbinteractprincipalname string = 'adb360-sp'
param adbspoid string = 'dc7a057b-6335-4fac-b58a-1728c4b11e09' //Service Principal Object ID
param currentDate string = utcNow('yyyy-MM-ddTHH:mm:ssZ')

var month = substring(currentDate, 5, 2)
var year = substring(currentDate, 0, 4)

var dailysolutionname = '${solutionname}-${month}-${year}' 
var rgDev = '${dailysolutionname}-dev'
var rgPrd = '${dailysolutionname}-prd'

resource rgDevResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgDev
  location: location
}

resource rgPrdResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgPrd
  location: location
}

module devRoleAssignments 'role-assignment.bicep' = {
  name: 'devRoleAssignments'
  scope: resourceGroup(rgDev)
  params: {
    resourceGroupName: rgDev
    serviceprincipalname: serviceprincipalname
    serviceprincipaloid: serviceprincipaloid
    adbinteractprincipalname: adbinteractprincipalname
    adbspoid: adbspoid
  }
}

module prdRoleAssignments 'role-assignment.bicep' = {
  name: 'prdRoleAssignments'
  scope: resourceGroup(rgPrd)
  params: {
    resourceGroupName: rgPrd
    serviceprincipalname: serviceprincipalname
    serviceprincipaloid: serviceprincipaloid
    adbinteractprincipalname: adbinteractprincipalname
    adbspoid: adbspoid
  }
}
