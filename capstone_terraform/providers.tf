terraform {
  required_providers {
    azuread = ">= 2.9.0"
    azurerm = ">= 3.0.0"
  }
}

provider "azurerm" {
  features {}
}