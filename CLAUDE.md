# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Terraform module for deploying k0s Kubernetes clusters on OpenStack using k0sctl. The module provides a complete infrastructure-as-code solution for creating and managing Kubernetes clusters including:
- OpenStack project/tenant management
- Network infrastructure (VPC, subnets, routers)
- Security groups with Kubernetes-specific rules
- Compute instances with persistent volumes
- Automatic k0sctl configuration generation
- Application credentials for automation

## Prerequisites

Before using this module, ensure you have:
1. OpenStack credentials configured via one of:
   - `clouds.yaml` file (recommended)
   - Environment variables (`OS_AUTH_URL`, `OS_PROJECT_ID`, etc.)
   - Direct variable input (not recommended)
2. Sufficient OpenStack quotas for your deployment
3. An SSH key pair for instance access

## Common Commands

```bash
# Set up OpenStack credentials (if using clouds.yaml)
export OS_CLOUD=mycloud

# Initialize Terraform providers
terraform init

# Plan infrastructure changes
terraform plan -out=tfplan

# Apply infrastructure
terraform apply tfplan

# Deploy k0s cluster
k0sctl apply --config ./k0sctl.yaml

# Get kubeconfig
k0sctl kubeconfig --config ./k0sctl.yaml > kubeconfig
export KUBECONFIG=$PWD/kubeconfig

# Access cluster
kubectl get nodes

# Check cluster status
k0sctl status --config ./k0sctl.yaml

# Upgrade k0s version
k0sctl upgrade --config ./k0sctl.yaml

# Destroy k0s cluster (keeps infrastructure)
k0sctl reset --config ./k0sctl.yaml

# Destroy infrastructure
terraform destroy
```

## Architecture

The module follows a hierarchical structure:

1. **Root Module** (`/`) - Orchestrates the deployment by:
   - Configuring OpenStack provider
   - Calling tenant module to create/manage projects
   - Calling infra module to provision resources
   - Generating `clouds.yaml` and `k0sctl.yaml` files

2. **Tenant Module** (`modules/tenant/`) - Manages OpenStack tenancy:
   - Creates OpenStack projects
   - Creates users with auto-generated passwords
   - Assigns admin roles

3. **Infrastructure Module** (`modules/infra/`) - Provisions all resources:
   - Network: Private network, subnet, router, floating IPs
   - Security: Security groups with Kubernetes-specific rules
   - Compute: Instances with boot-from-volume
   - Configuration: k0sctl YAML for cluster deployment

## Key Design Patterns

1. **Instance Configuration**: Uses a map-based approach for defining instances, allowing flexible node counts and configurations:
   ```hcl
   instances = {
     "controller-1" = { 
       flavor_name = "m1.medium"
       image_name = "ubuntu-22.04"
       volume_size = 50
       assign_floating_ip = true 
     }
     "worker-1" = { 
       flavor_name = "m1.large"
       image_name = "ubuntu-22.04"
       volume_size = 100
       assign_floating_ip = false 
     }
   }
   ```

2. **SSH Key Handling**: Supports both file path and direct key content:
   ```hcl
   ssh_public_key_file = "~/.ssh/id_ed25519.pub"  # OR
   ssh_public_key = "ssh-ed25519 AAAA..."
   ```

3. **Conditional Resource Creation**: 
   - Create new project: `create_project = true` (default)
   - Use existing project: `create_project = false` + `project_id = "existing-id"`

4. **Security Groups**: Pre-configured with essential Kubernetes ports:
   - SSH (22)
   - Kubernetes API (6443)
   - k0s API (9443)
   - kubelet (10250)
   - konnectivity (8132)
   - Calico/VXLAN overlay (4789)
   - Pod-to-pod communication within subnet

## Important Considerations

- All resources are tagged with deployment name for easy identification
- Floating IPs are optional per instance for cost optimization
- Boot-from-volume is used for all instances (persistent storage)
- Password for created users is auto-generated and available in outputs
- k0sctl.yaml is generated automatically based on infrastructure
- The module supports both creating new OpenStack projects and using existing ones

## Testing and Validation

When making changes:
1. Validate Terraform configuration: `terraform validate`
2. Format code: `terraform fmt -recursive`
3. Check the examples directory for reference implementations
4. Ensure generated k0sctl.yaml is valid by reviewing the template
5. Test with minimal configuration first before scaling up

## Module Outputs

Key outputs available after deployment:
- `ssh_commands` - Ready-to-use SSH commands for each instance
- `controller_ips` - Private IPs of controller nodes
- `worker_ips` - Private IPs of worker nodes
- `floating_ips` - Public IPs assigned to instances
- `clouds_yaml_path` - Path to generated OpenStack client config
- `k0sctl_yaml_path` - Path to generated k0s cluster config
- `project_id` - The ID of the created/used project
- `user_password` - Generated password for created user (sensitive)
- `app_credential_secret` - Application credential secret (sensitive)

## Troubleshooting

Common issues and solutions:

1. **Quota Errors**: Check OpenStack project quotas for instances, volumes, floating IPs
2. **Network Conflicts**: Ensure subnet CIDR doesn't overlap with existing networks
3. **SSH Access**: Verify security group rules and floating IP assignments
4. **k0sctl Failures**: Check instance connectivity and SSH key permissions
5. **Volume Boot Issues**: Ensure the image supports boot-from-volume

## Examples

The repository includes three example configurations:

1. **basic/**: Minimal configuration with defaults
2. **production/**: Full HA setup with 3 controllers and 3 workers
3. **existing-project/**: Deploy into an existing OpenStack project

Each example includes its own README with specific instructions.