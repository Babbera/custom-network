resource "aws_s3_bucket" "my_bucket" {
  bucket = "state.backend"
  acl    = "private"  # Define the access control list for the bucket

  tags = {
    Name        = "MyBucket"
    Environment = "Dev"
  }
}