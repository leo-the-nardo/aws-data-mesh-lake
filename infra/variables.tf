variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "vpc_name" {
  description = "Name of the existing VPC"
  type        = string
  default     = "default"
}

variable "private_subnet_names" {
  description = "Names of the private subnets"
  type        = list(string)
  default     = ["private-subnet-*"]
}

variable "public_subnet_names" {
  description = "Names of the public subnets"
  type        = list(string)
  default     = ["public-subnet-*"]
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "producer-account"
  }
}
