targetScope = 'subscription'

@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. The region this resource will be deployed in')
@maxLength(4)
param regionName string

@description('Required. Index of the resource')
param index int

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. The name of the region where the resource group will be deployed.')
param location string = 'West Europe'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')


module ResourceGroup 'br/BicepFeatures:resourcegroup:v1.1.0' = {
  name: 'ResourceGroup-${time}'
  params: {
    workloadName: workloadName
    applicationName: applicationName
    environmentName: environmentName
    regionName: regionName
    index: index
    customName: customName
    tags: tags
    location: location
  }
}

