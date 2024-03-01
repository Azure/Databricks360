param baseName string
param env string
param location string
param uamipid string
param subnetid string
param vnetid string


var tempdlgname = 'dlg2${location}${baseName}${env}'
var curatedDlgName = substring('${substring(tempdlgname, 0, 20)}${uniqueString(tempdlgname)}', 0, 24)
var storageblobdatacontributordefid = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

var storageenv = environment().suffixes.storage

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

resource dlg2Account 'Microsoft.Storage/storageAccounts@2023-01-01' =  {
  name: curatedDlgName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    isHnsEnabled: true
    publicNetworkAccess: 'Disabled'
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

resource privateEndpointstoragedfs 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: 'pe-${curatedDlgName}-dfsstorage'
  location: location
  properties: {
    subnet: {
      id: subnetid
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-to-dfsstorage'
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

resource privateDnsZonestoragedfs 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.dfs.${storageenv}'
  location: 'global'
  dependsOn: [
    privateEndpointstoragedfs
  ]
}

resource privateDnsZoneName_privateDnsZoneName_link_storage 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZonestoragedfs
  name: 'peDnsZone-${curatedDlgName}-dfsstorage-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetid
    }
  }
}

resource pvtEndpointDnsGroupstorage 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: 'peDnsGroup-${curatedDlgName}-dfsstorage'
  parent: privateEndpointstoragedfs
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1storage'
        properties: {
          privateDnsZoneId: privateDnsZonestoragedfs.id
        }
      }
    ]
  }

}


