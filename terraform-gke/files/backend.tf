terraform {
  backend "gcs" {
    bucket  = "devops-catalog"
    prefix  = "terraform/state"
    credentials = "account.json"
  }
}
