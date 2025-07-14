# Terraform OpenStack k0sctl Module

This Terraform module creates a complete OpenStack infrastructure for deploying k0sctl Kubernetes clusters using k0s.

## Features

- **Project Management**: Optionally creates a new OpenStack project with user and permissions
- **Network Infrastructure**: Creates isolated network with router, security groups, and floating IPs
- **Compute Instances**: Flexible instance configuration with boot-from-volume support
- **Security**: Configurable security group rules with sensible defaults for Kubernetes
- **k0s Integration**: Automatically generates k0sctl configuration for cluster deployment
- **Application Credentials**: Optionally creates OpenStack application credentials for programmatic access
- **Output Management**: Generates clouds.yaml for easy OpenStack CLI/SDK usage

## Usage

### Basic Usage

```hcl
module "k0sctl" {
  source = "path/to/terraform-openstack-k0sctl"
  
  # Required: External network for floating IPs
  external_network_name = "public"
  
  # Optional: Override auth_url if not using clouds.yaml or environment variables
  # auth_url = "https://openstack.example.com:5000/v3"
  
  # Optional: Use existing project instead of creating new one
  # create_project = false
  # project_id     = "existing-project-id"
  
  # SSH Key (one of these is required)
  ssh_public_key_file = "~/.ssh/id_rsa.pub"
  # OR
  # ssh_public_key = "ssh-rsa AAAAB3..."
}
```

### Advanced Usage

```hcl
module "k0sctl" {
  source = "path/to/terraform-openstack-k0sctl"
  
  # OpenStack Configuration
  external_network_name = "public"
  region_name          = "RegionOne"
  
  # Optional: Override auth_url if not using clouds.yaml
  # auth_url = "https://openstack.example.com:5000/v3"
  
  # Project Configuration
  project_name        = "my-k0sctl-cluster"
  project_description = "Production k0sctl cluster"
  
  # Network Configuration
  network_name = "k0sctl-prod"
  subnet_cidr  = "10.100.0.0/24"
  dns_servers  = ["10.0.0.10", "10.0.0.11"]
  
  # Instance Configuration
  instances = {
    controller-1 = {
      flavor_name = "m1.large"
      image_name  = "ubuntu-noble-server-amd64"
      volume_size = 100
      volume_type = "ssd"
    }
    controller-2 = {
      flavor_name = "m1.large"
      image_name  = "ubuntu-noble-server-amd64"
      volume_size = 100
      volume_type = "ssd"
    }
    controller-3 = {
      flavor_name = "m1.large"
      image_name  = "ubuntu-noble-server-amd64"
      volume_size = 100
      volume_type = "ssd"
    }
    worker-1 = {
      flavor_name = "m1.xlarge"
      image_name  = "ubuntu-noble-server-amd64"
      volume_size = 200
      volume_type = "ssd"
    }
    worker-2 = {
      flavor_name = "m1.xlarge"
      image_name  = "ubuntu-noble-server-amd64"
      volume_size = 200
      volume_type = "ssd"
    }
  }
  
  # SSH Configuration
  ssh_public_key_file = "~/.ssh/k0sctl.pub"
  
  # k0s Configuration
  k0s_version            = "1.33.2+k0s.0"
  generate_k0sctl_config = true
  k0sctl_config_path    = "./configs/k0sctl.yaml"
  
  # Application Credentials
  create_app_credential = true
  app_credential_name   = "k0sctl-automation"
  
  # Output Configuration
  output_clouds_yaml = true
  clouds_yaml_path   = "./configs/clouds.yaml"
  
  # Tags
  tags = {
    Environment = "production"
    Team        = "platform"
    Project     = "k0sctl"
  }
}
```

## Module Structure

```
terraform-openstack-k0sctl/
├── main.tf                 # Root module orchestration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── versions.tf             # Provider requirements
├── README.md               # This file
├── templates/              # Template files
│   └── clouds.yaml.tftpl   # clouds.yaml template
├── modules/
│   ├── tenant/             # Project/tenant management submodule
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── versions.tf
│   │   └── README.md
│   └── infra/              # Infrastructure submodule
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── versions.tf
│       ├── README.md
│       └── templates/
│           └── k0sctl.yaml.tftpl
└── examples/               # Example configurations
    ├── basic/
    ├── production/
    └── existing-project/
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| openstack | >= 1.53.0 |
| random | >= 3.5.0 |
| local | >= 2.4.0 |

## Deployment Flow

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan the deployment**:
   ```bash
   terraform plan -out=tfplan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply tfplan
   ```

4. **Deploy k0s cluster** (if k0sctl config was generated):
   ```bash
   k0sctl apply --config ./k0sctl.yaml
   ```

5. **Access the cluster**:
   ```bash
   k0sctl kubeconfig --config ./k0sctl.yaml > kubeconfig
   export KUBECONFIG=$PWD/kubeconfig
   kubectl get nodes
   ```

## Security Considerations

1. **Sensitive Outputs**: User passwords and application credentials are marked as sensitive
2. **Security Groups**: Default rules allow SSH, ICMP, and Kubernetes API access. Customize as needed
3. **Network Isolation**: Each deployment creates an isolated network with its own router
4. **SSH Keys**: Always use strong SSH keys and rotate them regularly

## Troubleshooting

### Common Issues

1. **External Network Not Found**:
   - Ensure the `external_network_name` matches exactly
   - Check you have permissions to access the external network

2. **Quota Exceeded**:
   - Check your project quotas for instances, floating IPs, and volumes
   - Reduce the number of instances or request quota increase

3. **Image Not Found**:
   - Verify image names in the `instances` configuration
   - Use `openstack image list` to see available images

4. **Authentication Failed**:
   - Ensure `OS_CLOUD` environment variable is set correctly
   - Verify your clouds.yaml configuration

## Examples

See the `examples/` directory for complete working examples:

- `basic/` - Minimal configuration with defaults
- `production/` - Production-ready multi-node cluster
- `existing-project/` - Using an existing OpenStack project

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

[Specify your license here]