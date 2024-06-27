param baseName string
param env string
param location string
param uamipid string
param lawid string

var tempdlgname = 'dlg2${env}${location}${baseName}'
var curatedDlgName = substring('${substring(tempdlgname, 0, 20)}${uniqueString(tempdlgname)}', 0, 24)
var tempmetastorename = 'dlg2metastore${env}${location}${baseName}'
var curatedMetaStorename = substring('${substring(tempmetastorename, 0, 20)}${uniqueString(tempmetastorename)}', 0, 24)
var storageblobdatacontributordefid = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource dlg2 'Microsoft.Storage/storageAccounts@2022-09-01'={
  name: curatedDlgName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
  }
}

resource bs 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01'={
  name: 'default'
  parent: dlg2
}

resource diagsets 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'blob-service-diagnostic-settings'
  scope: bs
  properties: {
    workspaceId: lawid
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics:[
      {
        category: 'Transaction'
        enabled: true
      }
    ]      
  }    
}

resource bronze 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01'={
  name: 'bronze'
  parent: bs
}

resource silver 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01'={
  name: 'silver'
  parent: bs
}

resource gold 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01'={
  name: 'gold'
  parent: bs
}

resource dlg2ms 'Microsoft.Storage/storageAccounts@2022-09-01'={
  name: curatedMetaStorename
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
  }
}

resource bsms 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01'={
  name: 'default'
  parent: dlg2ms
}

resource fsms 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01'={
  name: 'fsms'
  parent: bsms
}

resource sBDCRoleDefinitionId 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: storageblobdatacontributordefid
}

resource rauamitosa 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: dlg2ms
  name: guid(dlg2ms.id, uamipid, storageblobdatacontributordefid )
  properties: {
    principalId: uamipid
    roleDefinitionId: sBDCRoleDefinitionId.id
    principalType: 'ServicePrincipal'
  }
}

resource rauamitosa2 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: dlg2
  name: guid(dlg2.id, uamipid, storageblobdatacontributordefid )
  properties: {
    principalId: uamipid
    roleDefinitionId: sBDCRoleDefinitionId.id
    principalType: 'ServicePrincipal'
  }
}


