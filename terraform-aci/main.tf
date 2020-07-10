provider "azurerm" {
  features {}
}

resource "random_string" "main" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group != "" ? var.resource_group : "${random_string.main.result}"
  location = var.region
}

resource "azurerm_container_registry" "main" {
  name                = var.registry_name != "" ? var.registry_name : "${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Premium"
  admin_enabled       = true
}

data "azurerm_client_config" "main" { }