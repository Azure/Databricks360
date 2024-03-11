param baseName string
param env string = 'dev'
param location string = resourceGroup().location
param adbwsresgroupname string
@secure()
param pw string

var locationshortname = location == 'westus3'? 'wus3' : location == 'westus2'? 'wus2' : location == 'westus' ? 'wus' : location

module vnet 'bmain-scc-modules/vnet-scc-transit.bicep' = {
  name: 'vnet'
  params: {
    baseName: baseName
    env: env
    location: location
  }
}


module transvm 'bmain-scc-modules/vm-transit.bicep' = {
  name: 'transvm'
  params: {
    baseName: baseName
    env: env
    location: location
    subnetid: vnet.outputs.clientSubnetId
    pw: pw
  }
}

resource adbws 'Microsoft.Databricks/workspaces@2018-04-01' existing = {
  name: 'adbws-${locationshortname}${baseName}${env}'
  scope: resourceGroup(adbwsresgroupname)

}

module transpes './bmain-scc-modules/transit-pes-auth-n-ui.bicep' = {
  name: 'transpes'
  params: {
    baseName: baseName
    env: env
    location: location
    locationshortname: locationshortname
    transplinksubnetid: vnet.outputs.plinkSubnetId
    vnetid: vnet.outputs.vnetId
    adbwsid: adbws.id
  }
}
