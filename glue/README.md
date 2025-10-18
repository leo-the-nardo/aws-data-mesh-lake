# AWS Glue Spark Pipeline

This Terraform configuration creates a complete AWS Glue pipeline with Spark support, including an easy toggle for Spark UI.

## Features

- **S3 Bucket**: For storing Glue scripts and data
- **IAM Roles**: Proper permissions for Glue service
- **Glue Job**: Spark-based ETL job with configurable Spark UI
- **Sample Script**: Demonstrates Spark transformations and data processing

## Quick Start

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Configure your variables in `terraform.tfvars`:**
   ```hcl
   aws_region = "us-east-1"
   project_name = "my-glue-pipeline"
   enable_spark_ui = true  # Set to true to enable Spark UI
   ```

3. **Initialize and apply Terraform:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Spark UI Toggle

The easiest way to enable/disable Spark UI is by setting the `enable_spark_ui` variable:

```hcl
# Enable Spark UI
enable_spark_ui = true

# Disable Spark UI (default)
enable_spark_ui = false
```

When Spark UI is enabled:
- You can monitor job execution in real-time
- Access detailed Spark metrics and logs
- Debug performance issues
- View DAG visualization

## Running the Job

The job can be configured to run automatically after deployment by setting `run_job_after_deploy = true` (default). You can also run the Glue job manually in several ways:

### AWS Console
1. Go to AWS Glue Console
2. Navigate to "Jobs"
3. Find your job (named `{project_name}-spark-job`)
4. Click "Run job"

### AWS CLI
```bash
aws glue start-job-run --job-name your-job-name
```

### Terraform
```bash
terraform apply -var="enable_spark_ui=true"
```

## Configuration Options

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `aws_region` | AWS region for resources | `us-east-1` | string |
| `project_name` | Project name for resource naming | `glue-pipeline` | string |
| `enable_spark_ui` | Enable Spark UI for monitoring | `false` | bool |
| `glue_max_capacity` | Maximum DPUs for the job | `2` | number |
| `glue_timeout` | Job timeout in minutes | `60` | number |
| `run_job_after_deploy` | Run job immediately after deployment | `true` | bool |

## Outputs

After deployment, you'll get:
- S3 bucket name and ARN
- Glue job name and ARN
- IAM role ARN
- Spark UI status information
- Job run ID (if auto-run is enabled)
- Job execution status

## Sample Script

The included `spark_job.py` demonstrates:
- Creating DataFrames
- Data transformations
- Aggregations
- Logging
- Spark UI integration

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Notes

- The S3 bucket is created with versioning and encryption enabled
- IAM roles follow least privilege principle
- Spark UI logs are stored in S3 when enabled
- The job uses Glue 4.0 with Python 3
