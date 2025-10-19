# AWS Load Balancer Controller using EKS Blueprints Add-ons Module
module "eks_blueprints_addons" {
  count = var.deploy_helm_addons ? 1 : 0
  
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.22"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn
  enable_aws_load_balancer_controller = true

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
