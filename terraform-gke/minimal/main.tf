provider "google" {
  credentials = file("account.json")
  project     = var.project_id
  region      = var.region
}

terraform {
  backend "gcs" {
    bucket      = "devops-catalog"
    prefix      = "terraform/state"
    credentials = "account.json"
  }
}

resource "google_container_cluster" "primary" {
  name                     = var.cluster_name
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version       = var.k8s_version
  
  resource_labels          = {
    environment            = "development"
    created-by             = "terraform"
    owner                  = "vfarcic"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name               = var.cluster_name
  location           = var.region
  cluster            = google_container_cluster.primary.name
  version            = var.k8s_version
  initial_node_count = var.min_node_count
  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  autoscaling { 
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
  management {
    auto_upgrade = false
  }
  timeouts {
    create = "15m"
    update = "1h"
  }
}

resource "google_storage_bucket" "state" {
  name          = var.state_bucket
  # location      = var.region
  project       = var.project_id
  storage_class = "NEARLINE"
  labels        = {
    environment = "development"
    created-by  = "terraform"
    owner       = "vfarcic"
  }
}
