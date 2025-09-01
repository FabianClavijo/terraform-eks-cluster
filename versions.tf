terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.112" # ajusta si usas otra versión
    }
  }
}

provider "azurerm" {
  features {}
}