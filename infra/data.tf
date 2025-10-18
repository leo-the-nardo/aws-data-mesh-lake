# Data sources for AWS availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
