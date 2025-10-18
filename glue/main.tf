terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# Data source to get current AWS region
data "aws_region" "current" {}

# S3 bucket for Glue scripts and data
resource "aws_s3_bucket" "glue_bucket" {
  bucket = "${var.project_name}-glue-${random_string.bucket_suffix.result}"
  force_destroy = true
  
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_versioning" "glue_bucket" {
  bucket = aws_s3_bucket.glue_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "glue_bucket" {
  bucket = aws_s3_bucket.glue_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# IAM role for Glue service
resource "aws_iam_role" "glue_role" {
  name = "${var.project_name}-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for Glue service
resource "aws_iam_role_policy" "glue_policy" {
  name = "${var.project_name}-glue-policy"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.glue_bucket.arn,
          "${aws_s3_bucket.glue_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach AWS managed policy for Glue service
resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Glue job
resource "aws_glue_job" "spark_job" {
  name         = "${var.project_name}-spark-job"
  role_arn     = aws_iam_role.glue_role.arn
  glue_version = "4.0"

  command {
    script_location = "s3://${aws_s3_bucket.glue_bucket.bucket}/scripts/spark_job.py"
    python_version  = "3"
  }

  default_arguments = merge(
    {
      "--job-language"                    = "python"
      "--job-bookmark-option"             = "job-bookmark-disable"
      "--enable-metrics"                  = "true"
      "--enable-continuous-cloudwatch-log" = "true"
      "--enable-spark-ui"                 = var.enable_spark_ui ? "true" : "false"
      "--spark-event-logs-path"           = var.enable_spark_ui ? "s3://${aws_s3_bucket.glue_bucket.bucket}/spark-logs/" : ""
      "--TempDir"                         = "s3://${aws_s3_bucket.glue_bucket.bucket}/temp/"
      "--enable-continuous-log-filter"    = "true"
      "--enable-continuous-cloudwatch-log" = "true"
    },
    var.enable_spark_ui ? {
      "--spark-ui-enabled" = "true"
    } : {}
  )

  max_capacity = var.glue_max_capacity
  timeout      = var.glue_timeout

  tags = var.tags
}

# Upload the Spark script to S3
resource "aws_s3_object" "spark_script" {
  bucket = aws_s3_bucket.glue_bucket.bucket
  key    = "scripts/spark_job.py"
  source = "${path.module}/scripts/spark_job.py"
  etag   = filemd5("${path.module}/scripts/spark_job.py")
}

# Run the Glue job after deployment
resource "null_resource" "run_glue_job" {
  count = var.run_job_after_deploy ? 1 : 0

  provisioner "local-exec" {
    command = "aws glue start-job-run --job-name ${aws_glue_job.spark_job.name} --region ${var.aws_region}"
  }

  depends_on = [
    aws_s3_object.spark_script,
    aws_glue_job.spark_job
  ]

  triggers = {
    job_name = aws_glue_job.spark_job.name
    script_etag = aws_s3_object.spark_script.etag
  }
}
