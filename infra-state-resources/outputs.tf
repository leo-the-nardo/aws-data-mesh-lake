# S3 bucket outputs
output "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "state_bucket_domain_name" {
  description = "Domain name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket_domain_name
}

# DynamoDB table outputs
output "state_lock_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

output "state_lock_table_arn" {
  description = "ARN of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_state_lock.arn
}

# Backend configuration for other projects
output "backend_config" {
  description = "Backend configuration for other Terraform projects"
  value = {
    bucket         = aws_s3_bucket.terraform_state.bucket
    region         = var.aws_region
    dynamodb_table = aws_dynamodb_table.terraform_state_lock.name
    encrypt        = true
  }
}