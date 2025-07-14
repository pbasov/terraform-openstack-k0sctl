# K0s Cluster with Load Balancer Example

This example demonstrates how to deploy a k0s Kubernetes cluster with a load balancer in front of the controllers using the terraform-openstack-k0ctl module.

## Architecture

This configuration creates:
- 3 controller nodes with floating IPs
- 2 worker nodes without floating IPs
- An OpenStack Octavia load balancer with:
  - TCP listener on port 6443 (Kubernetes API)
  - Health monitoring
  - Round-robin load balancing
  - Floating IP for external access

## Prerequisites

1. OpenStack credentials configured
2. SSH public key available at `~/.ssh/id_rsa.pub`
3. Sufficient OpenStack quotas for:
   - 5 instances
   - 4 floating IPs (3 for controllers + 1 for load balancer)
   - 1 load balancer with pool and members
   - Network resources

## Usage

1. Clone the repository and navigate to this example:
   ```bash
   cd examples/with-loadbalancer
   ```

2. Review and modify the configuration:
   ```bash
   vim main.tf
   ```

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. Deploy the k0s cluster:
   ```bash
   k0sctl apply --config ./k0sctl.yaml
   ```

5. Get the kubeconfig:
   ```bash
   k0sctl kubeconfig --config ./k0sctl.yaml > kubeconfig
   export KUBECONFIG=$PWD/kubeconfig
   ```

6. Test the cluster:
   ```bash
   kubectl get nodes
   kubectl cluster-info
   ```

## Configuration Details

### Load Balancer Settings

- **Algorithm**: `LEAST_CONNECTIONS` (can be changed to `ROUND_ROBIN` or `SOURCE_IP`)
- **Health Monitor**: TCP health checks on port 6443
- **Pool Members**: All controller instances (k0s-ctrl-0, k0s-ctrl-1, k0s-ctrl-2)

### Instance Configuration

The example uses:
- **Controllers**: 3x m1.xlarge instances with 50GB volumes (k0s-ctrl-0, k0s-ctrl-1, k0s-ctrl-2)
- **Workers**: 2x m1.large instances with 100GB volumes (k0s-worker-0, k0s-worker-1)
- **Floating IPs**: Assigned to controllers for SSH access

### Generated Files

- `k0sctl.yaml`: k0s cluster configuration with load balancer endpoint
- `clouds.yaml`: OpenStack client configuration

## Accessing the Cluster

After deployment, the Kubernetes API is available at:
- **External**: `https://<load_balancer_floating_ip>:6443`
- **Internal**: `https://<load_balancer_vip>:6443`

The generated `k0sctl.yaml` automatically configures the cluster to use the load balancer endpoint.

## Load Balancer Benefits

1. **High Availability**: API requests are distributed across all controllers
2. **Fault Tolerance**: If one controller fails, others continue serving
3. **Single Endpoint**: Clients connect to one stable IP address
4. **Health Monitoring**: Unhealthy controllers are automatically removed from rotation

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Troubleshooting

1. **Load Balancer Creation Fails**: Check OpenStack quotas and Octavia service availability
2. **Health Monitor Issues**: Ensure controllers are accepting connections on port 6443
3. **API Access Problems**: Verify security groups allow traffic on port 6443
4. **k0sctl Connection Issues**: Check that the load balancer floating IP is accessible

## Advanced Configuration

You can customize the load balancer by modifying these variables:

```hcl
# Load balancer configuration
create_loadbalancer = true
controller_instance_keys = ["controller-1", "controller-2", "controller-3"]
loadbalancer_algorithm = "ROUND_ROBIN"  # or "SOURCE_IP"
```

For production use, consider:
- Using dedicated controller nodes (without worker role)
- Adding more health monitor settings
- Implementing network policies for security
- Setting up monitoring and logging