output "cluster_name" {
  value = var.cluster_name
}

output "region" {
  value = var.region
}

output "resource_group" {
  value = azurerm_resource_group.main.name
}

output "registry_server" {
  value = azurerm_container_registry.main.login_server
}

output "registry_name" {
  value = azurerm_container_registry.main.name
}