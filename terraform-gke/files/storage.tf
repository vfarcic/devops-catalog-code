resource "google_storage_bucket" "state" {
  name          = "devops-catalog"
  location      = var.region
  force_destroy = true
  project       = var.project_id
  storage_class = "NEARLINE"
  labels        = {
    environment = "development"
    created-by  = "terraform"
    owner       = "vfarcic"
  }
}
