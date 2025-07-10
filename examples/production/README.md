# Production k0sctl Deployment Example

This example demonstrates a production-ready k0sctl cluster deployment with:
- High availability (3 controller nodes)
- Multiple worker nodes
- Custom networking configuration
- Persistent storage with SSD volumes
- Application credentials for automation
- Comprehensive tagging

## Prerequisites

1. OpenStack credentials configured
2. SSH keypair for production use
3. Sufficient quota for 6 instances and associated resources

## Architecture

```
┌─────────────────────────────────────────────┐
│           External Network                   │
└─────────────────────────────────────────────┘
                    │
              ┌─────┴─────┐
              │  Router   │
              └─────┬─────┘
                    │
         ┌──────────┴──────────┐
         │   10.100.0.0/22     │
         │  Cluster Network    │
         └──────────┬──────────┘
                    │
    ┌───────────────┼───────────────┐
    │               │               │
┌───┴───┐     ┌────┴────┐     ┌────┴────┐
│ ctrl-1│     │ ctrl-2  │     │ ctrl-3  │
│ 100GB │     │ 100GB   │     │ 100GB   │
└───────┘     └─────────┘     └─────────┘
    │               │               │
┌───┴───┐     ┌────┴────┐     ┌────┴────┐
│work-1 │     │ work-2  │     │ work-3  │
│ 500GB │     │ 500GB   │     │ 500GB   │
└───────┘     └─────────┘     └─────────┘
```

## Usage

1. Copy and configure terraform.tfvars:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your production values
   ```

2. Review the plan:
   ```bash
   terraform init
   terraform plan -out=prod.tfplan
   ```

3. Apply the configuration:
   ```bash
   terraform apply prod.tfplan
   ```

4. Deploy k0s cluster:
   ```bash
   k0sctl apply --config ./k0sctl.yaml
   ```

5. Get kubeconfig:
   ```bash
   k0sctl kubeconfig --config ./k0sctl.yaml > kubeconfig
   export KUBECONFIG=$PWD/kubeconfig
   kubectl get nodes
   ```

## Post-Deployment

1. **Backup Configuration**: Save the generated `clouds.yaml` and `k0sctl.yaml` files
2. **Monitor Resources**: Check OpenStack dashboard for resource usage
3. **Configure Monitoring**: Deploy your monitoring stack to the cluster
4. **Set up Backups**: Configure regular backups of the control plane

## Customization

### Scaling Workers

To add more workers, update the `instances` map in main.tf:

```hcl
worker-4 = {
  flavor_name = var.worker_flavor
  image_name  = var.os_image
  volume_size = var.worker_volume_size
  volume_type = var.volume_type
}
```

### Network Policies

Additional security rules can be added via the infrastructure module's `security_rules` variable.

## Troubleshooting

See the main module README for common issues and solutions.