resource "azurerm_kubernetes_cluster_node_pool" "secondary" {
  name                  = "${var.cluster_name}2"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.primary.id
  vm_size               = var.machine_type
  enable_auto_scaling   = true
  max_count             = var.max_node_count
  min_count             = var.min_node_count
}
