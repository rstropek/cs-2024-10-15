param location string = resourceGroup().location
param projectName string
param tags object
param appInsightsConnectionString string
param sqlServerName string
param databaseName string

var abbrs = loadJsonContent('abbreviations.json')

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${abbrs.webServerFarms}${uniqueString(projectName)}'
  location: location
  tags: tags
  sku: {
    name: 'P0v3'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true // Required for Linux
  }
}

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: '${abbrs.webSitesAppService}${uniqueString(projectName)}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    publicNetworkAccess: 'Enabled'
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|rstropek/hellocontainerapps:v4'
      alwaysOn: true
      cors: {
        allowedOrigins: ['*']
      }
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }

  resource settings 'config@2023-01-01' = {
    name: 'appsettings'
    properties: {
      DOCKER_REGISTRY_SERVER_URL: 'https://index.docker.io'
      PORT: '8080'
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
      ConnectionStrings__Database: 'Server=tcp:${sqlServerName}${environment().suffixes.sqlServerHostname};Database=demo;Authentication=Active Directory Managed Identity; Encrypt=True;'
    }
  }
}

output managedIdentityPrincipalId string = webApp.identity.principalId
