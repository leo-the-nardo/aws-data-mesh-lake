# output "eks_cluster_id" {
#   description = "EKS cluster ID"
#   value       = module.eks.cluster_id
# }

# output "eks_cluster_arn" {
#   description = "EKS cluster ARN"
#   value       = module.eks.cluster_arn
# }

# output "eks_cluster_endpoint" {
#   description = "EKS cluster endpoint"
#   value       = module.eks.cluster_endpoint
# }

# output "eks_cluster_name" {
#   description = "EKS cluster name"
#   value       = module.eks.cluster_name
# }

# output "eks_cluster_certificate_authority_data" {
#   description = "EKS cluster certificate authority data"
#   value       = module.eks.cluster_certificate_authority_data
# }

# output "kubectl_config_command" {
#   description = "Command to configure kubectl"
#   value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
# }

# output "msk_cluster_arn" {
#   description = "MSK cluster ARN"
#   value       = aws_msk_cluster.main.arn
# }

# output "msk_cluster_name" {
#   description = "MSK cluster name"
#   value       = aws_msk_cluster.main.cluster_name
# }

# output "msk_bootstrap_brokers" {
#   description = "MSK bootstrap brokers"
#   value       = aws_msk_cluster.main.bootstrap_brokers
# }

# output "msk_bootstrap_brokers_tls" {
#   description = "MSK bootstrap brokers with TLS"
#   value       = aws_msk_cluster.main.bootstrap_brokers_tls
# }

# output "msk_zookeeper_connect_string" {
#   description = "MSK Zookeeper connect string"
#   value       = aws_msk_cluster.main.zookeeper_connect_string
# }

# output "vpc_id" {
#   description = "VPC ID"
#   value       = data.aws_vpc.existing.id
# }

# output "private_subnet_ids" {
#   description = "Private subnet IDs"
#   value       = data.aws_subnets.private.ids
# }

# output "public_subnet_ids" {
#   description = "Public subnet IDs"
#   value       = data.aws_subnets.public.ids
# }
