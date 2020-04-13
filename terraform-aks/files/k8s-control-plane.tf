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
