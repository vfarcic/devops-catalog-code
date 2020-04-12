terraform {
  backend "s3" {
    bucket = "devops-catalog"
    key    = "terraform/state"
  }
}
