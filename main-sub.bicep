targetScope = 'subscription'

@description('Resource Group name')
param rgName string

@description('Region for RG and storage')
param location string = 'eastus2'

@description('Storage Account name (empty => auto-generate in module)')
param stgName string = ''

@description('Blob container name')
param containerName string = 'tfstate'

// Crea el RG
resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: location
}

// Despliega el módulo dentro del RG (scope en el MÓDULO)
module stgMod './stg-rg-scope.bicep' = {
  name: 'tfBackendStorage'
  scope: rg
  params: {
    location: location
    stgName: stgName
    containerName: containerName
  }
}

output outResourceGroup  string = rg.name
output outStorageAccount string = stgMod.outputs.outStorageAccount
output outContainer      string = stgMod.outputs.outContainer
