param baseName string
param env string = 'dev'
param location string = resourceGroup().location
@secure()
param pw string

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
