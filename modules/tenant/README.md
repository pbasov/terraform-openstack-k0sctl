# OpenStack Tenant Module

This module creates an OpenStack project (tenant) with an optional user and role assignment.

## Usage

```hcl
module "tenant" {
  source = "./modules/tenant"
  
  project_name        = "my-k0sctl-project"
  project_description = "Project for k0sctl cluster"
  user_name          = "k0sctl-admin"
  
  # Optional
  create_user       = true
  assign_admin_role = true
  password_length   = 20
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| openstack | >= 1.53.0 |
| random | >= 3.5.0 |

## Providers

| Name | Version |
|------|---------|
| openstack | >= 1.53.0 |
| random | >= 3.5.0 |

## Resources

| Name | Type |
|------|------|
| openstack_identity_project_v3.this | resource |
| openstack_identity_user_v3.this | resource |
| random_password.user_password | resource |
| openstack_identity_role_assignment_v3.user_role | resource |
| openstack_identity_role_v3.this | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the OpenStack project/tenant | `string` | n/a | yes |
| user_name | Name of the user to create | `string` | n/a | yes |
| project_description | Description of the OpenStack project/tenant | `string` | `""` | no |
| create_user | Whether to create a user for the project | `bool` | `true` | no |
| assign_admin_role | Whether to assign admin role to the user | `bool` | `true` | no |
| role_name | Role to assign to the user | `string` | `"admin"` | no |
| password_length | Length of the generated password | `number` | `16` | no |
| password_special | Include special characters in password | `bool` | `false` | no |
| password_override_special | Special characters to use in password | `string` | `"_%@"` | no |
| user_domain_name | User domain name in OpenStack | `string` | `"Default"` | no |
| project_domain_name | Project domain name in OpenStack | `string` | `"Default"` | no |
| tags | Tags to apply to the project | `list(string)` | `[]` | no |
| enabled | Whether the project is enabled | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| project_id | The ID of the created project |
| project_name | The name of the created project |
| user_id | The ID of the created user |
| user_name | The name of the created user |
| user_password | The password of the created user (sensitive) |
| role_assignment_id | The ID of the role assignment |