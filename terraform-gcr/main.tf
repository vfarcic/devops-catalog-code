resource "random_string" "main" {
  length  = 16
  special = false
  upper   = false
}

data "google_billing_account" "main" {
  display_name = "My Billing Account"
  open         = true
}

resource "google_project" "main" {
  name            = "doc-serverless"
  project_id      = var.project_id != "" ? var.project_id : "doc-${random_string.main.result}"
  billing_account = var.billing_account_id != "" ? var.billing_account_id : data.google_billing_account.main.id
}

resource "google_project_service" "container_registry" {
  project = google_project.main.project_id
  service = "containerregistry.googleapis.com"
  depends_on = [google_project_service.cloud_run]
}

resource "google_project_service" "cloud_run" {
  project = google_project.main.project_id
  service = "run.googleapis.com"
}
