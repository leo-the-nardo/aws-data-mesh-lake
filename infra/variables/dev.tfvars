# Development Environment Configuration

# AWS Configuration
aws_region = "us-east-1"

# VPC Configuration
vpc_name = "vpc-producer"
private_subnet_names = ["SUBNET-PUBLIC-1A", "SUBNET-PUBLIC-1B",]
public_subnet_names  = ["SUBNET-PRIVATE-1A", "SUBNET-PRIVATE-1B",]

# EKS Configuration
cluster_name      = "dev-eks-cluster"
kubernetes_version = "1.33"

# MSK Configuration
msk_cluster_name = "dev-msk-cluster"
kafka_version    = "3.7.x"
msk_instance_type = "kafka.t3.small"
msk_storage_size  = 20

# Admin group ARN for EKS access (replace with your actual ARN)
admin_group_arn = "arn:aws:iam::992382465711:group/dev-admins"
# Admin user ARN for EKS access (replace with your actual ARN)
admin_arn = "arn:aws:iam::992382465711:user/producer-admin"

# Tags
tags = {
  Environment = "dev"
  Project     = "data-eng-aws"
  Owner       = "data-team"
  CostCenter  = "engineering"
}
