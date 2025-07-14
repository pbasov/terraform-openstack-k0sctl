module "k0sctl" {
  source = "../.."
  
  # OpenStack Configuration
  external_network_name = var.external_network_name
  
  # Optional: Override auth_url if not using clouds.yaml
  # auth_url = var.auth_url
  
  # Use existing project
  create_project = false
  project_id     = var.project_id
  
  # Network Configuration (using defaults)
  
  # Simple 3-node cluster
  instances = {
    node-1 = {
      flavor_name = var.flavor_name
      image_name  = var.image_name
      volume_size = var.volume_size
    }
    node-2 = {
      flavor_name = var.flavor_name
      image_name  = var.image_name
      volume_size = var.volume_size
    }
    node-3 = {
      flavor_name = var.flavor_name
      image_name  = var.image_name
      volume_size = var.volume_size
    }
  }
  
  # SSH Configuration
  ssh_public_key = var.ssh_public_key
  
  # Don't create app credentials in existing project
  create_app_credential = false
  
  # k0s Configuration
  generate_k0sctl_config = true
}

# Variables
# Variable for auth_url is optional - typically provided via clouds.yaml
# variable "auth_url" {
#   description = "OpenStack authentication URL"
#   type        = string
# }

variable "external_network_name" {
  description = "Name of the external network"
  type        = string
}

variable "project_id" {
  description = "Existing OpenStack project ID"
  type        = string
}

variable "flavor_name" {
  description = "Flavor to use for all nodes"
  type        = string
  default     = "m1.xlarge"
}

variable "image_name" {
  description = "Image to use for all nodes"
  type        = string
  default     = "ubuntu-noble-server-amd64"
}

variable "volume_size" {
  description = "Volume size for all nodes (GB)"
  type        = number
  default     = 50
}

variable "ssh_public_key" {
  description = "SSH public key for accessing nodes"
  type        = string
}

# Outputs
output "network_id" {
  value = module.k0sctl.network_id
}

output "instances" {
  value = module.k0sctl.instances
}

output "ssh_commands" {
  value = module.k0sctl.ssh_commands
}