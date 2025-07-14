# K0s Cluster with Load Balancer in Existing Project

This example demonstrates how to deploy a k0s Kubernetes cluster with a load balancer in an existing OpenStack project using the terraform-openstack-k0ctl module.

## Architecture

This configuration creates:
- 3 controller+worker nodes with floating IPs
- An OpenStack Octavia load balancer with:
  - TCP listener on port 6443 (Kubernetes API)
  - TCP listener on port 9443 (k0s API)
  - Health monitoring for both APIs
  - LEAST_CONNECTIONS load balancing
  - Floating IP for external access
- All resources deployed in an existing OpenStack project

## Prerequisites

1. **Existing OpenStack Project**: You must have an existing OpenStack project with sufficient quotas
2. **Project Access**: Your OpenStack credentials must have access to the existing project
3. **SSH Key**: SSH public key available (defaults to `~/.ssh/id_rsa.pub`)
4. **Required Quotas** in the existing project:
   - 3 instances
   - 4 floating IPs (3 for nodes + 1 for load balancer)
   - 1 load balancer with pool and members
   - Network resources (1 network, 1 subnet, 1 router)

## Usage

### 1. Get Project Information

First, find your existing project ID:

```bash
# Using OpenStack CLI
openstack project list

# Or using environment variables
echo $OS_PROJECT_ID
```

### 2. Configure Variables

Copy the example variables file and update it:

```bash
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
```

Update `terraform.tfvars` with your project ID:
```hcl
existing_project_id = "your-actual-project-id"
ssh_public_key_file = "~/.ssh/id_rsa.pub"
```

### 3. Deploy Infrastructure

```bash
# Initialize and apply
tofu init
tofu plan
tofu apply
```

### 4. Deploy k0s Cluster

```bash
# Apply the k0s cluster configuration
k0sctl apply --config ./k0sctl.yaml
```

### 5. Access the Cluster

```bash
# Get kubeconfig
k0sctl kubeconfig --config ./k0sctl.yaml > kubeconfig
export KUBECONFIG=$PWD/kubeconfig

# Test cluster access
kubectl get nodes
kubectl cluster-info
```

## Configuration Details

### Project Configuration

- **create_project**: `false` - Use existing project
- **project_id**: Variable for existing project ID
- **create_user**: `false` - No user creation needed
- **create_app_credential**: `false` - No app credentials needed

### Load Balancer Configuration

- **Algorithm**: `LEAST_CONNECTIONS`
- **Health Monitor**: TCP health checks on ports 6443 and 9443
- **Pool Members**: All nodes (k0s-node-0, k0s-node-1, k0s-node-2 by default)
- **External Access**: Floating IP assigned to load balancer

### Instance Configuration

- **Nodes**: 3x m1.xlarge instances (50GB volumes, floating IPs)
- **Role**: All nodes run as controller+worker (can schedule workloads)
- **Network**: Private network with subnet 10.0.2.0/24

## Outputs

After deployment, you'll get:

```bash
# Load balancer endpoints
loadbalancer_endpoint = "https://203.0.113.100:6443"
k0s_api_endpoint = "https://203.0.113.100:9443"

# Instance SSH commands
ssh_commands = {
  controller-1 = "ssh ubuntu@203.0.113.101"
  controller-2 = "ssh ubuntu@203.0.113.102"
  controller-3 = "ssh ubuntu@203.0.113.103"
}

# k0sctl commands
k0sctl_apply_command = "k0sctl apply --config ./k0sctl.yaml"
kubeconfig_command = "k0sctl kubeconfig --config ./k0sctl.yaml > kubeconfig && export KUBECONFIG=$PWD/kubeconfig"
```

## Generated Files

- `k0sctl.yaml`: k0s cluster configuration with load balancer endpoint
- `clouds.yaml`: OpenStack client configuration (for the existing project)

## Benefits of This Approach

1. **No Project Creation**: Uses existing project structure and quotas
2. **High Availability**: Load balancer provides HA for Kubernetes API
3. **Cost Efficient**: Reuses existing project resources
4. **Compact Setup**: 3-node cluster with combined controller+worker roles
5. **Fault Tolerance**: Automatic failover if nodes become unhealthy

## Accessing the Cluster

The APIs are available at:
- **Kubernetes API External**: `https://<lb_floating_ip>:6443`
- **Kubernetes API Internal**: `https://<lb_vip>:6443`
- **k0s API External**: `https://<lb_floating_ip>:9443`
- **k0s API Internal**: `https://<lb_vip>:9443`

All kubectl and k0sctl commands will automatically use the load balancer endpoints.

## Network Architecture

```
Internet
    |
    | (floating IP)
    |
Load Balancer (Octavia)
    |
    | (round-robin)
    |
+---+---+---+
|   |   |   |
v   v   v   v
N1  N2  N3  (Controller+Worker Nodes)
    |
    | (internal network 10.0.2.0/24)
    |
```

## Troubleshooting

### Common Issues

1. **Invalid Project ID**: 
   ```bash
   # Verify project exists and is accessible
   openstack project show <project_id>
   ```

2. **Insufficient Quotas**:
   ```bash
   # Check quotas
   openstack quota show <project_id>
   ```

3. **Network Conflicts**:
   - Ensure subnet CIDR doesn't conflict with existing networks
   - Check if external network name is correct

4. **Load Balancer Creation Fails**:
   - Verify Octavia service is available
   - Check load balancer quotas

### Debugging Commands

```bash
# Check OpenStack resources
openstack server list --project <project_id>
openstack loadbalancer list --project <project_id>
openstack network list --project <project_id>

# Check k0s cluster status
k0sctl status --config ./k0sctl.yaml

# Test load balancer connectivity
curl -k https://<lb_floating_ip>:6443/version
```

## Cleanup

To destroy the infrastructure:

```bash
# First reset the k0s cluster (optional)
k0sctl reset --config ./k0sctl.yaml

# Then destroy infrastructure
tofu destroy
```

**Note**: This only destroys resources created by Terraform. The existing project remains intact.

## Advanced Configuration

### Custom Load Balancer Algorithm

```hcl
# In main.tf
loadbalancer_algorithm = "ROUND_ROBIN"  # or "SOURCE_IP"
```

### Different Network Configuration

```hcl
# In main.tf
subnet_cidr = "192.168.10.0/24"  # Different subnet
external_network_name = "external"  # Different external network
```

### Custom Node Configuration

```hcl
# Change node names and count
node_name_prefix = "my-k8s-node"
node_count = 5  # Creates my-k8s-node-0 through my-k8s-node-4

# Or use different network names
network_name = "production-k8s-network"
external_network_name = "external-network"
```