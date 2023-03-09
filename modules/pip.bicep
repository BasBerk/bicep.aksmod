// this pip is for the scrim bridge load balancer
param pipName string 
var commonTags = loadJsonContent('sharedConfig.json')
param additionTags object = {}
var tags = union(commonTags.commonTags, additionTags)

param location string
module pip 'br/BicepFeatures:publicip:v1.1.0' = {
  name: 'pip'
  params: {
    applicationName: ''
    environmentName: ''
    index: 0
    regionName: ''
    workloadName: ''
    customName:pipName
    location: location
    publicIPAddressVersion: 'IPv4'
    tags:tags
    publicIPAllocationMethod: 'Static'
    publicIPSku: 'Standard'
    
  }
}
