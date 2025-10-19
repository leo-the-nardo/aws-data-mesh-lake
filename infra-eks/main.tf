terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket         = "tfstates-data-eng-aws"
    key            = "infra-eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-data-eng-aws"
    encrypt        = true
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

}

provider "aws" {
  region = var.aws_region
}

# Data source to get network outputs from remote state
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket         = "tfstates-data-eng-aws"
    key            = "infra-network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-data-eng-aws"
    encrypt        = true
  }
}

