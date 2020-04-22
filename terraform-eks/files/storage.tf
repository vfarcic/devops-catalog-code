resource "aws_s3_bucket" "state" {
  bucket        = "devops-catalog"
  acl           = "private"
  region        = var.region
}

