param baseName string
param env string
param location string
param uamipid string
param vnetname string
param subnetname string
param vnetid string


var tempdlgname = 'dlg2${location}${baseName}${env}'
var curatedDlgName = substring('${substring(tempdlgname, 0, 20)}${uniqueString(tempdlgname)}', 0, 24)
var storageblobdatacontributordefid = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource sBDCRoleDefinitionId 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: storageblobdatacontributordefid
}

resource rauamitosa 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: dlg2Account
  name: guid(dlg2Account.id, uamipid, storageblobdatacontributordefid )
  properties: {
    principalId: uamipid
    roleDefinitionId: sBDCRoleDefinitionId.id
    principalType: 'ServicePrincipal'
  }
}

resource dlg2Account 'Microsoft.Storage/storageAccounts@2021-04-01' =  {
  name: curatedDlgName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    isHnsEnabled: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetname, subnetname)
          action: 'Allow'
          state: 'succeeded'
        }
      ]
      ipRules: []
      defaultAction: 'Allow'
    }
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
  }

}

resource bs 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01'={
  name: 'default'
  parent: dlg2Account
}

resource bronze 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01'={
  name: 'bronze'
  parent: bs
}

resource privateEndpointstorage 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: 'pe-${curatedDlgName}-storage'
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetname, subnetname)
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-${curatedDlgName}-storage'
        properties: {
          privateLinkServiceId: dlg2Account.id
          groupIds: [
            'dfs'
          ]
        }
      }
    ]
  }
}

resource privateDnsZonestorage 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.dfs.core.windows.net'
  location: 'global'
  dependsOn: [
    privateEndpointstorage
  ]
}

resource privateDnsZoneName_privateDnsZoneName_link_storage 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZonestorage
  name: 'peDnsZone-${curatedDlgName}-storage-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetid
    }
  }
}

resource pvtEndpointDnsGroupstorage 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: 'peDnsGroup-${curatedDlgName}-storage'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1storage'
        properties: {
          privateDnsZoneId: privateDnsZonestorage.id
        }
      }
    ]
  }

}
