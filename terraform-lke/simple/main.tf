provider "linode" {
  token = var.token
}

resource "linode_lke_cluster" "primary" {
    label       = "devops-catalog"
    k8s_version = var.k8s_version
    region      = "us-east"
    pool {
        type  = var.pool_type
        count = 3
    }
}
