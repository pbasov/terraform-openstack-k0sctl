module "k0sctl" {
  source = "../.."
  
  # Required variables
  auth_url              = var.auth_url
  external_network_name = var.external_network_name
  
  # SSH key
  ssh_public_key_file = "~/.ssh/id_rsa.pub"
}

variable "auth_url" {
  description = "OpenStack authentication URL"
  type        = string
}

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