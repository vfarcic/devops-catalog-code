resource "aws_s3_bucket" "state" {
  bucket        = var.state_bucket
  acl           = "private"
}

