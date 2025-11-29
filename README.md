# Data Mesh on AWS - Reference Architecture
<img width="2591" height="6279" alt="aws-data-mesh-reference" src="https://github.com/user-attachments/assets/dc5826f6-042d-46a7-81a7-3f6e4a5fbf3c" />


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
