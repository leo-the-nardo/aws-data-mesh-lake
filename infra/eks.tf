# EKS Cluster using terraform-aws-modules/eks/aws
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.21.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id     = data.aws_vpc.existing.id
  subnet_ids = data.aws_subnets.private.ids

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # Cluster access entry
  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = var.admin_arn
      username = "admin"
      groups   = ["system:masters"]
    }
  ]

  # Fargate profiles
  fargate_profiles = {
    main = {
      name = "main"
      selectors = [
        {
          namespace = "*"
        }
      ]
    }
  }

  # Cluster security group
  cluster_security_group_additional_rules = {
    ingress_from_vpc = {
      description = "Allow all inbound traffic from within the VPC"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = [data.aws_vpc.existing.cidr_block]
    }
    ingress_https = {
      description = "Allow HTTPS from anywhere (for EKS API)"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Tags
  tags = var.tags
}