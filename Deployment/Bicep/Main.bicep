// Here is some useful documentation:
//
// - https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep
//      This is a link to  Bicep's documentation.  Bicep is a domain-specific 
//      language for deploying Azure resources.  It's built on top of Azure Resource Manager 
//      (ARM).
//
// - https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview
//      This is a link to Azure Resource Manager's documentation.  

targetScope = 'subscription'

@allowed([
  // Development environment
  'Development'

  // Production environment
  'Production'
])
param environment string = 'Development'

var regionName = 'West US 2'
var regionShortName = 'usw2'

var environmentNameToEnvironmentSettingsMap = {
  Development: {
    environmentShortName: 'dev'
  }

  Production: {
    environmentShortName: 'prod'
  }
}

var intermediateEnvironmentSettings = environmentNameToEnvironmentSettingsMap[environment]

// These settings are shared by all environments
var commonEnvironmentSettings = {
  standardResourcePrefix: 'goals-${intermediateEnvironmentSettings.environmentShortName}-${regionShortName}'
  regionName: regionName
  regionShortName: regionShortName
}

var environmentSettings = union(commonEnvironmentSettings, intermediateEnvironmentSettings)

//
// Create Resource Groups
//
resource webSiteResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${environmentSettings.standardResourcePrefix}-rg-web-site'
  location: environmentSettings.regionName
}

//
// Deploy Resources
//

module deployWebSite './WebSite.bicep' = {
  name: 'DeployWebSite'
  scope: webSiteResourceGroup
  params: {
    environmentSettings: environmentSettings
  }
}
