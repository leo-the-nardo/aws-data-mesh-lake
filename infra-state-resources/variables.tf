variable "aws_region" {
  description = "AWS region for state resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "data-eng-aws"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "tfstates-producer"
}

variable "state_lock_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-lock"
}

variable "github_owner" {
  description = "GitHub repository owner (username or organization)"
  type        = string
  default     = "leo-the-nardo"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "aws-data-mesh-lake"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "data-eng-aws"
    Module      = "state"
    Owner       = "data-team"
    CostCenter  = "engineering"
  }
}
