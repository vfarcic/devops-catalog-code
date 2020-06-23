variable "desired_count" {
  type    = number
  default = 1
}

variable "memory" {
  type    = string
  default = "512"
}

variable "cpu" {
  type    = string
  default = "256"
}

variable "port" {
  type    = number
  default = 80
}

variable "lb_arn" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "cluster_id" {
  type = string
}
