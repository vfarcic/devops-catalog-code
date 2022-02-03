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

resource "google_service_account" "main" {
  project      = google_project.main.project_id
  account_id   = google_project.main.project_id
  display_name = "devops-catalog"
}

resource "google_service_account_key" "main" {
  service_account_id = google_service_account.main.name
}

resource "local_file" "account" {
    content  = base64decode(google_service_account_key.main.private_key)
    filename = "account.json"
}

resource "google_service_account_iam_policy" "admin-account-iam" {
  service_account_id = google_service_account.main.name
  policy_data        = data.google_iam_policy.main.policy_data
}

resource "google_project_service" "cloudfunctions" {
  project = google_project.main.project_id
  service = "cloudfunctions.googleapis.com"
}

resource "google_project_service" "cloudbuild" {
  project = google_project.main.project_id
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "storage-api" {
  project = google_project.main.project_id
  service = "storage-api.googleapis.com"
  depends_on = [google_project_service.cloudfunctions]
}

resource "google_project_service" "storage-component" {
  project = google_project.main.project_id
  service = "storage-component.googleapis.com"
  depends_on = [google_project_service.cloudfunctions]
}

resource "google_project_service" "logging" {
  project = google_project.main.project_id
  service = "logging.googleapis.com"
  depends_on = [google_project_service.cloudfunctions]
}

resource "google_project_service" "deploymentmanager" {
  project = google_project.main.project_id
  service = "deploymentmanager.googleapis.com"
}

data "google_iam_policy" "main" {
  binding {
    role = "roles/owner"
    members = [
      "serviceAccount:${google_service_account.main.email}",
    ]
  }
}
