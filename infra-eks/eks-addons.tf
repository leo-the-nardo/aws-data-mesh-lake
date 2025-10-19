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

