param projectName string
param location string = resourceGroup().location
param tags object

var abbrs = loadJsonContent('abbreviations.json')

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${abbrs.operationalInsightsWorkspaces}${uniqueString(projectName)}'
  location: location
  tags: tags
  properties: {
    // Consider turning off public network access for ingestion if not needed.
    // Depends on the project's requirements.
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: 30
    features: {
      disableLocalAuth: false
      enableDataExport: false
    }
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${abbrs.insightsComponents}${uniqueString(projectName)}'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    DisableIpMasking: false // Change this setting according to your GDPR requirements
    WorkspaceResourceId: logAnalytics.id
  }
}

output appInsightsConnectionString string = appInsights.properties.ConnectionString
output workspaceName string = logAnalytics.name
