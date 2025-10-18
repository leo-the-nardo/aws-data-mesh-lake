# Security Group for EKS Cluster is now managed by the EKS module

# Security Group for API Gateway VPC Link
resource "aws_security_group" "api_gateway_vpc_link" {
  name_prefix = "${var.cluster_name}-api-gateway-vpc-link-"
  vpc_id      = module.vpc.vpc_id

  # Allow HTTPS traffic from API Gateway to NLB
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "HTTPS from API Gateway VPC Link to NLB"
  }

  # Allow HTTP traffic from API Gateway to NLB (if needed)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "HTTP from API Gateway VPC Link to NLB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-api-gateway-vpc-link-sg"
  })
}

# Security Group for MSK
resource "aws_security_group" "msk" {
  count       = var.enable_msk ? 1 : 0
  name_prefix = "${var.msk_cluster_name}-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ingress {
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.msk_cluster_name}-sg"
  })
}
