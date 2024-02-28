param baseName string
param env string = 'dev'
param location string = resourceGroup().location
param withVnet bool = true
param addressSpace string = '192.168.5.0/24'

var subnets  = [for i in range(0,2): cidrSubnet('${addressSpace}', 25, i)]


resource transnsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${baseName}${env}-transnsg'
  location: location
  properties: {
    securityRules: [
      // Add your security rules here
    ]
  }
}


// creates the vnet and networks for 
resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = if(withVnet) {
  name: '${baseName}${env}-transvnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpace
      ]
    }
    subnets: [
      
      {
        name: '${baseName}${env}-transplink'
        properties: {
          addressPrefix: subnets[0]
          networkSecurityGroup: {
            id: transnsg.id
          }
        }
      }
      {
        name: '${baseName}${env}-transclient'
        properties: {
          addressPrefix: subnets[1]
          networkSecurityGroup: {
            id: transnsg.id
          }
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output plinkSubnetId string = vnet.properties.subnets[0].id
output clientSubnetId string = vnet.properties.subnets[1].id

