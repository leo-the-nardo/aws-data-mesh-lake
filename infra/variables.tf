variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.33"
}

variable "msk_cluster_name" {
  description = "Name of the MSK cluster"
  type        = string
  default     = "datapoc-msk-cluster"
}

variable "kafka_version" {
  description = "Kafka version for MSK cluster"
  type        = string
  default     = "3.7.x"
}

variable "msk_instance_type" {
  description = "Instance type for MSK brokers"
  type        = string
  default     = "kafka.t3.small"
}

variable "msk_storage_size" {
  description = "Storage size in GB for MSK brokers"
  type        = number
  default     = 50
}

variable "admin_group_arn" {
  description = "ARN of the admin group for EKS access"
  type        = string
}

variable "admin_arn" {
  description = "ARN of the admin user for EKS access"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "data-eng-aws"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "access_entries" {
  description = "EKS access entries configuration"
  type = map(object({
    # Access entry
    kubernetes_groups = optional(list(string))
    principal_arn     = string
    type              = optional(string, "STANDARD")
    user_name         = optional(string)
    tags              = optional(map(string), {})
    
    # Access policy association
    policy_associations = optional(map(object({
      policy_arn = string
      access_scope = object({
        namespaces = optional(list(string))
        type       = string
      })
    })), {})
  }))
  default = {}
}

variable "fargate_profiles" {
  description = "Fargate profiles configuration"
  type = map(object({
    name       = optional(string)
    subnet_ids = optional(list(string))
    selectors = list(object({
      labels    = optional(map(string))
      namespace = string
    }))
    tags = optional(map(string))
  }))
  default = {}
}

variable "enable_msk" {
  description = "Enable MSK cluster creation"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "producer-account"
  }
}

variable "enable_api_gateway" {
  description = "Enable API Gateway v2 creation"
  type        = bool
  default     = true
}

variable "nlb_service_name" {
  description = "Name of the NLB service created by Kubernetes"
  type        = string
  default     = "nlb-svc-simulacaoconvivencia"
}

variable "nlb_dns_name" {
  description = "DNS name of the NLB service (set this after NLB is created)"
  type        = string
  default     = ""
}
