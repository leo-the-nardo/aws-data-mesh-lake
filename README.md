# AWS Data Engineering Infrastructure

Infrastructure as Code for AWS data engineering platform using Terraform and Kubernetes.

## 🏗️ Project Structure

```
.
├── infra-state-resources/   # S3 backend, DynamoDB, GitHub Actions OIDC
├── infra-network/           # VPC, subnets, routing
├── infra-glue/             # AWS Glue jobs and catalog
├── infra-eks/              # EKS cluster, MSK, add-ons
├── k8s-manifests/          # Kubernetes deployments and services
└── .github/workflows/      # CI/CD pipelines with cost-effective approvals
```

## 🚀 Quick Start

### Option 1: GitHub Actions (Recommended)

Cost-effective deployment with approval gates that **don't consume runner minutes**:

1. **Setup** (one-time):
   ```bash
   cd infra-state-resources
   terraform init
   terraform apply
   ```

2. **Configure GitHub Actions**: Follow [.github/SETUP.md](.github/SETUP.md)

3. **Deploy via GitHub UI**:
   - Go to Actions → "Deploy All Infrastructure"
   - Run workflow with desired environment
   - Approve when ready (no costs while waiting!)

### Option 2: Local Deployment

```bash
# Initialize Terraform
cd infra-<component>
terraform init

# Plan the deployment
terraform plan -var-file="variables/dev.tfvars"

# Apply the configuration
terraform apply -var-file="variables/dev.tfvars"

# Configure kubectl access
aws eks update-kubeconfig --region <your-region> --name <cluster-name>
```

## 🔐 GitHub Actions Workflows

We use **environment-based approvals** that pause workflows without consuming GitHub Actions minutes:

| Workflow | Purpose | Cost Savings |
|----------|---------|--------------|
| `terraform-deploy-with-approval.yml` | PR-triggered deployments | 92% reduction |
| `manual-approval-workflow.yml` | Manual plan/apply | 86% reduction |
| `deploy-all-infra.yml` | Full stack deployment | 90% reduction |

**How it works**: Workflows pause between jobs while waiting for approval, with **zero runner costs** during the wait.

📚 **[Read the full setup guide](.github/SETUP.md)**

## Outputs

After deployment, you'll get:
- EKS cluster endpoint and configuration
- MSK cluster bootstrap brokers
- VPC and subnet information
- kubectl configuration command

## Accessing the Clusters

### EKS Cluster
```bash
# Configure kubectl
aws eks update-kubeconfig --region <region> --name <cluster-name>

# Verify access
kubectl get nodes
```

### MSK Cluster
Use the bootstrap brokers from the Terraform outputs to connect your Kafka clients.

## Cleanup

```bash
terraform destroy
```
