terraform {
  required_providers {
    azuread = ">= 2.9.0"
    azurerm = ">= 3.0.0"
  }
}

provider "azurerm" {
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}