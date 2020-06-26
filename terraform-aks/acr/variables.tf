variable "region" {
  type    = string
  default = "eastus"
}

variable "resource_group" {
  type    = string
  default = ""
}

variable "cluster_name" {
  type    = string
  default = "docatalog"
}

variable "dns_prefix" {
  type    = string
  default = ""
}

# Get the version with `az aks get-versions --location eastus`
variable "k8s_version" {
  type = string
}

variable "min_node_count" {
  type    = number
  default = 3
}

variable "max_node_count" {
  type    = number
  default = 9
}

variable "machine_type" {
  type    = string
  default = "Standard_A2_v2"
}

variable "container_registry_name" {
  type    = string
  default = ""
}
