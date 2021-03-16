variable "pool_type" {
  type    = string
  default = "g6-standard-2"
}

variable "k8s_version" {
  type = string
}

variable "token" {
  type = string
}

variable "ingress_nginx" {
  type    = bool
  default = false
}

variable "istio" {
  type    = bool
  default = false
}

