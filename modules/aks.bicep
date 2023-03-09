param vnetSubnetId string

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

param lawid string = ''

var commonTags = loadJsonContent('sharedConfig.json')
param additionTags object = {}
var tags = union(commonTags.commonTags, additionTags)

@description('Optional. Profile for Linux VMs in the container service cluster')
param linuxProfile object = {}

@description('Optional. Profile for Windows VMs in the container service cluster')
param windowsProfile object = {}

@description('Optional. Whether or not to enable the AKS Policy add-on')
param enableAKSPolicy bool = true
param serviceCidr string = ''

@description('Optional. Name of the resource group containing agent pool nodes')
param nodeResourceGroup string = 'rg-infr-aksnodes-p-weu-00'

@description('Optional. Whether to enable Kubernetes pod security policy')
param enablePodSecurityPolicy bool = false

@description('Optional. Profile of Azure Active Directory configuration')
param aadProfile object = {
  managed: true
  enableAzureRbac: true
  adminGroupObjectIDs: [
    'f65ea094-0f7f-4e12-9de9-f7027a4ad604'
  ]
  tenantID: subscription().tenantId
}

@description('Optional. AutoUpgradeProfile')
@allowed([
  'stable'
  'node-image'
  'patch'
  'none'
  'rapid'
])
param upgradeChannel string = 'stable'

@description('Optional. Parameters to be applied to the cluster-autoscaler when enabled')
param autoScalerProfile object = {}

@description('Optional. Profile of managed cluster add-ons')
param addonProfiles object = {
  azureKeyvaultSecretsProvider: {
    enabled: true
    config: {
      enableSecretRotation: 'true'
    }
  }
}

@description('Optional. Access profile for managed cluster API server')
param apiServerAccessProfile object = {
  authorizedIPRanges: [
    '62.45.84.93'
  ]
}

@description('Optional. ResourceId of the disk encryption set to use for enabling encryption at rest')
param diskEncryptionSetId string = ''

@description('Optional. The resource Id of the container registry this cluster should use. Default is `/////` to prevent a bug in the template')
param containerRegistryId string = '/////'

@description('Optional. Location of the resource')
param location string = 'westeurope'

@description('Optional. The humber of days to keep the diagnostic logging')
param diagnosticsRetentionPeriod int = 14

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

// Added Requiered params in this block, no use of seperate paramfile needed
module AzureKubernetesService 'br/BicepFeatures:azurekubernetesservice:v1.2.1' = {

  name: 'AzureKubernetesService-${time}'
  params: {
    applicationName: 'aks'
    environmentName: 'p'
    workloadName: 'alz'
    regionName: 'w'
    index: 1
    customName: customName
    tags: tags
    kubernetesVersion: '1.24.9'
    dnsPrefix: 'aks'  
    agentPools: [
      {
        count: 2
        vmSize: 'Standard_B4ms'
        osDiskSizeGB: 40
        osDiskType: 'Ephemeral'
        vnetSubnetID: vnetSubnetId
        maxPods: 40
        maxCount: 4
        minCount: 2
        enableAutoScaling: true
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        availabilityZones: [ '1', '2', '3' ]
        enableNodePublicIP: false
        tags: tags
        nodeLabels: {}
        nodeTaints: []
        name: 'agtplw2'
      }
    ]
    linuxProfile: linuxProfile
    windowsProfile: windowsProfile
    logAnalyticsWorkspaceId: lawid
    enableAKSPolicy: enableAKSPolicy
    nodeResourceGroup: nodeResourceGroup
    enableRBAC: true
    enablePodSecurityPolicy: enablePodSecurityPolicy
    networkProfile: {

      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
      serviceCidr: '10.224.5.0/24'
      dnsServiceIp: '10.224.5.10'
      dockerBridgeCidr: '172.17.0.1/16'
      networkPlugin: 'azure'
      networkPolicy: 'calico'

    }
    aadProfile: aadProfile
    upgradeChannel: upgradeChannel
    autoScalerProfile: autoScalerProfile
    addonProfiles: addonProfiles

    apiServerAccessProfile: apiServerAccessProfile
    diskEncryptionSetId: diskEncryptionSetId
    containerRegistryId: containerRegistryId
    location: location
    diagnosticsRetentionPeriod: diagnosticsRetentionPeriod
    permissions: [
      {
        name: 'Cluster-Admin-AKS'
        //principalId: 'f3d2c5bb-8a5f-4697-a1b6-f7d967a0f88c' == Stijn
        principalId: 'f65ea094-0f7f-4e12-9de9-f7027a4ad604'
        principalType: 'Group'
        roleDefinitionId: 'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b'
        description: 'Cluster Admin for accessing AKS API'
      }
    ]
  }
}

@description('Name of the resource')
output resourceName string = AzureKubernetesService.outputs.resourceName

@description('ID of the resource')
output resourceID string = AzureKubernetesService.outputs.resourceID


