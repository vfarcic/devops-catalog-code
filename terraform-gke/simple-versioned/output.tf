output "cluster_name" {
  value = var.cluster_name
}

output "region" {
  value = var.region
}

output "project_id" {
  value = google_project.main.project_id
}