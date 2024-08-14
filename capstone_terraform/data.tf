data "azurerm_kubernetes_service_versions" "current" {
  location        = var.region
  include_preview = false
}

data "azuread_client_config" "current" {}
