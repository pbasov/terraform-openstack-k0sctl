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

# Deploy k0s cluster with load balancer in existing project
module "k0s_cluster" {
  source = "../.."
  
  # Use existing project (no tenant creation)
  create_project = false
  project_id     = var.existing_project_id
  create_user    = false
  
  # Network configuration
  network_name          = var.network_name
  subnet_cidr           = "10.0.2.0/24"
  external_network_name = var.external_network_name
  dns_servers          = var.dns_servers
  
  # SSH key configuration
  ssh_public_key_file = var.ssh_public_key_file
  
  # Instance configuration
  instances = {
    for i in range(var.node_count) : "${var.node_name_prefix}-${i}" => {
      flavor_name        = "m1.xlarge"
      image_name         = "ubuntu-noble-server-amd64"
      volume_size        = 50
      assign_floating_ip = true
    }
  }
  
  # Load balancer configuration
  create_loadbalancer = true
  controller_instance_keys = [for i in range(var.node_count) : "${var.node_name_prefix}-${i}"]
  loadbalancer_algorithm = "LEAST_CONNECTIONS"
  loadbalancer_provider = var.loadbalancer_provider
  
  # k0s configuration
  generate_k0sctl_config = true
  k0sctl_config_path     = "./k0sctl.yaml"
  k0s_version           = "1.33.2+k0s.0"
  
  # Output configurations
  output_clouds_yaml = true
  clouds_yaml_path   = "./clouds.yaml"
  
  # No application credentials needed for existing project
  create_app_credential = false
  
  tags = {
    Environment = "production"
    Project     = "k0s-existing-project-lb"
    ManagedBy   = "terraform"
  }
}

# Variables
variable "existing_project_id" {
  description = "ID of the existing OpenStack project"
  type        = string
}

variable "ssh_public_key_file" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "network_name" {
  description = "Name of the network to create"
  type        = string
  default     = "k0s-lb-existing-network"
}

variable "external_network_name" {
  description = "Name of the external network"
  type        = string
  default     = "public"
}

variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "node_name_prefix" {
  description = "Prefix for node names"
  type        = string
  default     = "k0s-node"
}

variable "node_count" {
  description = "Number of nodes to create"
  type        = number
  default     = 3
}

variable "loadbalancer_provider" {
  description = "OpenStack load balancer provider"
  type        = string
  default     = "amphorav2"
}

# Outputs
output "project_id" {
  description = "OpenStack project ID being used"
  value       = var.existing_project_id
}

output "loadbalancer_endpoint" {
  description = "Load balancer endpoint for Kubernetes API"
  value       = module.k0s_cluster.loadbalancer_floating_ip != null ? "https://${module.k0s_cluster.loadbalancer_floating_ip}:6443" : "Load balancer not created"
}

output "loadbalancer_vip" {
  description = "Load balancer VIP (internal network)"
  value       = module.k0s_cluster.loadbalancer_vip
}

output "k0s_api_endpoint" {
  description = "k0s API endpoint URL"
  value       = module.k0s_cluster.k0s_api_endpoint
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

output "instance_details" {
  description = "Detailed instance information"
  value = module.k0s_cluster.instances
}