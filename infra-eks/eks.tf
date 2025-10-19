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

  # Managed node groups for reliable capacity
  eks_managed_node_groups = {
    main = {
      name = "main"
      instance_types = ["t3.medium"]
      capacity_type = "ON_DEMAND"
      min_size = 1
      max_size = 3
      desired_size = 2
      subnet_ids = data.terraform_remote_state.network.outputs.private_subnets

      # Disk configuration to fix image filesystem capacity issue
      disk_size = 50
      disk_type = "gp3"
      
      # Labels for node identification
      labels = {
        node-type = "worker"
        environment = var.environment
      }
    }
  }

  # Tags
  tags = var.tags
}

# EKS Add-ons - configured separately to avoid circular dependencies
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = module.eks.cluster_name
  addon_name   = "vpc-cni"
  
  # Use latest compatible version
  # Let AWS determine the best version for Kubernetes 1.33
  
  tags = var.tags
}

resource "aws_eks_addon" "coredns" {
  cluster_name = module.eks.cluster_name
  addon_name   = "coredns"
  
  # Use latest compatible version
  # Let AWS determine the best version for Kubernetes 1.33
  
  depends_on = [
    module.eks,
    aws_eks_addon.vpc_cni
  ]
  
  tags = var.tags
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = module.eks.cluster_name
  addon_name   = "kube-proxy"
  
  # Use latest compatible version
  # Let AWS determine the best version for Kubernetes 1.33
  
  depends_on = [
    module.eks,
    aws_eks_addon.vpc_cni
  ]
  
  tags = var.tags
}
