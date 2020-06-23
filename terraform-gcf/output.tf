output "project_id" {
  value = google_project.main.project_id
}

output "region" {
  value = var.region
}

output "sa_email" {
  value = google_service_account.main.email
}