terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.25.2"
    }
  }
}

provider "digitalocean" {}

resource "digitalocean_kubernetes_cluster" "primary" {
  name   = var.name
  region = "nyc1"
  version = var.k8s_version
  node_pool {
    name       = "primary"
    size       = var.pool_size
    auto_scale = true
    min_nodes  = var.min_nodes
    max_nodes  = var.max_nodes
  }
}

resource "null_resource" "ingress-nginx" {
  count = var.ingress_nginx == true ? 1 : 0
  provisioner "local-exec" {
    command = "KUBECONFIG=$PWD/kubeconfig.yaml kubectl apply --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.3.1/deploy/static/provider/cloud/deploy.yaml"
  }
  depends_on = [
    null_resource.kubeconfig,
  ]
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "echo '${digitalocean_kubernetes_cluster.primary.kube_config[0].raw_config}' | tee kubeconfig.yaml"
  }
  depends_on = [
    digitalocean_kubernetes_cluster.primary,
  ]
}

resource "null_resource" "destroy-kubeconfig" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f $PWD/kubeconfig.yaml"
  }
}
