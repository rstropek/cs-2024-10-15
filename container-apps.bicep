param location string = resourceGroup().location
param projectName string
param tags object
param appInsightsConnectionString string
param workspaceName string

var abbrs = loadJsonContent('abbreviations.json')

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: workspaceName
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: '${abbrs.appManagedEnvironments}${uniqueString(projectName)}'
  location: location
  tags: tags
  properties: {
    daprAIConnectionString: appInsightsConnectionString
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    workloadProfiles: [
      {
        maximumCount: 3
        minimumCount: 1
        name: 'wp${uniqueString(projectName)}'
        workloadProfileType: 'D4'
      }
    ]
  }
}

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: '${abbrs.appContainerApps}${uniqueString(projectName)}'
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      ingress: {
        corsPolicy: {
          allowedHeaders: [
            '*'
          ]
          allowedMethods: [
            '*'
          ]
          allowedOrigins: [
            '*'
          ]
        }
        external: true
        targetPort: 8080
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
    }
    template: {
      revisionSuffix: 'firstrevision'
      containers: [
        {
          name: 'api'
          image: 'rstropek/api'
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}
