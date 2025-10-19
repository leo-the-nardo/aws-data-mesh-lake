# OIDC Identity Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = {
    Name        = "GitHub Actions OIDC Provider"
    Environment = var.environment
    Purpose     = "GitHub Actions authentication"
  }
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "github-actions-terraform-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}/${var.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "GitHub Actions Terraform Role"
    Environment = var.environment
    Purpose     = "GitHub Actions Terraform deployment"
  }
}

# Attach AdministratorAccess policy for Terraform operations
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Optional: More restrictive policy for production use
resource "aws_iam_policy" "github_actions_terraform" {
  name        = "GitHubActionsTerraform-${var.environment}"
  description = "Policy for GitHub Actions Terraform operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "dynamodb:*",
          "ec2:*",
          "eks:*",
          "iam:*",
          "glue:*",
          "kms:*",
          "secretsmanager:*",
          "ssm:*",
          "cloudformation:*",
          "route53:*",
          "acm:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "rds:*",
          "elasticache:*",
          "logs:*",
          "cloudwatch:*",
          "events:*",
          "lambda:*",
          "apigateway:*",
          "cognito-idp:*",
          "cognito-identity:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "GitHub Actions Terraform Policy"
    Environment = var.environment
    Purpose     = "GitHub Actions Terraform permissions"
  }
}

# Attach the custom Terraform policy (uncomment to use instead of AdministratorAccess)
# resource "aws_iam_role_policy_attachment" "github_actions_terraform" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = aws_iam_policy.github_actions_terraform.arn
# }
