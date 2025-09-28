# Security Group for EKS Cluster is now managed by the EKS module

# Security Group for MSK
resource "aws_security_group" "msk" {
  name_prefix = "${var.msk_cluster_name}-"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.existing.cidr_block]
  }

  ingress {
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.existing.cidr_block]
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
