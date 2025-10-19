# VPC using terraform-aws-modules/vpc/aws

# EKS Cluster using terraform-aws-modules/eks/aws
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.3.1"
  name  = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnets
  upgrade_policy = {
    support_type = "STANDARD"
  }
  endpoint_private_access = true
  endpoint_public_access = true
  access_entries = var.access_entries
  # Fargate profiles with dynamic private subnet IDs
  fargate_profiles = {
    for k, v in var.fargate_profiles : k => merge(v, {
      subnet_ids = data.terraform_remote_state.network.outputs.private_subnets
    })
  }

  # Tags
  tags = var.tags
}
