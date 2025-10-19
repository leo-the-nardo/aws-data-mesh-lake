# State Management Configuration for Development Environment

# AWS Configuration
aws_region = "us-east-1"

# Environment
environment = "dev"
project_name = "aws-data-mesh-lake"

# GitHub Configuration
github_owner = "leo-the-nardo"
github_repo = "aws-data-mesh-lake"

# State Resources Configuration
state_bucket_name = "tfstates-aws-data-mesh-lake"
state_lock_table_name = "terraform-state-lock-aws-data-mesh-lake"

# Tags
tags = {
  Environment = "dev"
  Project     = "aws-data-mesh-lake"
  Module      = "state"
  Owner       = "data-team"
  CostCenter  = "engineering"
}
