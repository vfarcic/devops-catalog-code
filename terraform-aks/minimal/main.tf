resource "azurerm_kubernetes_cluster" "primary" {
  name                = var.cluster_name
  location            = var.region
  resource_group_name = var.resource_group
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.k8s_version
  default_node_pool {
    name                = var.cluster_name
    vm_size             = var.machine_type
    enable_auto_scaling = true
    max_count           = var.max_node_count
    min_count           = var.min_node_count
  }
  identity {
    type = "SystemAssigned"
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_storage_account" "state" {
  name                     = "devopscatalog"
  resource_group_name      = var.resource_group
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "state" {
  name                  = "devopscatalog"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "blob"
}

