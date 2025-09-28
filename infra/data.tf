# Data sources to fetch existing VPC, subnets, and security groups
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  filter {
    name   = "tag:Name"
    values = var.private_subnet_names
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  filter {
    name   = "tag:Name"
    values = var.public_subnet_names
  }
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.existing.id
  name   = "default"
}
