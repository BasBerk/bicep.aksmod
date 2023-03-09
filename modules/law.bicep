

@description('The Azure region to deploy the resourece')
param location string

@description('The name for the log analytics workspace')
param lawName string

/* General param and vars */
var commonTags = loadJsonContent('sharedConfig.json')
param additionTags object = {}
var tags = union(commonTags.commonTags, additionTags)


@description('Solution to be supported in this Log Analitics ')
var solutionTypes = [
  'AgentHealthAssessment'
  'AzureActivity'
  'KeyVaultAnalytics'
  'AzureSQLAnalytics'
  'ChangeTracking'
  'DnsAnalytics'
  'NetworkMonitoring'
  'Security'
  'ServiceMap'
  'SQLVulnerabilityAssessment'
  'SQLAdvancedThreatProtection'
  'Updates'
  'VMInsights'
  'ContainerInsights'
]

module LogAnalyticsWorkspace 'br/BicepFeatures:loganalytics:v1.1.0' = {
  name: lawName
  params: {
    customName: lawName
    applicationName: ''
    environmentName: ''
    index: 0
    regionName: ''
    solutionTypes: solutionTypes
    workloadName: ''
    tags: tags
    location: location
    serviceTier: 'PerGB2018'
    subscriptions: []

  }
}


output lawName string = LogAnalyticsWorkspace.outputs.resourceName
output lawID  string = LogAnalyticsWorkspace.outputs.resourceID
output lawWorkspaceId string = LogAnalyticsWorkspace.outputs.workspaceId

