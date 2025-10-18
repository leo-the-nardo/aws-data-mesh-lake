# Kubernetes Manifests

This directory contains Kubernetes manifests for the EKS cluster.

## Files

- `nlb-service.yaml` - NLB service with automatic subnet selection

## AWS Load Balancer Controller Subnet Discovery

The AWS Load Balancer Controller discovers subnets through a multi-step process:

### 1. Subnet Tag Discovery
The controller looks for subnets with specific tags:

**For Internal Load Balancers:**
- `kubernetes.io/role/internal-elb = "1"`
- `kubernetes.io/cluster/<cluster-name> = "owned"`

**For Internet-facing Load Balancers:**
- `kubernetes.io/role/elb = "1"`
- `kubernetes.io/cluster/<cluster-name> = "owned"`

### 2. Subnet Filtering
- **Cluster Tag Check**: Only subnets tagged with the current cluster name
- **IP Availability**: Subnets with fewer than 8 available IPs are excluded
- **AZ Distribution**: One subnet per Availability Zone

### 3. Final Selection
- Prioritizes subnets with cluster ownership
- Selects lexicographically first subnet ID per AZ

## Implementation

1. **Terraform VPC Configuration** (`eks.tf`):
   - Adds required subnet tags for controller discovery
   - Tags private subnets for internal load balancers
   - Tags public subnets for internet-facing load balancers

2. **Service Configuration**:
   - Standard Kubernetes Service with LoadBalancer type
   - AWS Load Balancer Controller automatically discovers subnets
   - No explicit subnet specification needed
   - Fargate-compatible pod spec (no node selectors or tolerations)

## Deployment

1. **Apply Terraform:**
   ```bash
   terraform apply
   # Creates VPC with proper subnet tags
   ```

2. **Deploy NLB service:**
   ```bash
   kubectl apply -f nlb-service.yaml
   ```

3. **Verify deployment:**
   ```bash
   kubectl get svc nlb-service
   kubectl describe svc nlb-service
   ```

4. **Check subnet tags:**
   ```bash
   aws ec2 describe-subnets --filters "Name=tag:kubernetes.io/cluster/dev-eks-cluster,Values=owned"
   ```

## Benefits

- **Fully declarative** - no imperative commands
- **Automatic subnet selection** by AWS Load Balancer Controller
- **Simplified configuration** - no custom logic or RBAC
- **Standard Kubernetes patterns** - pure Service manifest
- **No external dependencies** - uses built-in AWS integration
- **Fargate-compatible** - works with both Fargate and EC2 nodes

## Fargate Compatibility

The NLB service is configured to work with AWS Fargate:

- **No node selectors** - Fargate doesn't support node selection
- **No tolerations** - Fargate doesn't support taints/tolerations
- **Standard pod spec** - Uses only Fargate-supported features
- **Automatic scheduling** - Pods can be scheduled on any Fargate profile

## Container Configuration

The nginx container is configured to:
- Listen on port 8080 (instead of default 80)
- Return a simple "NLB Service is running!" message
- Use startup, liveness, and readiness probes for health checks

## Troubleshooting

- Check pod status: `kubectl get pods -l app=nlb-app`
- Check pod logs: `kubectl logs -l app=nlb-app`
- Check service status: `kubectl get svc nlb-service`
- Check service events: `kubectl describe svc nlb-service`
- Verify load balancer creation in AWS console
- Test pod health: `kubectl port-forward <pod-name> 8080:8080` then `curl localhost:8080`