terraform {
  backend "azurerm" {
    resource_group_name  = "devops-catalog-aks"
    storage_account_name = "devopscatalog"
    container_name       = "devopscatalog"
    key                  = "terraform.tfstate"
  }
}
