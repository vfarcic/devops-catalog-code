resource "aws_s3_bucket" "state" {
  bucket        = "devops-catalog"
  acl           = "private"
  force_destroy = false
  region        = var.region
}

