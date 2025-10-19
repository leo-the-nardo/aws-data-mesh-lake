# API Gateway v2 (HTTP API)
resource "aws_apigatewayv2_api" "nlb_api" {
  count         = var.enable_api_gateway ? 1 : 0
  name          = "${var.cluster_name}-nlb-api"
  protocol_type = "HTTP"
  description   = "API Gateway v2 for ${var.cluster_name} NLB service"

  cors_configuration {
    allow_credentials = false
    allow_headers     = ["*"]
    allow_methods     = ["*"]
    allow_origins     = ["*"]
    expose_headers    = ["*"]
    max_age          = 300
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-nlb-api"
  })
}

# VPC Link for API Gateway to connect to NLB
resource "aws_apigatewayv2_vpc_link" "nlb_vpc_link" {
  count              = var.enable_api_gateway ? 1 : 0
  name               = "${var.cluster_name}-nlb-vpc-link"
  security_group_ids = [aws_security_group.api_gateway_vpc_link.id]
  subnet_ids         = data.terraform_remote_state.network.outputs.private_subnets
  tags = merge(var.tags, {
    Name = "${var.cluster_name}-nlb-vpc-link"
  })
}

# API Gateway Integration
resource "aws_apigatewayv2_integration" "nlb_integration" {
  count            = var.enable_api_gateway && var.nlb_dns_name != "" ? 1 : 0
  api_id           = aws_apigatewayv2_api.nlb_api[0].id
  integration_type = "HTTP_PROXY"
  integration_uri  = "https://${var.nlb_dns_name}"
  connection_type  = "VPC_LINK"
  connection_id    = aws_apigatewayv2_vpc_link.nlb_vpc_link[0].id

  integration_method = "ANY"
  payload_format_version = "1.0"
}

# API Gateway Route
resource "aws_apigatewayv2_route" "nlb_route" {
  count    = var.enable_api_gateway && var.nlb_dns_name != "" ? 1 : 0
  api_id   = aws_apigatewayv2_api.nlb_api[0].id
  route_key = "ANY /{proxy+}"
  target   = "integrations/${aws_apigatewayv2_integration.nlb_integration[0].id}"
}

# API Gateway Stage
resource "aws_apigatewayv2_stage" "nlb_stage" {
  count    = var.enable_api_gateway ? 1 : 0
  api_id   = aws_apigatewayv2_api.nlb_api[0].id
  name     = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_rate_limit  = 1000
    throttling_burst_limit = 2000
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs[0].arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-nlb-stage"
  })
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  count             = var.enable_api_gateway ? 1 : 0
  name              = "/aws/apigateway/${var.cluster_name}-nlb-api"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-api-gateway-logs"
  })
}
