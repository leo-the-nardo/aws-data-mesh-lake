# AWS Data Engineering Infrastructure

Infrastructure as Code for AWS data engineering platform using Terraform and Kubernetes.

## Project Structure

```
├── infra-state-resources/   # S3 backend, DynamoDB, GitHub Actions OIDC
├── infra-network/           # VPC, subnets, routing
├── infra-glue/             # AWS Glue jobs and catalog
├── infra-eks/              # EKS cluster, MSK, add-ons
└── k8s-manifests/          # Kubernetes deployments
```

## Quick Commands

### Local Deployment
```bash
# Deploy infrastructure
cd infra-<component>
terraform init
terraform plan -var-file="variables/dev.tfvars"
terraform apply -var-file="variables/dev.tfvars"
```

### GitHub Actions
```bash
# Setup (one-time)
cd infra-state-resources
terraform init && terraform apply
terraform output github_actions_role_arn  # Copy to GitHub Secrets as AWS_ROLE_ARN

# Deploy: Push to main or use Actions UI → "Deploy Infrastructure"
# Terraform version: 1.9.8 (change in reusable-terraform.yml line 21)
```

**Destroy infrastructure**: Create `.destroy` file in infra directory, then push:
```bash
touch infra-glue/.destroy
git add infra-glue/.destroy
git commit -m "destroy: mark glue for destruction"
git push  # Triggers plan destroy → approval → destroy
# After destroy, .destroy file is auto-removed and next run will recreate
```

### EKS Access
```bash
# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name <cluster-name>

# Verify
kubectl get nodes
kubectl get pods -A
```

### Useful Commands
```bash
# Get MSK bootstrap brokers
cd infra-eks
terraform output msk_bootstrap_brokers

# Get EKS cluster info
terraform output eks_cluster_endpoint

# Destroy resources
terraform destroy -var-file="variables/dev.tfvars"
```
