resource "google_container_cluster" "primary" {
    label       = "devops-catalog"
    k8s_version = var.k8s_version
    region      = "us-east"
    pool {
        type  = var.pool_type
        count = 3
    }
}
