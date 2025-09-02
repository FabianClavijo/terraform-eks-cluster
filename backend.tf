# Usa Azure Storage como backend remoto para el estado de Terraform.
# Requiere que ya exista el Storage Account y el contenedor "tfstate".
# Puedes parametrizar estos valores vía variables de entorno al ejecutar `terraform init`:
#   export ARM_ACCESS_KEY="<storage_account_key>"
# O usar "azurerm" con Managed Identity/az login (recomendado).
terraform {
  backend "azurerm" {
    subscription_id      = "<MY_AZURE_SUBSCRIPTION_ID>"
    resource_group_name  = "rg-tfstates"
    storage_account_name = "sttfdemodev001"
    container_name       = "tfstate"
    key                  = "aks-demo/terraform.tfstate"
    use_azuread_auth     = true
  }
}
