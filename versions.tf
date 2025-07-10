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