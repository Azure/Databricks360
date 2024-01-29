param baseName string
param env string
param location string
param locationshortname string

resource lawWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01'= {
  name: 'law-${locationshortname}${baseName}-${env}'
  location: location
  properties: {
    retentionInDays: 30
  }
}


output lawid string = lawWorkspace.id
