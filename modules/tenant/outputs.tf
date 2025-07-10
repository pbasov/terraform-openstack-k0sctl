output "project_id" {
  description = "The ID of the created project"
  value       = openstack_identity_project_v3.this.id
}

output "project_name" {
  description = "The name of the created project"
  value       = openstack_identity_project_v3.this.name
}

output "user_id" {
  description = "The ID of the created user"
  value       = var.create_user ? openstack_identity_user_v3.this[0].id : null
}

output "user_name" {
  description = "The name of the created user"
  value       = var.create_user ? openstack_identity_user_v3.this[0].name : null
}

output "user_password" {
  description = "The password of the created user"
  value       = var.create_user ? random_password.user_password[0].result : null
  sensitive   = true
}

output "role_assignment_id" {
  description = "The ID of the role assignment"
  value       = var.create_user && var.assign_admin_role ? openstack_identity_role_assignment_v3.user_role[0].id : null
}