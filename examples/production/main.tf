module "k0sctl" {
  source = "../.."
  
  # OpenStack Configuration
  external_network_name = var.external_network_name
  region_name          = var.region_name
  
  # Optional: Override auth_url if not using clouds.yaml
  # auth_url = var.auth_url
  
  # Project Configuration
  project_name        = "${var.cluster_name}-project"
  project_description = "Production k0sctl cluster: ${var.cluster_name}"
  
  # Network Configuration
  network_name = "${var.cluster_name}-net"
  subnet_cidr  = var.subnet_cidr
  dns_servers  = var.dns_servers
  
  # Instance Configuration
  instances = {
    # 3 controller nodes for HA
    controller-1 = {
      flavor_name = var.controller_flavor
      image_name  = var.os_image
      volume_size = var.controller_volume_size
      volume_type = var.volume_type
    }
    controller-2 = {
      flavor_name = var.controller_flavor
      image_name  = var.os_image
      volume_size = var.controller_volume_size
      volume_type = var.volume_type
    }
    controller-3 = {
      flavor_name = var.controller_flavor
      image_name  = var.os_image
      volume_size = var.controller_volume_size
      volume_type = var.volume_type
    }
    # Worker nodes
    worker-1 = {
      flavor_name = var.worker_flavor
      image_name  = var.os_image
      volume_size = var.worker_volume_size
      volume_type = var.volume_type
    }
    worker-2 = {
      flavor_name = var.worker_flavor
      image_name  = var.os_image
      volume_size = var.worker_volume_size
      volume_type = var.volume_type
    }
    worker-3 = {
      flavor_name = var.worker_flavor
      image_name  = var.os_image
      volume_size = var.worker_volume_size
      volume_type = var.volume_type
    }
  }
  
  # SSH Configuration
  ssh_public_key_file = var.ssh_public_key_file
  
  # k0s Configuration
  k0s_version            = var.k0s_version
  generate_k0sctl_config = true
  k0sctl_config_path    = "${path.module}/k0sctl.yaml"
  
  # Application Credentials
  create_app_credential = true
  app_credential_name   = "${var.cluster_name}-app-cred"
  
  # Output Configuration
  output_clouds_yaml = true
  clouds_yaml_path   = "${path.module}/clouds.yaml"
  
  # Tags
  tags = merge(var.tags, {
    ClusterName = var.cluster_name
    Environment = "production"
  })
}

# Variables
variable "cluster_name" {
  description = "Name of the k0sctl cluster"
  type        = string
}

# Variable for auth_url is optional - typically provided via clouds.yaml
# variable "auth_url" {
#   description = "OpenStack authentication URL"
#   type        = string
# }

variable "external_network_name" {
  description = "Name of the external network"
  type        = string
}

variable "region_name" {
  description = "OpenStack region name"
  type        = string
  default     = "RegionOne"
}

variable "subnet_cidr" {
  description = "CIDR for the cluster subnet"
  type        = string
  default     = "10.100.0.0/24"
}

variable "dns_servers" {
  description = "DNS servers for the subnet"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "os_image" {
  description = "Operating system image to use"
  type        = string
  default     = "ubuntu-22.04"
}

variable "controller_flavor" {
  description = "Flavor for controller nodes"
  type        = string
  default     = "m1.large"
}

variable "controller_volume_size" {
  description = "Volume size for controller nodes (GB)"
  type        = number
  default     = 100
}

variable "worker_flavor" {
  description = "Flavor for worker nodes"
  type        = string
  default     = "m1.xlarge"
}

variable "worker_volume_size" {
  description = "Volume size for worker nodes (GB)"
  type        = number
  default     = 200
}

variable "volume_type" {
  description = "Volume type to use"
  type        = string
  default     = "ssd"
}

variable "k0s_version" {
  description = "k0s version to deploy"
  type        = string
  default     = "1.29.1+k0s.0"
}

variable "ssh_public_key_file" {
  description = "Path to SSH public key file"
  type        = string
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

# Outputs
output "project_id" {
  value = module.k0sctl.project_id
}

output "instances" {
  value = module.k0sctl.instances
}

output "ssh_commands" {
  value = module.k0sctl.ssh_commands
}

output "k0sctl_apply_command" {
  value = module.k0sctl.k0sctl_apply_command
}

output "kubeconfig_command" {
  value = "k0sctl kubeconfig --config ${module.k0sctl.k0sctl_config_path} > kubeconfig"
}