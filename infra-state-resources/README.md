# State Management Module

This module manages the S3 bucket and DynamoDB table required for Terraform remote state storage and locking across all projects in the data-eng-aws infrastructure.

## Overview

The state management module creates:
- S3 bucket for storing Terraform state files
- DynamoDB table for state locking to prevent concurrent modifications
- Proper security configurations (encryption, access policies)
- Versioning and backup capabilities

## Architecture

```
State Management Resources
├── S3 Bucket (tfstates-producer)
│   ├── Versioning enabled
│   ├── Server-side encryption (AES256)
│   ├── Public access blocked
│   └── Secure transport enforced
└── DynamoDB Table (terraform-state-lock)
    ├── Pay-per-request billing
    └── LockID as primary key
```

## Usage

### Deploy State Management Infrastructure First

```bash
cd state
terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

**Important**: This module must be deployed first before any other Terraform projects can use remote state.

### Configuration

The module uses the following key variables:

- `state_bucket_name`: Name of the S3 bucket (default: "tfstates-producer")
- `state_lock_table_name`: Name of the DynamoDB table (default: "terraform-state-lock")
- `aws_region`: AWS region for resources (default: "us-east-1")
- `environment`: Environment name (default: "dev")

### Outputs

The module provides the following outputs:

- `state_bucket_name`: S3 bucket name
- `state_bucket_arn`: S3 bucket ARN
- `state_lock_table_name`: DynamoDB table name
- `state_lock_table_arn`: DynamoDB table ARN
- `backend_config`: Complete backend configuration for other projects

## Integration with Other Projects

All other Terraform projects are configured to use this state management infrastructure:

### Network Project
```hcl
backend "s3" {
  bucket         = "tfstates-producer"
  key            = "data-eng-aws/network/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-state-lock"
  encrypt        = true
}
```

### Infrastructure Project
```hcl
backend "s3" {
  bucket         = "tfstates-producer"
  key            = "data-eng-aws/infra/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-state-lock"
  encrypt        = true
}
```

### Glue Project
```hcl
backend "s3" {
  bucket         = "tfstates-producer"
  key            = "data-eng-aws/glue/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-state-lock"
  encrypt        = true
}
```

## Security Features

- **Encryption**: All state files are encrypted using AES256
- **Access Control**: Public access is completely blocked
- **Secure Transport**: Only HTTPS connections are allowed
- **Versioning**: State file versioning is enabled for backup/recovery
- **Locking**: DynamoDB-based state locking prevents concurrent modifications

## Migration from Local State

If you have existing local state files, you'll need to migrate them:

1. **Deploy state management infrastructure first**
2. **For each project with local state**:
   ```bash
   cd <project-directory>
   terraform init
   terraform plan  # Verify the plan
   terraform apply
   ```

3. **Remove local state files** (after successful migration):
   ```bash
   rm terraform.tfstate*
   ```

## State File Organization

State files are organized by project:
- `data-eng-aws/state/terraform.tfstate` - State management resources
- `data-eng-aws/network/terraform.tfstate` - Network infrastructure
- `data-eng-aws/infra/terraform.tfstate` - Application infrastructure
- `data-eng-aws/glue/terraform.tfstate` - Glue jobs and resources

## Benefits

- **Centralized State Management**: All state files in one secure location
- **State Locking**: Prevents concurrent modifications and state corruption
- **Backup and Recovery**: Versioning enables state file recovery
- **Security**: Encrypted storage with restricted access
- **Team Collaboration**: Multiple team members can work safely
- **Audit Trail**: S3 access logs provide state file access history
