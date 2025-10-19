# Development Environment Configuration

# AWS Configuration
aws_region = "us-east-1"

# EKS Configuration
cluster_name      = "dev-eks-cluster"
kubernetes_version = "1.33"

# Fargate Profiles Configuration
fargate_profiles = {
  main = {
    name = "main"
    selectors = [
      {
        namespace = "kube-system"
      },
      {
        namespace = "default"
      },
      {
        namespace = "faxineiro"
      },
      {
        namespace = "monitoring"
      },
      {
        namespace = "ingress-nginx"
      }
    ]
  }
}

# MSK Configuration
msk_cluster_name = "dev-msk-cluster"
kafka_version    = "3.7.x"
msk_instance_type = "kafka.t3.small"
msk_storage_size  = 20
enable_msk        = false

# Admin group ARN for EKS access (replace with your actual ARN)
admin_group_arn = "arn:aws:iam::992382465711:group/dev-admins"
# Admin user ARN for EKS access (replace with your actual ARN)
admin_arn = "arn:aws:iam::992382465711:user/producer-admin"

# EKS Access Entries
access_entries = {
  admin_user = {
    principal_arn = "arn:aws:iam::992382465711:user/producer-admin"
    type = "STANDARD"
    policy_associations = {
      cluster_admin = {
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = {
          type = "cluster"
        }
      }
    }
  }
}

# Tags
tags = {
  Environment = "dev"
  Project     = "data-eng-aws"
  Owner       = "data-team"
  CostCenter  = "engineering"
}
