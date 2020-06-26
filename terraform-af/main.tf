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

# resource "azurerm_storage_account" "main" {
#   name                     = "docserverless"
#   resource_group_name      = azurerm_resource_group.main.name
#   location                 = var.region
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
#   account_kind             = "Storage"
# }

data "azurerm_client_config" "main" { }