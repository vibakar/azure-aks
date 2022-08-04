terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.16.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.auth.subscription_id
  client_id       = var.auth.client_id
  client_secret   = var.auth.client_secret
  tenant_id       = var.auth.tenant_id
}