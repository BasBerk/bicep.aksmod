/* General param and vars */

@description('The Azure region to deploy the resource')
param location string

@description('The workspace ID for the diagnostic settings.')
param workSpaceId string = ''

/* General param and vars */
var commonTags = loadJsonContent('sharedConfig.json')
param additionTags object = {}
var tags = union(commonTags.commonTags, additionTags)

@description('The name of the resource "Key Vault"')
param resourceName string

@description('the vnet used for the private endpoint')
param vnetName string = ''

param vnetId string = ''

param subnetName string = ''

param privateEndpointName string = ''

module KeyVault 'br/BicepFeatures:keyvault:v1.3.0' = {
  name: 'KeyVault'
  params: {
    accessPolicies: []
    applicationName: ''
    environmentName: ''
    regionName: ''
    workloadName: ''
    customName: resourceName
    defaultAction: 'Deny'
    diagnosticsSettings: (empty(workSpaceId)) ? [] : [
      {
        name: 'Diag2Law'
        workspaceId: workSpaceId
        logs: [
          {
            categoryGroup: 'allLogs'
            enabled: true
          }
        ]
        metrics: [
          {
            category: 'AllMetrics'
            enabled: true
          }
        ]
      }
    ]
    location: location
    tags: tags
  }
}
output saId string = KeyVault.outputs.resourceID

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: KeyVault.outputs.resourceID
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }

}
/*var privateDnsZoneName = 'privatelink${environment().suffixes.keyvaultDns}'
 var pvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}

}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${privateDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privateEndpoint-dnsConfig'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

/* resource arecord 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
  parent: privateDnsZone
  name: '${privateEndpointName}.${privateDnsZoneName}'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: privateEndpoint.properties.ipConfigurations[0].properties.privateIPAddress
      }

    ]
  }
  dependsOn: [
    pvtEndpointDnsGroup
  ]
}

 */
