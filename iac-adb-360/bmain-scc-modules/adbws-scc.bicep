param baseName string
param env string
param location string = resourceGroup().location
param adbmngresourceid string
param locationshortname string
//param lawid string
param vnetid string
param publicsubnetname string
param privatesubnetname string
param plinksubnetid string


resource adbac 'Microsoft.Databricks/accessConnectors@2023-05-01'={
  name: 'adbac-${locationshortname}-${baseName}-${env}'
  location: location
  identity: {
    type: 'SystemAssigned'

  }
  properties:{
    
  }
}


output adbacid string = adbac.id
output adbacpid string = adbac.identity.principalId

resource adbws 'Microsoft.Databricks/workspaces@2023-02-01' = {
  name: 'adbws-${locationshortname}${baseName}${env}'
  location: location
  sku: {
    name: 'premium'
  }
  properties: {
    managedResourceGroupId: adbmngresourceid
    publicNetworkAccess: 'Disabled'
    parameters: {
      customVirtualNetworkId: {
        value: vnetid
      }
      customPublicSubnetName: {
        value: publicsubnetname
      }
      customPrivateSubnetName: {
        value: privatesubnetname
      }
      enableNoPublicIp: {
        value: true
      }
      
    }
    requiredNsgRules: 'NoAzureDatabricksRules'
    
  }
}

output adbwsid string = adbws.id

var pename = 'petoui-${locationshortname}${baseName}${env}'
var pdnszname = 'dnszone-${locationshortname}${baseName}${env}'
var pdnszgname = 'dnszonegroup-${locationshortname}${baseName}${env}'
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: pename
  location: location
  properties: {
    subnet: {
      id: plinksubnetid
    }
    privateLinkServiceConnections: [
      {
        name: pename
        properties: {
          privateLinkServiceId: adbws.id
          groupIds: [
            'databricks_ui_api'
          ]
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azuredatabricks.net'
  
  location: 'global'
  dependsOn: [
    privateEndpoint
  ]
}

resource privateDnsZoneName_privateDnsZoneName_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${pdnszname}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetid
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: pdnszgname
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }

}


/*
resource adbwsdiags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${adbws.name}diags'
  scope: adbws
  properties: {
    workspaceId: lawid
    logs: [
      {
        category: 'dbfs'
        enabled: true
      }
      {
        category: 'clusters'
        enabled: true
      }
      {
        category: 'accounts'
        enabled: true
      }
      {
        category: 'jobs'
        enabled: true
      }
      {
        category: 'notebook'
        enabled: true
      }
      {
        category:'workspace'
        enabled: true
      }
      {
        category: 'sqlAnalytics'
        enabled: true
      }
      {
        category: 'repos'
        enabled: true
      }
      {
        category: 'unitycatalog'
        enabled: true
      }
    ]
  }
}

*/



