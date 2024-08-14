// Here is some useful documentation:
//
// - https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep
//      This is a link to  Bicep's documentation.  Bicep is a domain-specific 
//      language for deploying Azure resources.  It's built on top of Azure Resource Manager 
//      (ARM).
//
// - https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview
//      This is a link to Azure Resource Manager's documentation.  

targetScope = 'resourceGroup'

@allowed([
  // Development environment
  'dev'

  // Production environment
  'prod'
])
param environment string = 'dev'
param location string = resourceGroup().location

var staticWebSiteName = '$goals-{environment}-web-site'


resource staticWebSite 'Microsoft.Web/staticSites@2022-03-01' = {
  name: staticWebSiteName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  kind: 'string'
  identity: {
    type: 'string'
    userAssignedIdentities: {}
  }
  properties: {
    provider: 'GitHub'
   
    repositoryUrl: 'https://github.com/BenjaminEllett/Goals'    
    branch: 'main'

    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true

    enterpriseGradeCdnStatus: 'Disabled'

    buildProperties: {
      apiBuildCommand: 'string'
      apiLocation: 'string'
      appArtifactLocation: 'string'
      appBuildCommand: 'string'
      appLocation: 'string'
      githubActionSecretNameOverride: 'string'
      outputLocation: 'string'
      skipGithubActionWorkflowGeneration: true
    }

    publicNetworkAccess: 'string'
    repositoryToken: 'string'

    templateProperties: {
      description: 'string'
      isPrivate: bool
      owner: 'string'
      repositoryName: 'string'
      templateRepositoryUrl: 'string'
    }
  }
}
