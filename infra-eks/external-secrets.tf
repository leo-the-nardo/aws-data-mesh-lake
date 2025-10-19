# External Secrets Operator IAM Role and Policies

# IAM Role for External Secrets Operator
resource "aws_iam_role" "external_secrets" {
  name = "${var.cluster_name}-external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:external-secrets-system:external-secrets"
            "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for External Secrets Operator to access AWS Secrets Manager
resource "aws_iam_policy" "external_secrets" {
  name        = "${var.cluster_name}-external-secrets-policy"
  description = "Policy for External Secrets Operator to access AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:*:secret:prod/*",
          "arn:aws:secretsmanager:${var.aws_region}:*:secret:dev/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:ListSecrets"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}

# Output the IAM role ARN for use in Kubernetes manifests
output "external_secrets_role_arn" {
  description = "ARN of the IAM role for External Secrets Operator"
  value       = aws_iam_role.external_secrets.arn
}
