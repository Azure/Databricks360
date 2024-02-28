param baseName string
param env string = 'dev'
param location string = resourceGroup().location

var adbwsmngresid = '${subscription().id}/resourceGroups/${resourceGroup().name}-mng'
var locationshortstring = location == 'westus3'? 'wus3' : location == 'westus2'? 'wus2' : location == 'westus' ? 'wus' : location

param vnetResourceGroup string 
param vnetName string



// get the existing vnet
resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroup)
}


// create adb workspace
module adbwsmng './bmain-scc-modules/adbws-scc.bicep' = {
  name: '${baseName}${env}-adbwsmng'
  params: {
    location: location
    adbmngresourceid: adbwsmngresid
    baseName: baseName
    env: env
    locationshortname: locationshortstring
    plinksubnetid: vnet.properties.subnets[2].id
    privatesubnetname: vnet.properties.subnets[1].name
    publicsubnetname: vnet.properties.subnets[0].name
    vnetid: vnet.id
  }
}
