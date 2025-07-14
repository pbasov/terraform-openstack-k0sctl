# OpenStack Infrastructure Module

This module creates OpenStack infrastructure for k0sctl clusters including networking, compute instances, security groups, and optional k0sctl configuration.

## Usage

```hcl
module "infra" {
  source = "./modules/infra"
  
  project_id            = module.tenant.project_id
  network_name          = "k0sctl-net"
  external_network_name = "Public_Network"
  
  # Instance configuration
  instances = {
    controller-1 = {
      flavor_name = "m1.xlarge"
      image_name  = "ubuntu-noble-server-amd64"
      volume_size = 50
    }
    worker-1 = {
      flavor_name = "m1.large"
      image_name  = "ubuntu-noble-server-amd64"
      volume_size = 100
    }
  }
  
  # SSH key
  create_keypair = true
  ssh_public_key = file("~/.ssh/id_rsa.pub")
  
  # Generate k0sctl config
  generate_k0sctl_config = true
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| openstack | >= 1.53.0 |
| local | >= 2.4.0 |

## Providers

| Name | Version |
|------|---------|
| openstack | >= 1.53.0 |
| local | >= 2.4.0 |

## Resources

| Name | Type |
|------|------|
| openstack_networking_network_v2.this | resource |
| openstack_networking_subnet_v2.this | resource |
| openstack_networking_router_v2.this | resource |
| openstack_networking_router_interface_v2.this | resource |
| openstack_networking_secgroup_v2.this | resource |
| openstack_networking_secgroup_rule_v2.* | resource |
| openstack_networking_port_v2.this | resource |
| openstack_networking_floatingip_v2.this | resource |
| openstack_networking_floatingip_associate_v2.this | resource |
| openstack_compute_keypair_v2.this | resource |
| openstack_compute_instance_v2.this | resource |
| openstack_identity_application_credential_v3.this | resource |
| local_file.k0sctl_config | resource |
| openstack_networking_network_v2.external | data source |
| openstack_images_image_v2.this | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The OpenStack project ID to create resources in | `string` | n/a | yes |
| external_network_name | Name of the external network to connect to | `string` | n/a | yes |
| instances | Map of instances to create | `map(object)` | n/a | yes |
| network_name | Name of the network to create | `string` | `"k0sctl-net"` | no |
| subnet_cidr | CIDR for the subnet | `string` | `"192.168.1.0/24"` | no |
| dns_servers | List of DNS servers for the subnet | `list(string)` | `[]` | no |
| enable_dhcp | Enable DHCP for the subnet | `bool` | `true` | no |
| create_router | Whether to create a router | `bool` | `true` | no |
| security_rules | Additional security group rules to create | `list(object)` | `[]` | no |
| enable_ssh | Enable SSH access from anywhere | `bool` | `true` | no |
| enable_icmp | Enable ICMP (ping) | `bool` | `true` | no |
| enable_k8s_api | Enable Kubernetes API access | `bool` | `true` | no |
| pod_cidr | Pod network CIDR for Kubernetes | `string` | `"10.244.0.0/16"` | no |
| create_keypair | Whether to create a new SSH keypair | `bool` | `false` | no |
| keypair_name | Name of the SSH keypair to create or use | `string` | `"k0sctl-key"` | no |
| ssh_public_key | SSH public key content | `string` | `""` | no |
| create_app_credential | Whether to create an application credential | `bool` | `false` | no |
| generate_k0sctl_config | Whether to generate k0sctl.yaml configuration file | `bool` | `false` | no |
| k0sctl_config_path | Path where to save the k0sctl.yaml file | `string` | `"./k0sctl.yaml"` | no |
| k0s_version | k0s version to use | `string` | `"1.33.2+k0s.0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| network_id | The ID of the created network |
| subnet_id | The ID of the created subnet |
| router_id | The ID of the created router |
| security_group_id | The ID of the created security group |
| instance_ids | Map of instance names to their IDs |
| instance_ips | Map of instance names to their private IPs |
| floating_ips | Map of instance names to their floating IPs |
| instance_ports | Map of instance names to their port IDs |
| keypair_name | Name of the SSH keypair used |
| app_credential_id | The ID of the application credential |
| app_credential_secret | The secret of the application credential |
| instances | Detailed information about all instances |

## Instance Configuration

The `instances` variable accepts a map of instance configurations. Each instance can have the following properties:

- `name` - Instance name (defaults to map key)
- `flavor_name` - *Required* OpenStack flavor name
- `image_name` - Image name (either this or image_id required)
- `image_id` - Image UUID (either this or image_name required)
- `key_pair` - SSH keypair name (overrides module default)
- `user_data` - Cloud-init user data
- `metadata` - Instance metadata
- `assign_floating_ip` - Whether to assign floating IP (default: true)
- `allowed_address_pairs` - Allowed address pairs for the port
- `volume_size` - Root volume size in GB (default: 20)
- `volume_type` - Volume type
- `delete_volume_on_termination` - Delete volume when instance is deleted (default: true)
- `availability_zone` - Availability zone placement

## Security Rules

Additional security rules can be added using the `security_rules` variable:

```hcl
security_rules = [
  {
    direction        = "ingress"
    ethertype        = "IPv4"
    protocol         = "tcp"
    port_range_min   = 80
    port_range_max   = 80
    remote_ip_prefix = "0.0.0.0/0"
    description      = "HTTP access"
  }
]
```