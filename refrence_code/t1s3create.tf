resource "aws_s3_bucket" "b8520" {
  bucket = "test8520"
  acl    = "public-read"

  tags = {
    Name        = "bucket2580"
  }
}