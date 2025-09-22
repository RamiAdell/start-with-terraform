# resource "aws_s3_bucket" "backend_bucket" {
#   bucket = "my-unique-terraform-backend-bucket-987654321"
#   lifecycle {
#     prevent_destroy = false
#   }
# }

# resource "aws_s3_bucket_versioning" "backend_bucket_versioning" {
#   bucket = aws_s3_bucket.backend_bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
# resource "aws_dynamodb_table" "terraform_state" {
#   name         = "terraform-state-rami"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }
terraform {
  backend "s3" {
    bucket = "my-unique-terraform-backend-bucket-987654321"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"
  }
}