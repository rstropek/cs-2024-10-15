param location string = resourceGroup().location
param projectName string
param tags object
param sqlAdminGroupName string
param sqlAdminGroupId string

var abbrs = loadJsonContent('abbreviations.json')

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: '${abbrs.sqlServers}${uniqueString(projectName)}'
  location: location
  tags: tags
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true // We only allow Entra authentication
      principalType: 'Group'
      tenantId: subscription().tenantId
      login: sqlAdminGroupName
      sid: sqlAdminGroupId
    }
    minimalTlsVersion: '1.2'
  }

  resource firewallRuleAzureInternal 'firewallRules@2022-05-01-preview' = {
    name: 'AzureInternal'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }

  resource firewallRule 'firewallRules@2022-05-01-preview' = {
    name: 'AllowAll'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '255.255.255.255'
    }
  }

  resource database 'databases@2022-05-01-preview' = {
    name: 'demo'
    location: location
    tags: tags
    sku: {
      name: 'GP_S_Gen5_1'
      tier: 'GeneralPurpose'
      family: 'Gen5'
      capacity: 1
    }
    properties: {
      collation: 'SQL_Latin1_General_CP1_CI_AS'
      catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
      zoneRedundant: false
      readScale: 'Disabled'
    }
  }
}

/*
# Don't forget to create users in DB
CREATE USER [$APP_SERVICE_NAME] FROM EXTERNAL PROVIDER
EXEC sp_addrolemember 'db_owner', [$APP_SERVICE_NAME]
*/

output sqlServerName string = sqlServer.name
output databaseName string = 'demo'
