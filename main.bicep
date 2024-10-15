@description('Name of the project, uses azure-iac by default')
param projectName string = 'azure-iac'

@description('Deployment location, uses westeurope by default')
param location string = 'westeurope'

param adminPrincipals array = []

param sqlAdminGroupName string
param sqlAdminGroupId string

var tags = {
  Project: projectName
}

module insightsModule './app-insights.bicep' = {
  name: '${deployment().name}-appInsightsDeploy'
  params: {
    location: location
    projectName: projectName
    tags: tags
  }
}

module web './app-service.bicep' = {
  name: '${deployment().name}-appServiceDeploy'
  params: {
    location: location
    projectName: projectName
    tags: tags
    appInsightsConnectionString: insightsModule.outputs.appInsightsConnectionString
  }
}

module containerApps './container-apps.bicep' = {
  name: '${deployment().name}-containerAppsDeploy'
  params: {
    location: location
    projectName: projectName
    tags: tags
    appInsightsConnectionString: insightsModule.outputs.appInsightsConnectionString
    workspaceName: insightsModule.outputs.workspaceName
  }
}

module sql './sql.bicep' = {
  name: '${deployment().name}-sqlDeploy'
  params: {
    location: location
    projectName: projectName
    tags: tags
    sqlAdminGroupName: sqlAdminGroupName
    sqlAdminGroupId: sqlAdminGroupId
  }
}
