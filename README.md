# AWS Data Engineering Infrastructure

Infrastructure as Code for AWS data engineering platform using Terraform and Kubernetes.

## Project Structure

```
├── infra-state-resources/   # S3 backend, DynamoDB, GitHub Actions OIDC
├── infra-network/           # VPC, subnets, routing
├── infra-data-mesh-producer/             # AWS Glue jobs,stepfunctions and other producer resources
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



**Destroy infrastructure**: Create `.destroy` file in infra directory:
```bash
touch infra-data-mesh-producer/.destroy
git add infra-data-mesh-producer/.destroy
git commit -m "destroy: mark glue for destruction"
git push  # Triggers plan destroy → approval → destroy
```

**Recreate infrastructure**: Remove `.destroy` file:
```bash
git rm infra-data-mesh-producer/.destroy
git commit -m "deploy: recreate glue infrastructure"
git push  # Triggers plan apply → approval → apply
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
