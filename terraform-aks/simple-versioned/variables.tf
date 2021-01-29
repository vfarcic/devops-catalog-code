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
  default = "docatalog"
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
  default = "Standard_D2_v2"
}

variable "ingress_nginx" {
  type    = bool
  default = false
}

variable "istio" {
  type    = bool
  default = false
}

variable "k8s_version" {
  type    = string
}

