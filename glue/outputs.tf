output "s3_bucket_name" {
  description = "Name of the S3 bucket for Glue scripts and data"
  value       = aws_s3_bucket.glue_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Glue scripts and data"
  value       = aws_s3_bucket.glue_bucket.arn
}

output "glue_job_name" {
  description = "Name of the Glue job"
  value       = aws_glue_job.spark_job.name
}

output "glue_job_arn" {
  description = "ARN of the Glue job"
  value       = aws_glue_job.spark_job.arn
}

output "glue_role_arn" {
  description = "ARN of the Glue IAM role"
  value       = aws_iam_role.glue_role.arn
}

output "spark_ui_enabled" {
  description = "Whether Spark UI is enabled for the job"
  value       = var.enable_spark_ui
}

output "spark_ui_info" {
  description = "Information about Spark UI access"
  value = var.enable_spark_ui ? {
    enabled = true
    message = "Spark UI is enabled. Access it through the Glue console during job execution."
  } : {
    enabled = false
    message = "Spark UI is disabled. Set enable_spark_ui = true to enable it."
  }
}

output "job_run_id" {
  description = "ID of the Glue job run (if run_job_after_deploy is true)"
  value       = var.run_job_after_deploy ? null_resource.run_glue_job[0].id : null
}

output "job_run_status" {
  description = "Status of the Glue job run"
  value       = var.run_job_after_deploy ? "Job will run after deployment" : "Job will not run automatically"
}
