provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "eks-backend" {
  bucket = "quiz-app-eks-state-bucket"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name         = "quiz-app-eks-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }


}
