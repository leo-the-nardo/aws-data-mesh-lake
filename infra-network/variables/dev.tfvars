# Network Configuration for Development Environment

# AWS Configuration
aws_region = "us-east-1"

# VPC Configuration
vpc_name = "dev-vpc"
vpc_cidr = "10.0.0.0/16"

# Cost Optimization: Reduce to 2 AZs instead of 3
availability_zones = ["us-east-1a", "us-east-1b"]

# Subnet Configuration (updated for 2 AZs)
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]

# Gateway Configuration - Ultra Cost Optimized with fck-nat
enable_nat_gateway     = false  # Disable NAT Gateway when using fck-nat
single_nat_gateway     = true   # Use single NAT Gateway (saves ~$45/month)
one_nat_gateway_per_az = false  # Disable per-AZ NAT Gateways
enable_fck_nat         = true   # Use fck-nat for ultra cost savings (~$3/month)
fck_nat_instance_type  = "t4g.nano"
enable_vpn_gateway     = false
enable_flow_logs       = false  # Disable flow logs for dev (saves ~$10-50/month)

# EKS Cluster Name (used for subnet tags)
cluster_name = "dev-eks-cluster"

# Environment
environment = "dev"
project_name = "data-eng-aws"

# Tags
tags = {
  Environment = "dev"
  Project     = "data-eng-aws"
  Module      = "network"
  Owner       = "data-team"
  CostCenter  = "engineering"
}
