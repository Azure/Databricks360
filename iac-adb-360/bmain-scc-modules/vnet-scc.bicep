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
          networkSecurityGroup: {
            id: nsg.id
          }
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
          networkSecurityGroup: {
            id: nsg.id
          }
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
output plinkSubnetId string = filter(vnet.properties.subnets, s => contains(s.name, '-plink'))[0].id 
output plinksubnetname string = filter(vnet.properties.subnets, s => contains(s.name, '-plink'))[0].name
output clientSubnetId string = filter(vnet.properties.subnets, s => contains(s.name, '-client'))[0].id 
output pubsubnetname string = filter(vnet.properties.subnets, s => contains(s.name, '-pub'))[0].name
output privsubnetname string = filter(vnet.properties.subnets, s => contains(s.name, '-priv'))[0].id

