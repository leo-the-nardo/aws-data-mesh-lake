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

output "msk_cluster_arn" {
  description = "MSK cluster ARN"
  value       = var.enable_msk ? aws_msk_cluster.main[0].arn : null
}

output "msk_cluster_name" {
  description = "MSK cluster name"
  value       = var.enable_msk ? aws_msk_cluster.main[0].cluster_name : null
}

output "msk_bootstrap_brokers" {
  description = "MSK bootstrap brokers"
  value       = var.enable_msk ? aws_msk_cluster.main[0].bootstrap_brokers : null
}

output "msk_bootstrap_brokers_tls" {
  description = "MSK bootstrap brokers with TLS"
  value       = var.enable_msk ? aws_msk_cluster.main[0].bootstrap_brokers_tls : null
}

output "msk_zookeeper_connect_string" {
  description = "MSK Zookeeper connect string"
  value       = var.enable_msk ? aws_msk_cluster.main[0].zookeeper_connect_string : null
}

# output "vpc_id" {
#   description = "VPC ID"
#   value       = data.aws_vpc.existing.id
# }

output "private_subnet_ids" {
  description = "Private subnet IDs for NLB service"
  value       = data.terraform_remote_state.network.outputs.private_subnets
}

# API Gateway v2 outputs
output "api_gateway_id" {
  description = "API Gateway v2 ID"
  value       = var.enable_api_gateway ? aws_apigatewayv2_api.nlb_api[0].id : null
}

output "api_gateway_endpoint_url" {
  description = "API Gateway v2 endpoint URL"
  value       = var.enable_api_gateway ? aws_apigatewayv2_api.nlb_api[0].api_endpoint : null
}

output "api_gateway_vpc_link_id" {
  description = "API Gateway v2 VPC Link ID"
  value       = var.enable_api_gateway ? aws_apigatewayv2_vpc_link.nlb_vpc_link[0].id : null
}

output "nlb_dns_name" {
  description = "NLB DNS name"
  value       = var.nlb_dns_name != "" ? var.nlb_dns_name : null
}



# output "public_subnet_ids" {
#   description = "Public subnet IDs"
#   value       = data.aws_subnets.public.ids
# }
