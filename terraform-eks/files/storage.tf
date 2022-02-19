resource "aws_s3_bucket" "state" {
  bucket        = var.state_bucket
}

resource "aws_s3_bucket_acl" "acl" {
  bucket    = aws_s3_bucket.state.id
  acl       = "private"
}