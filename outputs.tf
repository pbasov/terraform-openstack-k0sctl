# Project outputs
output "project_id" {
  description = "The ID of the OpenStack project"
  value       = local.project_id
}

output "project_name" {
  description = "The name of the OpenStack project"
  value       = var.project_name
}

# User outputs
output "user_name" {
  description = "The name of the created user"
  value       = var.create_project && var.create_user ? module.tenant[0].user_name : null
}

output "user_password" {
  description = "The password of the created user"
  value       = var.create_project && var.create_user ? module.tenant[0].user_password : null
  sensitive   = true
}

# Network outputs
output "network_id" {
  description = "The ID of the created network"
  value       = module.infra.network_id
}

output "subnet_id" {
  description = "The ID of the created subnet"
  value       = module.infra.subnet_id
}

output "security_group_id" {
  description = "The ID of the created security group"
  value       = module.infra.security_group_id
}

# Instance outputs
output "instances" {
  description = "Information about all created instances"
  value       = module.infra.instances
}

output "instance_ips" {
  description = "Map of instance names to their private IPs"
  value       = module.infra.instance_ips
}

output "floating_ips" {
  description = "Map of instance names to their floating IPs"
  value       = module.infra.floating_ips
}

# SSH key output
output "ssh_keypair_name" {
  description = "Name of the SSH keypair used for instances"
  value       = module.infra.keypair_name
}

# Load balancer outputs
output "loadbalancer_id" {
  description = "The ID of the load balancer"
  value       = module.infra.loadbalancer_id
}

output "loadbalancer_vip" {
  description = "The VIP address of the load balancer"
  value       = module.infra.loadbalancer_vip
}

output "loadbalancer_floating_ip" {
  description = "The floating IP address of the load balancer"
  value       = module.infra.loadbalancer_floating_ip
}

output "k0s_api_endpoint" {
  description = "k0s API endpoint URL"
  value       = module.infra.loadbalancer_floating_ip != null ? "https://${module.infra.loadbalancer_floating_ip}:9443" : "Load balancer not created"
}

# Application credential outputs
output "app_credential_id" {
  description = "The ID of the application credential"
  value       = module.infra.app_credential_id
  sensitive   = true
}

output "app_credential_secret" {
  description = "The secret of the application credential"
  value       = module.infra.app_credential_secret
  sensitive   = true
}

# Configuration file outputs
output "k0sctl_config_path" {
  description = "Path to the generated k0sctl.yaml file"
  value       = var.generate_k0sctl_config ? var.k0sctl_config_path : null
}

output "clouds_yaml_path" {
  description = "Path to the generated clouds.yaml file"
  value       = var.output_clouds_yaml ? var.clouds_yaml_path : null
}

# Quick access commands
output "ssh_commands" {
  description = "SSH commands to access the instances"
  value = {
    for name, ip in module.infra.floating_ips :
    name => "ssh ubuntu@${ip}"
  }
}

output "k0sctl_apply_command" {
  description = "Command to apply the k0s cluster configuration"
  value       = var.generate_k0sctl_config ? "k0sctl apply --config ${var.k0sctl_config_path}" : null
}