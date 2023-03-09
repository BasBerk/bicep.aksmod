targetScope = 'subscription'
var resourcegroups =[
  'aks'
]

module resourceGroup 'modules/resource-groups.bicep' = [for rg in resourcegroups: {
  name: 'Deploy-rg-${rg}'
  params:{
    applicationName: rg
    environmentName: 'p'
    index: 0
    regionName: 'weu'
    workloadName: 'infr'
  }
}]
