variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "glue-pipeline"
}

variable "enable_spark_ui" {
  description = "Enable Spark UI for the Glue job (true/false)"
  type        = bool
  default     = false
}

variable "glue_max_capacity" {
  description = "Maximum number of AWS Glue data processing units (DPUs) that can be allocated when this job runs"
  type        = number
  default     = 2
}

variable "glue_timeout" {
  description = "Job timeout in minutes"
  type        = number
  default     = 60
}

variable "run_job_after_deploy" {
  description = "Whether to run the Glue job immediately after deployment"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "glue-pipeline"
    ManagedBy   = "terraform"
  }
}
