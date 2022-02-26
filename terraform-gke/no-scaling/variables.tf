variable "region" {
  type    = string
  default = "us-east1"
}

variable "project_id" {
  type    = string
  default = ""
}

variable "cluster_name" {
  type    = string
  default = "devops-catalog"
}

variable "node_count" {
  type    = number
  default = 1
}

variable "machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "image_type" {
  type = string
  default = "cos_containerd"
}

variable "preemptible" {
  type    = bool
  default = false
}

variable "billing_account_id" {
  type    = string
  default = ""
}

variable "k8s_version" {
  type = string
}

variable "ingress_nginx" {
  type    = bool
  default = false
}
