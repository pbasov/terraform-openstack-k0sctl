terraform {
  required_version = ">= 1.0"
  
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.53.0"
    }
  }
}

# Configure the OpenStack provider
provider "openstack" {
  # Authentication is configured via environment variables or clouds.yaml
  region = "RegionOne"
}

# Deploy k0s cluster with load balancer
module "k0s_cluster" {
  source = "../.."
  
  # Project configuration
  project_name = "k0s-lb-demo"
  
  # Network configuration
  network_name          = "k0s-lb-network"
  subnet_cidr           = "10.0.1.0/24"
  external_network_name = "public"
  
  # SSH key configuration
  ssh_public_key_file = "~/.ssh/id_rsa.pub"
  
  # Instance configuration - 3 controller+worker nodes and 2 dedicated workers
  instances = merge(
    # Controller+worker nodes
    {
      for i in range(3) : "k0s-ctrl-${i}" => {
        flavor_name        = "m1.xlarge"
        image_name         = "ubuntu-noble-server-amd64"
        volume_size        = 50
        assign_floating_ip = true
      }
    },
    # Dedicated worker nodes
    {
      for i in range(2) : "k0s-worker-${i}" => {
        flavor_name        = "m1.large"
        image_name         = "ubuntu-noble-server-amd64"
        volume_size        = 100
        assign_floating_ip = false
      }
    }
  )
  
  # Load balancer configuration
  create_loadbalancer = true
  controller_instance_keys = [for i in range(3) : "k0s-ctrl-${i}"]
  loadbalancer_algorithm = "LEAST_CONNECTIONS"
  
  # k0s configuration
  generate_k0sctl_config = true
  k0sctl_config_path     = "./k0sctl.yaml"
  k0s_version           = "1.33.2+k0s.0"
  
  # Output configurations
  output_clouds_yaml = true
  clouds_yaml_path   = "./clouds.yaml"
  
  tags = {
    Environment = "demo"
    Project     = "k0s-with-lb"
    ManagedBy   = "terraform"
  }
}

# Outputs
output "loadbalancer_endpoint" {
  description = "Load balancer endpoint for Kubernetes API"
  value       = module.k0s_cluster.loadbalancer_floating_ip != null ? "https://${module.k0s_cluster.loadbalancer_floating_ip}:6443" : "Load balancer not created"
}

output "ssh_commands" {
  description = "SSH commands to access instances"
  value       = module.k0s_cluster.ssh_commands
}

output "k0sctl_apply_command" {
  description = "Command to deploy the k0s cluster"
  value       = module.k0s_cluster.k0sctl_apply_command
}

output "kubeconfig_command" {
  description = "Command to get kubeconfig"
  value       = "k0sctl kubeconfig --config ./k0sctl.yaml > kubeconfig && export KUBECONFIG=$PWD/kubeconfig"
}