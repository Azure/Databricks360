param baseName string
param env string
param location string
param locationshortname string
param kvadminspid string
param kvuserspid string

var kvadmins = '00482a5a-887f-4fb3-b363-3b7fe8e74483'
var kvsecretreaders = '4633458b-17de-408a-b874-0445c86b69e6'

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: 'kv-${locationshortname}-${baseName}-${env}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies:[
      
    ]
    enableRbacAuthorization: true
  }
}



resource kvadminsroledef 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: kvadmins
}

resource kvadminra 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: kv
  name: guid(kv.id, kvadminspid, kvadmins )
  properties: {
    principalId: kvadminspid
    roleDefinitionId: kvadminsroledef.id
    principalType: 'Group'

  }
}

resource kvsecretreaderroledef 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: kvsecretreaders
}

resource kvuserra 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: kv
  name: guid(kv.id, kvuserspid, kvsecretreaders )
  properties: {
    principalId: kvuserspid
    roleDefinitionId: kvsecretreaderroledef.id
    principalType: 'Group'

  }
}

