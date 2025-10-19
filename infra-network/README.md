# Network Module

This module manages the VPC and networking infrastructure for the data-eng-aws project.

## Overview

The network module creates:
- VPC with configurable CIDR block
- Public and private subnets across multiple availability zones
- NAT Gateway for private subnet internet access
- Internet Gateway for public subnets
- VPC Flow Logs for monitoring
- Proper subnet tagging for EKS integration

## Architecture

```
VPC (10.0.0.0/16)
├── Public Subnets (10.0.101.0/24, 10.0.102.0/24, 10.0.103.0/24)
│   ├── Internet Gateway
│   └── NAT Gateway
└── Private Subnets (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24)
    └── Route to NAT Gateway
```

## Usage

### Deploy Network Infrastructure

```bash
cd network
terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

### Configuration

The module uses the following key variables:

- `vpc_cidr`: CIDR block for the VPC (default: "10.0.0.0/16")
- `availability_zones`: List of AZs to use (default: ["us-east-1a", "us-east-1b", "us-east-1c"])
- `private_subnet_cidrs`: CIDR blocks for private subnets
- `public_subnet_cidrs`: CIDR blocks for public subnets
- `enable_nat_gateway`: Enable NAT Gateway (default: true)
- `enable_flow_logs`: Enable VPC Flow Logs (default: true)

### Outputs

The module provides the following outputs for other modules to consume:

- `vpc_id`: VPC ID
- `vpc_cidr_block`: VPC CIDR block
- `private_subnets`: List of private subnet IDs
- `public_subnets`: List of public subnet IDs
- `nat_gateway_ids`: NAT Gateway IDs
- `igw_id`: Internet Gateway ID

## Integration with Other Modules

This network module is designed to be consumed by other Terraform modules using remote state:

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket         = "tfstates-producer"
    key            = "data-eng-aws/network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

# Use network outputs
vpc_id = data.terraform_remote_state.network.outputs.vpc_id
subnet_ids = data.terraform_remote_state.network.outputs.private_subnets
```

## Migration from Infra Module

This module was extracted from the main infrastructure module to provide better separation of concerns and enable independent management of networking resources.

### Changes Made:
1. VPC module moved from `infra/` to `network/`
2. VPC-related variables moved to network module
3. Infra module now references network outputs via remote state
4. Separate Terraform state for network resources

### Benefits:
- Independent network management
- Better resource organization
- Reduced blast radius for network changes
- Clearer separation of concerns
