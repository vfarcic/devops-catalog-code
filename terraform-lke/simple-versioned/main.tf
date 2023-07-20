terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "2.5.2"
    }
  }
}

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

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "echo ${linode_lke_cluster.primary.kubeconfig} | base64 --decode | tee kubeconfig"
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    linode_lke_cluster.primary,
  ]
}

resource "null_resource" "destroy-kubeconfig" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f $PWD/kubeconfig"
  }
}

