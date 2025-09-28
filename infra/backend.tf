# S3 Backend Configuration
terraform {
  backend "s3" {
    bucket         = "tfstates-producer"
    key            = "data-eng-aws/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
