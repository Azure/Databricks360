param baseName string
param env string = 'dev'
param location string = resourceGroup().location
param withVm bool = true
param subnetid string
param adminuser string = 'tdadmin'
@secure()
param pw string

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = if(withVm) {
  name: '${baseName}${env}-transvm'
  location: location

  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS2_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }

    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    osProfile: {
      computerName: 'vm${baseName}'
      adminUsername: adminuser
      adminPassword: pw
    }
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${baseName}${env}-transnic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetid
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${baseName}${env}-transpublicip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
}
