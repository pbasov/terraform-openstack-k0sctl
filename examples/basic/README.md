# Basic k0sctl Deployment Example

This example shows the minimal configuration required to deploy a k0sctl cluster.

## Prerequisites

1. OpenStack credentials configured (via clouds.yaml or environment variables)
2. SSH public key at `~/.ssh/id_rsa.pub`

## Usage

1. Copy and update the terraform.tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. Deploy k0s:
   ```bash
   k0sctl apply --config ./k0sctl.yaml
   ```

## What Gets Created

- New OpenStack project named "k0sctl"
- Network with subnet (192.168.100.0/24)
- Router connected to external network
- Security group with k8s-related rules
- 3 instances (1 controller + 2 workers)
- Floating IPs for all instances
- k0sctl.yaml configuration file
- clouds.yaml for OpenStack access