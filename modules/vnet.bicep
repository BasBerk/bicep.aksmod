
@description('The Azure region to deploy the resourece')
param location string

@description('The workspace ID for the diagnostic settings.')
param workSpaceId string = ''

/* General param and vars */
var commonTags = loadJsonContent('sharedConfig.json')
param additionTags object = {}
var tags = union(commonTags.commonTags, additionTags)

@description('Nane of the vnet')
param vnetName string

@description('The name and IP address range for each subnet in the virtual networks.')
param subnets array

@description('The IP address range for all virtual networks to use.')
param virtualNetworkAddressPrefix array

var subnetProperties = [for subnet in subnets: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.ipAddressRange
  }
}]

module vnet 'br/BicepFeatures:virtualnetwork:v2.1.0' = {
  
  name: vnetName
  params: {
    applicationName: ''
    environmentName: ''
    index: 0
    regionName: ''
    vNetPrefix: virtualNetworkAddressPrefix
    workloadName: ''
    customName: vnetName
    location: location
    subnets: subnetProperties
    vNetDnsServers: []
    diagnosticSettings: (empty(workSpaceId)) ? [] : [
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
    tags: tags
  }
}

output vnetid string = vnet.outputs.resourceID
output vnetName string = vnet.outputs.resourceName

