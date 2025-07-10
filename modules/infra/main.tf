terraform {
  required_version = ">= 1.0"
  
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.53.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
  }
}

# Network resources
resource "openstack_networking_network_v2" "this" {
  name           = var.network_name
  admin_state_up = true
  tenant_id      = var.project_id
}

resource "openstack_networking_subnet_v2" "this" {
  name            = "${var.network_name}-subnet"
  network_id      = openstack_networking_network_v2.this.id
  cidr            = var.subnet_cidr
  ip_version      = 4
  dns_nameservers = var.dns_servers
  enable_dhcp     = var.enable_dhcp
  tenant_id       = var.project_id
}

# External network data source
data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

# Router
resource "openstack_networking_router_v2" "this" {
  count = var.create_router ? 1 : 0
  
  name                = coalesce(var.router_name, "${var.network_name}-router")
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
  tenant_id           = var.project_id
}

resource "openstack_networking_router_interface_v2" "this" {
  count = var.create_router ? 1 : 0
  
  router_id = openstack_networking_router_v2.this[0].id
  subnet_id = openstack_networking_subnet_v2.this.id
}

# Security group
resource "openstack_networking_secgroup_v2" "this" {
  name        = coalesce(var.security_group_name, "${var.network_name}-secgroup")
  description = "Security group for ${var.network_name} instances"
  tenant_id   = var.project_id
}

# Default security group rules
resource "openstack_networking_secgroup_rule_v2" "ssh" {
  count = var.enable_ssh ? 1 : 0
  
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.this.id
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  count = var.enable_icmp ? 1 : 0
  
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.this.id
}

resource "openstack_networking_secgroup_rule_v2" "internal" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = openstack_networking_secgroup_v2.this.id
  security_group_id = openstack_networking_secgroup_v2.this.id
}

resource "openstack_networking_secgroup_rule_v2" "pod_cidr" {
  count = var.enable_k8s_api ? 1 : 0
  
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = var.pod_cidr
  security_group_id = openstack_networking_secgroup_v2.this.id
}

resource "openstack_networking_secgroup_rule_v2" "k8s_api" {
  count = var.enable_k8s_api ? 1 : 0
  
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.this.id
}

resource "openstack_networking_secgroup_rule_v2" "k0s_api" {
  count = var.enable_k8s_api ? 1 : 0
  
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9443
  port_range_max    = 9443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.this.id
}

# Additional security rules
resource "openstack_networking_secgroup_rule_v2" "additional" {
  for_each = { for idx, rule in var.security_rules : idx => rule }
  
  direction         = each.value.direction
  ethertype         = each.value.ethertype
  protocol          = each.value.protocol
  port_range_min    = each.value.port_range_min
  port_range_max    = each.value.port_range_max
  remote_ip_prefix  = each.value.remote_ip_prefix
  remote_group_id   = each.value.remote_group_id
  security_group_id = openstack_networking_secgroup_v2.this.id
}

# SSH Keypair
resource "openstack_compute_keypair_v2" "this" {
  count = var.create_keypair ? 1 : 0
  
  name       = var.keypair_name
  public_key = var.ssh_public_key
}

# Get image data
data "openstack_images_image_v2" "this" {
  for_each = { 
    for k, v in var.instances : k => v.image_name 
    if v.image_name != null 
  }
  
  name        = each.value
  most_recent = true
}

# Network ports
resource "openstack_networking_port_v2" "this" {
  for_each = var.instances
  
  name               = "${each.key}-port"
  network_id         = openstack_networking_network_v2.this.id
  admin_state_up     = true
  security_group_ids = [openstack_networking_secgroup_v2.this.id]
  tenant_id          = var.project_id
  
  dynamic "allowed_address_pairs" {
    for_each = each.value.allowed_address_pairs != null ? each.value.allowed_address_pairs : [{ ip_address = "0.0.0.0/0" }]
    content {
      ip_address = allowed_address_pairs.value.ip_address
    }
  }
  
  depends_on = [
    openstack_networking_subnet_v2.this,
    openstack_networking_router_interface_v2.this
  ]
}

# Compute instances
resource "openstack_compute_instance_v2" "this" {
  for_each = var.instances
  
  name              = coalesce(each.value.name, each.key)
  flavor_name       = each.value.flavor_name
  key_pair          = var.create_keypair ? openstack_compute_keypair_v2.this[0].name : each.value.key_pair
  security_groups   = [openstack_networking_secgroup_v2.this.name]
  availability_zone = each.value.availability_zone
  user_data         = each.value.user_data
  metadata          = each.value.metadata
  
  block_device {
    uuid                  = each.value.image_id != null ? each.value.image_id : data.openstack_images_image_v2.this[each.key].id
    source_type           = "image"
    volume_size           = each.value.volume_size
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = each.value.delete_volume_on_termination
    volume_type           = each.value.volume_type
  }
  
  network {
    port = openstack_networking_port_v2.this[each.key].id
  }
  
  depends_on = [
    openstack_networking_port_v2.this
  ]
}

# Floating IPs
resource "openstack_networking_floatingip_v2" "this" {
  for_each = { 
    for k, v in var.instances : k => v 
    if v.assign_floating_ip 
  }
  
  pool      = data.openstack_networking_network_v2.external.name
  tenant_id = var.project_id
}

resource "openstack_networking_floatingip_associate_v2" "this" {
  for_each = { 
    for k, v in var.instances : k => v 
    if v.assign_floating_ip 
  }
  
  floating_ip = openstack_networking_floatingip_v2.this[each.key].address
  port_id     = openstack_compute_instance_v2.this[each.key].network[0].port
  
  depends_on = [
    openstack_compute_instance_v2.this,
    openstack_networking_router_interface_v2.this
  ]
}

# Application Credentials
resource "openstack_identity_application_credential_v3" "this" {
  count = var.create_app_credential ? 1 : 0
  
  name         = var.app_cred_name
  description  = var.app_cred_description
  roles        = var.app_cred_roles
  expires_at   = var.app_cred_expiration
  unrestricted = var.app_cred_unrestricted
}

# Generate k0sctl configuration
locals {
  k0sctl_instances = [
    for k, v in var.instances : {
      name        = coalesce(v.name, k)
      private_ip  = openstack_compute_instance_v2.this[k].access_ip_v4
      floating_ip = v.assign_floating_ip ? openstack_networking_floatingip_v2.this[k].address : null
    }
  ]
}

resource "local_file" "k0sctl_config" {
  count = var.generate_k0sctl_config ? 1 : 0
  
  content = templatefile("${path.module}/templates/k0sctl.yaml.tftpl", {
    instances      = local.k0sctl_instances
    k0s_version    = var.k0s_version
    dynamic_config = var.k0s_dynamic_config
  })
  
  filename = var.k0sctl_config_path
}