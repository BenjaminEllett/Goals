param environmentSettings object

// https://learn.microsoft.com/en-us/azure/templates/microsoft.web/staticsites?pivots=deployment-language-bicep
resource webSite 'Microsoft.Web/staticSites@2023-12-01' = {
  name: '${environmentSettings.standardResourcePrefix}-swa-web-site'
  location: environmentSettings.regionName
  sku: {
    name: 'Free'
    tier: 'Free'
  }

  properties: {
    provider: 'GitHub'
    repositoryUrl: 'https://github.com/BenjaminEllett/Goals'
    branch: 'main'

    publicNetworkAccess: 'Enabled'

    allowConfigFileUpdates: true
    stagingEnvironmentPolicy: 'Disabled'
    enterpriseGradeCdnStatus: 'Disabled'
  }

  resource webSiteBasicAuth 'basicAuth@2023-12-01' = {
    name: 'default'
    properties: {
      applicableEnvironmentsMode: 'SpecifiedEnvironments'
    }
  }
}
