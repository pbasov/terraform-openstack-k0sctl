# Existing Project k0sctl Deployment Example

This example shows how to deploy k0sctl infrastructure in an existing OpenStack project.

## Use Case

This configuration is useful when:
- You have an existing OpenStack project with quotas and permissions set up
- You want to deploy k0sctl alongside other resources
- Project creation is handled by a separate process/team

## Prerequisites

1. An existing OpenStack project ID
2. Appropriate permissions in the project to create:
   - Networks, subnets, routers
   - Security groups and rules
   - Instances and volumes
   - Floating IPs
3. OpenStack credentials with access to the project

## Usage

1. Configure your OpenStack credentials:
   ```bash
   export OS_CLOUD=mycloud
   # OR use environment variables
   ```

2. Copy and update terraform.tfvars:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit with your project ID and configuration
   ```

3. Deploy:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## What Gets Created

- Network infrastructure (network, subnet, router)
- Security group with Kubernetes rules
- 3 instances with floating IPs
- k0sctl.yaml configuration

Note: This example does NOT create:
- New OpenStack project
- New user accounts
- Application credentials

## Customization

To use existing network infrastructure, you would need to modify the infrastructure module to accept existing network/subnet IDs instead of creating new ones.