output "cluster_name" {
  value = var.cluster_name
}

output "region" {
  value = var.region
}

output "resource_group" {
  value = azurerm_resource_group.main.name
}
