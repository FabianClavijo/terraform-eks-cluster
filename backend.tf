# Usa Azure Storage como backend remoto para el estado de Terraform.
# Requiere que ya exista el Storage Account y el contenedor "tfstate".
# Puedes parametrizar estos valores vía variables de entorno al ejecutar `terraform init`:
#   export ARM_ACCESS_KEY="<storage_account_key>"
# O usar "azurerm" con Managed Identity/az login (recomendado).

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstates"           # <-- cambia por tu RG de estados
    storage_account_name = "sttfdemoxxxxx"         # <-- cambia por tu Storage Account
    container_name       = "tfstate"               # contenedor (blob) para estados
    key                  = "aks-demo/terraform.tfstate"
  }
}
