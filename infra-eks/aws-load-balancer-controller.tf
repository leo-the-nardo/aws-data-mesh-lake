# AWS Load Balancer Controller using EKS Blueprints Add-ons Module
module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.22"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn
  enable_aws_load_balancer_controller = true
  
  # Wait for Fargate profiles to be ready so the controller pods have somewhere to run
  depends_on = [
    module.eks,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.coredns,
    aws_eks_addon.kube_proxy
  ]

  aws_load_balancer_controller = {
    name = "aws-load-balancer-controller"
    chart = "aws-load-balancer-controller"
    chart_version = "1.14.0"
    namespace = "kube-system"
    set = [
      {
        name  = "clusterName"
        value = module.eks.cluster_name
      },
      {
        name  = "region"
        value = var.aws_region
      },
      {
        name  = "vpcId"
        value = data.terraform_remote_state.network.outputs.vpc_id
      }
    ]
  }

  tags = var.tags
}
