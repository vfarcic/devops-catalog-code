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

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.region
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.dns_prefix != "" ? var.dns_prefix : "${random_string.main.result}"
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

resource "azurerm_container_registry" "main" {
  name                = var.container_registry_name != "" ? var.container_registry_name : "${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name
  admin_enabled       = true
  location            = var.region
  sku                 = "Premium"
}

resource "azurerm_role_assignment" "acrpull_role" {
  scope                            = azurerm_container_registry.main.id
  role_definition_name             = "AcrPull"
  principal_id                     = azuread_service_principal.main.object_id
  depends_on = [
    azurerm_container_registry.main,
    azuread_application.main
  ]
}

# resource "azurerm_role_assignment" "acrpull_role" {
#   scope                            = "${data.azurerm_subscription.main.id}/resourceGroups/${azurerm_resource_group.main.name}"
#   role_definition_name             = "AcrPull"
#   principal_id                     = "${azuread_service_principal.server.id}"
#   skip_service_principal_aad_check = true
# }

resource "azuread_application" "main" {
  name = azurerm_kubernetes_cluster.main.name
}

# resource "azurerm_role_assignment" "acrpull_role" {
#   scope                            = data.azurerm_subscription.main.id
#   role_definition_name             = "AcrPull"
#   principal_id                     = azurerm_kubernetes_cluster.main.identity.0.principal_id
#   skip_service_principal_aad_check = true
# }

resource "azuread_service_principal" "main" {
  application_id               = azuread_application.main.application_id
  app_role_assignment_required = false
}

data "azurerm_subscription" "main" { }

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "KUBECONFIG=$PWD/kubeconfig az aks get-credentials --name ${var.cluster_name} --resource-group ${azurerm_resource_group.main.name} --file $PWD/kubeconfig"
  }
  depends_on = [
    azurerm_kubernetes_cluster.main,
  ]
}

resource "null_resource" "destroy-kubeconfig" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f $PWD/kubeconfig"
  }
}
