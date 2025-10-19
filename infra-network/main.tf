terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket         = "tfstates-data-eng-aws"
    key            = "infra-network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-data-eng-aws"
    encrypt        = true
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC using terraform-aws-modules/vpc/aws
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  # Cost optimization: Single NAT Gateway instead of per-AZ
  enable_nat_gateway     = var.enable_nat_gateway && !var.enable_fck_nat
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  
  enable_vpn_gateway = var.enable_vpn_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Cost optimization: Disable flow logs for dev environment
  enable_flow_log                      = var.enable_flow_logs
  create_flow_log_cloudwatch_log_group  = var.enable_flow_logs
  create_flow_log_cloudwatch_iam_role   = var.enable_flow_logs

  # Tags
  tags = var.tags

  # Additional tags for subnets
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# fck-nat implementation for ultra cost-effective NAT
module "fck_nat" {
  count  = var.enable_fck_nat ? 1 : 0
  source = "RaJiska/fck-nat/aws"
  version = "1.3.0"

  name          = "${var.vpc_name}-fck-nat"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnets[0]  # Use first public subnet
  instance_type = var.fck_nat_instance_type
}
