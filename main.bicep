targetScope = 'resourceGroup'

param location string = 'westeurope'

module kv 'modules/keyvault.bicep' = {
  scope: resourceGroup('rg-infr-aks-p-weu-00')
  name: 'Deploy-kv-aks'
  params: {
    location: location
    resourceName: 'kv-infr-aks-p-weu-00'
    workSpaceId: law.outputs.lawID
    vnetName: vnet.outputs.vnetName
    subnetName: 'privateendpoints'
    privateEndpointName: 'pe-kv-infr-aks-p-weu-00'
    vnetId: vnet.outputs.vnetid
  }
}
var subnets = [
  {
    name: 'AzureAKSsubnet'
    ipAddressRange: '10.224.0.0/22'
    routeTable: ''
    networkSecurityGroup: false
    serviceEndpoints: []
  }
   {
    name: 'privateendpoints'
    ipAddressRange: '10.224.10.0/24'
    routeTable: ''
    networkSecurityGroup: false
    serviceEndpoints: []

  } 
]
module vnet 'modules/vnet.bicep' = {
  scope: resourceGroup('rg-infr-aks-p-weu-00')
  name: 'Deploy-vnet-aks'
  params: {
    location: location
    subnets: subnets
    virtualNetworkAddressPrefix: [ '10.224.0.0/16' ]
    vnetName: 'vnet-infr-aks-p-weu-00'
  }
}

module law 'modules/law.bicep' = {
  scope: resourceGroup('rg-infr-aks-p-weu-00')
  name: 'Deploy-vnet-law'
  params: {
    lawName: 'law-infr-aks-p-weu-00'
    location: location
  }
}

module acr 'modules/acr.bicep' = {
  name: 'Deploy-acr-aks'
  params: {
    location: location
    resourceName: 'acrinfrakspweu00'
    workSpaceId: law.outputs.lawID
  }
}

resource aksvnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: vnet.outputs.vnetName
}

resource akssubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  name: 'AzureAKSsubnet'
  parent: aksvnet
}

module aks 'modules/aks.bicep' = {
  name: 'Deploy-aks'
  params: {
    location: location
    containerRegistryId: acr.outputs.resourceId
    lawid: law.outputs.lawID
    vnetSubnetId: akssubnet.id
    apiServerAccessProfile:{
      authorizedIPRanges:[
        '86.81.62.251'
        '62.45.84.93'
      ]
    }
  }
}

module pip 'modules/pip.bicep' = {
  name: 'deploy-pip'
  params: {
    location: location
    pipName: 'pip-infr-1pw-scim-p-weu-00'
  }
}

@description('Specifies the role definition ID used in the role assignment.')
param roleDefinitionID string = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'

@description('Specifies the principal ID assigned to the role.')
param principalIdBas string = '645ad4db-be41-4471-9f34-ae48367f80a6'
param principalIdstijn string = '7e99074c-62cf-474e-948d-9c264a5eb354'


resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalIdBas, roleDefinitionID, resourceGroup().id)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionID)
    principalId: principalIdBas
  }
}

resource roleAssignment2 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalIdstijn, roleDefinitionID, resourceGroup().id)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionID)
    principalId: principalIdstijn
  }
}

