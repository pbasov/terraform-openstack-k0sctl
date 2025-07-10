output "network_id" {
  description = "The ID of the created network"
  value       = openstack_networking_network_v2.this.id
}

output "subnet_id" {
  description = "The ID of the created subnet"
  value       = openstack_networking_subnet_v2.this.id
}

output "router_id" {
  description = "The ID of the created router"
  value       = var.create_router ? openstack_networking_router_v2.this[0].id : null
}

output "security_group_id" {
  description = "The ID of the created security group"
  value       = openstack_networking_secgroup_v2.this.id
}

output "instance_ids" {
  description = "Map of instance names to their IDs"
  value       = { for k, v in openstack_compute_instance_v2.this : k => v.id }
}

output "instance_ips" {
  description = "Map of instance names to their private IPs"
  value       = { for k, v in openstack_compute_instance_v2.this : k => v.access_ip_v4 }
}

output "floating_ips" {
  description = "Map of instance names to their floating IPs"
  value = {
    for k, v in var.instances :
    k => v.assign_floating_ip ? openstack_networking_floatingip_v2.this[k].address : null
  }
}

output "instance_ports" {
  description = "Map of instance names to their port IDs"
  value       = { for k, v in openstack_networking_port_v2.this : k => v.id }
}

output "keypair_name" {
  description = "Name of the SSH keypair used"
  value       = var.create_keypair ? openstack_compute_keypair_v2.this[0].name : var.keypair_name
}

output "app_credential_id" {
  description = "The ID of the application credential"
  value       = var.create_app_credential ? openstack_identity_application_credential_v3.this[0].id : null
  sensitive   = true
}

output "app_credential_secret" {
  description = "The secret of the application credential"
  value       = var.create_app_credential ? openstack_identity_application_credential_v3.this[0].secret : null
  sensitive   = true
}

output "instances" {
  description = "Detailed information about all instances"
  value = {
    for k, v in openstack_compute_instance_v2.this : k => {
      id         = v.id
      name       = v.name
      private_ip = v.access_ip_v4
      floating_ip = var.instances[k].assign_floating_ip ? openstack_networking_floatingip_v2.this[k].address : null
      flavor     = v.flavor_name
      az         = v.availability_zone
    }
  }
}