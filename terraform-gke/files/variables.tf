variable "region" {
  type    = string
  default = "us-east1"
}

variable "project_id" {
  type    = string
  default = "devops-catalog-project"
}

variable "cluster_name" {
  type    = string
  default = "devops-catalog"
}

variable "k8s_version" {
  type = string
}

variable "min_node_count" {
  type    = number
  default = 1
}

variable "max_node_count" {
  type    = number
  default = 3
}

variable "machine_type" {
  type    = string
  default = "n1-standard-1"
}

variable "preemptible" {
  type    = bool
  default = true
}
