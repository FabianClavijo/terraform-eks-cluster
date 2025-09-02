targetScope = 'resourceGroup'

@description('Region (defaults to the RG location)')
param location string = resourceGroup().location

@description('Storage Account name (3-24 lowercase/numbers). Empty => auto-generate')
param stgName string = ''

@description('Blob container name for Terraform state')
param containerName string = 'tfstate'

var rgName = resourceGroup().name

// Genera un nombre único si no se pasa (y limita a 24 chars)
var generatedBase = toLower('st${uniqueString(subscription().subscriptionId, rgName)}')
var storageAccountName = empty(stgName)
  ? (length(generatedBase) > 24 ? substring(generatedBase, 0, 15) : generatedBase)
  : toLower(stgName)

resource stg 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    encryption: {
      services: {
        blob: { enabled: true }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
  tags: {
    purpose: 'terraform-backend'
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${stg.name}/default/${containerName}'
  properties: {
    publicAccess: 'None'
  }
}

output outStorageAccount string = stg.name
output outContainer      string = containerName
