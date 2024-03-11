param baseName string
param env string = 'dev'
param location string = resourceGroup().location
param locationshortname string
param transplinksubnetid string
param adbwsid string
param vnetid string

var transitpename = 'pefromtranstoui-${locationshortname}${baseName}${env}'
var transitpdnszname = 'dnszone-${locationshortname}${baseName}${env}'
var transitpdnszgname = 'dnszonegroup-${locationshortname}${baseName}${env}'

resource transuiprivateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: transitpename
  location: location
  properties: {
    subnet: {
      id: transplinksubnetid
    }
    privateLinkServiceConnections: [
      {
        name: transitpename
        properties: {
          privateLinkServiceId: adbwsid
          groupIds: [
            'databricks_ui_api'
          ]
        }
      }
    ]
  }
}

resource transprivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azuredatabricks.net'
  
  location: 'global'
  dependsOn: [
    transuiprivateEndpoint
  ]
}

resource privateDnsZoneName_privateDnsZoneName_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: transprivateDnsZone
  name: '${transitpdnszname}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetid
    }
  }
}


var transitpenameauth = 'pefromtranstoauth-${locationshortname}${baseName}${env}'
//var transitpdnsznameauth = 'dnszoneauth-${locationshortname}${baseName}${env}'
var transitpdnszgnameauth = 'dnszonegroupauth-${locationshortname}${baseName}${env}'

resource transauthprivateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: transitpenameauth
  location: location
  properties: {
    subnet: {
      id: transplinksubnetid
    }
    privateLinkServiceConnections: [
      {
        name: transitpenameauth
        properties: {
          privateLinkServiceId: adbwsid
          groupIds: [
            'browser_authentication'
          ]
        }
      }
    ]
  }
}

// resource transprivateDnsZoneAuth 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: 'privatelink.azuredatabricks.net'
  
//   location: 'global'
//   dependsOn: [
//     transauthprivateEndpoint
//   ]
// }

// resource privateDnsZoneName_privateDnsZoneName_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   parent: transprivateDnsZone
//   name: '${transitpdnszname}-link'
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: vnetid
//     }
//   }
// }


resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: transitpdnszgname
  parent: transuiprivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: transprivateDnsZone.id
        }
      }
    ]
  }

}

resource pvtEndpointDnsGroupAuth 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: transitpdnszgnameauth
  parent: transauthprivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: transprivateDnsZone.id
        }
      }
    ]
  }

}
