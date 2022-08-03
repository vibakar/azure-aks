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
  subscription_id = var.AUTH.SUBSCRIPTION_ID
  client_id       = var.AUTH.CLIENT_ID
  client_secret   = var.AUTH.CLIENT_SECRET
  tenant_id       = var.AUTH.TENANT_ID
}