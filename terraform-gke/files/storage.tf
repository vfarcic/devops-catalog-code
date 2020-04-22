resource "google_storage_bucket" "state" {
  name          = "devops-catalog"
  location      = var.region
  project       = var.project_id
  storage_class = "NEARLINE"
  labels        = {
    environment = "development"
    created-by  = "terraform"
    owner       = "vfarcic"
  }
}
