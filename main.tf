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
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
  }
}

provider "openstack" {
  auth_url    = var.auth_url != "" ? var.auth_url : null
  region_name = var.region_name
}

provider "random" {}
provider "local" {}

# Load SSH public key if file path is provided
locals {
  ssh_public_key = coalesce(
    var.ssh_public_key,
    var.ssh_public_key_file != "" ? file(var.ssh_public_key_file) : ""
  )
  
  project_id = var.create_project ? module.tenant[0].project_id : var.project_id
}

# Tenant/Project creation
module "tenant" {
  count  = var.create_project ? 1 : 0
  source = "./modules/tenant"
  
  project_name        = var.project_name
  project_description = var.project_description
  user_name          = var.user_name
  create_user        = var.create_user
  password_length    = var.user_password_length
  
  # Pass through auth configuration
  user_domain_name    = "Default"
  project_domain_name = "Default"
}

# Infrastructure creation
module "infra" {
  source = "./modules/infra"
  
  project_id            = local.project_id
  network_name          = var.network_name
  subnet_cidr           = var.subnet_cidr
  external_network_name = var.external_network_name
  dns_servers          = var.dns_servers
  
  # Instance configuration
  instances = var.instances
  
  # SSH configuration
  create_keypair = local.ssh_public_key != ""
  keypair_name   = "${var.project_name}-key"
  ssh_public_key = local.ssh_public_key
  
  # k0s configuration
  generate_k0sctl_config = var.generate_k0sctl_config
  k0sctl_config_path    = var.k0sctl_config_path
  k0s_version           = var.k0s_version
  
  # Application credential
  create_app_credential = var.create_app_credential
  app_cred_name        = var.app_credential_name
  
  # Tags
  tags = var.tags
  
  depends_on = [module.tenant]
}

# Generate clouds.yaml file
resource "local_file" "clouds_yaml" {
  count = var.output_clouds_yaml ? 1 : 0
  
  content = templatefile("${path.module}/templates/clouds.yaml.tftpl", {
    cloud_name     = var.project_name
    auth_url       = var.auth_url
    region_name    = var.region_name
    project_id     = local.project_id
    project_name   = var.project_name
    
    # User credentials (if created)
    has_user_creds = var.create_project && var.create_user
    username       = var.create_project && var.create_user ? module.tenant[0].user_name : ""
    password       = var.create_project && var.create_user ? module.tenant[0].user_password : ""
    
    # Application credentials (if created)
    has_app_creds  = var.create_app_credential
    app_cred_id    = var.create_app_credential ? module.infra.app_credential_id : ""
    app_cred_secret = var.create_app_credential ? module.infra.app_credential_secret : ""
  })
  
  filename = var.clouds_yaml_path
  
  depends_on = [module.infra]
}