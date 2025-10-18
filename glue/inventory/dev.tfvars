# AWS Configuration
aws_region = "us-east-1"

# Project Configuration
project_name = "glue-pipeline"

# Spark UI Configuration
# Set to true to enable Spark UI for monitoring job execution
# Set to false to disable Spark UI (default)
enable_spark_ui = true

# Glue Job Configuration
glue_max_capacity = 2
glue_timeout      = 60

# Job Execution
# Set to true to run the job immediately after deployment
# Set to false to only create the job without running it
run_job_after_deploy = true

# Tags
tags = {
  Environment = "dev"
  Project     = "glue-pipeline"
  ManagedBy   = "terraform"
}
