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

data "azurerm_client_config" "main" { }