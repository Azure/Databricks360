param baseName string
param env string = 'dev'
param location string = resourceGroup().location
param withVnet bool = true
param addressSpace string = '192.168.4.0/24'

var subnets  = [for i in range(0,4): cidrSubnet('${addressSpace}', 26, i)]


resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${baseName}${env}-nsg'
  location: location
  properties: {
    securityRules: [
      // Add your security rules here
    ]
  }
}


// creates the vnet and networks for 
resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = if(withVnet) {
  name: '${baseName}${env}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpace
      ]
    }
    subnets: [
      {
        name: '${baseName}${env}-priv'
        properties: {
          addressPrefix: subnets[0]
          delegations: [{
            name: '${baseName}${env}-del-priv'
            properties: {
              serviceName: 'Microsoft.Databricks/workspaces'
            }
          }
        ]
        }

      }
      {
        name: '${baseName}${env}-pub'
        properties: {
          addressPrefix: subnets[1]
          delegations: [{
            name: '${baseName}${env}-del-pub'
            properties: {
              serviceName: 'Microsoft.Databricks/workspaces'
            }
          }
        ]
        }
      }
      {
        name: '${baseName}${env}-plink'
        properties: {
          addressPrefix: subnets[2]
          networkSecurityGroup: {
            id: nsg.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
      {
        name: '${baseName}${env}-client'
        properties: {
          addressPrefix: subnets[3]
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output plinkSubnetId string = vnet.properties.subnets[2].id
output plinksubnetname string = vnet.properties.subnets[2].name
output clientSubnetId string = vnet.properties.subnets[3].id
output pubsubnetname string = vnet.properties.subnets[1].name
output privsubnetname string = vnet.properties.subnets[0].name

