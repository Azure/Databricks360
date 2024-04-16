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

resource nsgws 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${baseName}${env}-nsg1'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-inbound'
        properties: {
          description: 'Required for worker nodes communication within a cluster.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-databricks-webapp'
        properties: {
          description: 'Required for workers communication with Databricks Webapp.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureDatabricks'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-sql'
        properties: {
          description: 'Required for workers communication with Azure SQL services.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3306'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Sql'
          access: 'Allow'
          priority: 101
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-storage'
        properties: {
          description: 'Required for workers communication with Azure Storage services.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 102
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-outbound'
        properties: {
          description: 'Required for worker nodes communication within a cluster.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 103
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-eventhub'
        properties: {
          description: 'Required for worker communication with Azure Eventhub services.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '9093'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'EventHub'
          access: 'Allow'
          priority: 104
          direction: 'Outbound'
        }
      }
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
            id: nsgws.id
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
            id: nsgws.id
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

