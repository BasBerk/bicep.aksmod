
/* General param and vars */

@description('The Azure region to deploy the resourece')
param location string

@description('The workspace ID for the diagnostic settings.')
param workSpaceId string = ''

/* General param and vars */
var commonTags = loadJsonContent('sharedConfig.json')
param additionTags object = {}
var tags = union(commonTags.commonTags, additionTags)

@description('The name of the resource "Storageaccount"')
param resourceName string

module AzureContainerRegistry 'br/BicepFeatures:azurecontainerregistry:v1.3.0' = {

  name: 'AzureContainerRegistry'
  params: {
    applicationName: ''
    environmentName: ''
    index: 0
    regionName: ''
    workloadName:'' 
    customName: resourceName
    tags:tags
    acrSku: 'Basic'
    location: location
    acrAdminUserEnabled:false
    diagnosticSettings: (empty(workSpaceId)) ? [] :  [
      {
        name: 'Diag2Law'
        workspaceId: workSpaceId
        logs: [
          {
            categoryGroup: 'allLogs'
            enabled: true
          }
        ]
        metrics:[
          {
            category: 'AllMetrics'
            enabled: true
          }
        ]

      }
    ]
  }
}

output resourceId string = AzureContainerRegistry.outputs.resourceID
