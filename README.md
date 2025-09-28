## Usage

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Configure kubectl access
aws eks update-kubeconfig --region <your-region> --name <cluster-name>
```

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
