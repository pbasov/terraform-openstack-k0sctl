terraform {
  required_version = ">= 1.0"
  
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.53.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

resource "openstack_identity_project_v3" "this" {
  name        = var.project_name
  description = var.project_description
  enabled     = var.enabled
  tags        = var.tags
  
  domain_id = var.project_domain_name
}

resource "random_password" "user_password" {
  count = var.create_user ? 1 : 0
  
  length           = var.password_length
  special          = var.password_special
  override_special = var.password_override_special
}

resource "openstack_identity_user_v3" "this" {
  count = var.create_user ? 1 : 0
  
  name               = var.user_name
  default_project_id = openstack_identity_project_v3.this.id
  password           = random_password.user_password[0].result
  enabled            = true
  
  domain_id = var.user_domain_name
}

data "openstack_identity_role_v3" "this" {
  count = var.create_user && var.assign_admin_role ? 1 : 0
  
  name = var.role_name
}

resource "openstack_identity_role_assignment_v3" "user_role" {
  count = var.create_user && var.assign_admin_role ? 1 : 0
  
  project_id = openstack_identity_project_v3.this.id
  user_id    = openstack_identity_user_v3.this[0].id
  role_id    = data.openstack_identity_role_v3.this[0].id
}