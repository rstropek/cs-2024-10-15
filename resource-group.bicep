targetScope = 'subscription'

@description('Name of the project, uses azure-iac by default')
param projectName string = 'azure-iac'

@description('Location of the resources, uses westeurope by default')
param location string = 'westeurope'

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: projectName
  location: location
  tags: {
    Project: projectName
  }
}

output rgName string = rg.name
