param baseName string
param env string = 'dev'
param location string = resourceGroup().location



module vnet 'bmain-scc-modules/vnet-scc.bicep' = {
  name: '${baseName}${env}-vnet'
  params: {
    baseName: baseName
    location: location
    env: env
  }
}
