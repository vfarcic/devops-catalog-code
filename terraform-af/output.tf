output "region" {
  value = var.region
}

output "subscription_id" {
  value = data.azurerm_client_config.main.subscription_id
}

output "resource_group" {
  value = azurerm_resource_group.main.name
}