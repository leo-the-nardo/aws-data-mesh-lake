# VPC using terraform-aws-modules/vpc/aws
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  
  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"
  
  azs = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  
  # Public subnets for NAT Gateway and Load Balancers
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  
  # Private subnets for EKS nodes
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  
  # Enable NAT Gateway for private subnets
  enable_nat_gateway = true
  single_nat_gateway = true
  
  # Enable DNS resolution and hostnames
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = merge(var.tags, {
    Name = "${var.cluster_name}-vpc"
  })

  # Tags for AWS Load Balancer Controller subnet discovery
  public_subnet_tags = merge(var.tags, {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })

  private_subnet_tags = merge(var.tags, {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })
}

# EKS Cluster using terraform-aws-modules/eks/aws
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.3.1"
  name  = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  upgrade_policy = {
    support_type = "STANDARD"
  }
  endpoint_private_access = true
  endpoint_public_access = true
  access_entries = var.access_entries
  # Fargate profiles with dynamic private subnet IDs
  fargate_profiles = {
    for k, v in var.fargate_profiles : k => merge(v, {
      subnet_ids = module.vpc.private_subnets
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
      subnet_ids = module.vpc.private_subnets

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
