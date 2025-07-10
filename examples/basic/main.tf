module "k0sctl" {
  source = "../.."
  
  # Required variables
  external_network_name = var.external_network_name
  
  # Optional: Override auth_url if not using clouds.yaml
  # auth_url = var.auth_url
  
  # SSH key
  ssh_public_key_file = "~/.ssh/id_rsa.pub"
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

output "instances" {
  value = module.k0sctl.instances
}

output "ssh_commands" {
  value = module.k0sctl.ssh_commands
}

output "k0sctl_apply_command" {
  value = module.k0sctl.k0sctl_apply_command
}