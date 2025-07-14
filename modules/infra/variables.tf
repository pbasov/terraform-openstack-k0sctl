# Project Configuration
variable "project_id" {
  description = "The OpenStack project ID to create resources in"
  type        = string
}

# Network Configuration
variable "network_name" {
  description = "Name of the network to create"
  type        = string
  default     = "k0sctl-net"
}

variable "subnet_cidr" {
  description = "CIDR for the subnet"
  type        = string
  default     = "192.168.1.0/24"
  
  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "Subnet CIDR must be a valid IPv4 CIDR block."
  }
}

variable "external_network_name" {
  description = "Name of the external network to connect to"
  type        = string
}

variable "dns_servers" {
  description = "List of DNS servers for the subnet"
  type        = list(string)
  default     = []
}

variable "enable_dhcp" {
  description = "Enable DHCP for the subnet"
  type        = bool
  default     = true
}

# Router Configuration
variable "create_router" {
  description = "Whether to create a router"
  type        = bool
  default     = true
}

variable "router_name" {
  description = "Name of the router to create"
  type        = string
  default     = "kcm-router"
}

# Security Group Configuration
variable "security_group_name" {
  description = "Name of the security group to create"
  type        = string
  default     = "kcm-sg"
}

variable "security_rules" {
  description = "Additional security group rules to create"
  type = list(object({
    direction        = string
    ethertype        = string
    protocol         = optional(string)
    port_range_min   = optional(number)
    port_range_max   = optional(number)
    remote_ip_prefix = optional(string)
    remote_group_id  = optional(string)
    description      = optional(string)
  }))
  default = []
}

variable "enable_ssh" {
  description = "Enable SSH access from anywhere"
  type        = bool
  default     = true
}

variable "enable_icmp" {
  description = "Enable ICMP (ping)"
  type        = bool
  default     = true
}

variable "enable_k8s_api" {
  description = "Enable Kubernetes API access"
  type        = bool
  default     = true
}

variable "pod_cidr" {
  description = "Pod network CIDR for Kubernetes"
  type        = string
  default     = "10.244.0.0/16"
}

# Instance Configuration
variable "instances" {
  description = "Map of instances to create"
  type = map(object({
    name           = optional(string)
    flavor_name    = string
    image_name     = optional(string)
    image_id       = optional(string)
    key_pair       = optional(string)
    user_data      = optional(string)
    metadata       = optional(map(string))
    
    # Network configuration
    assign_floating_ip = optional(bool, true)
    allowed_address_pairs = optional(list(object({
      ip_address = string
    })))
    
    # Volume configuration
    volume_size = optional(number, 20)
    volume_type = optional(string)
    delete_volume_on_termination = optional(bool, true)
    
    # Availability zone
    availability_zone = optional(string)
  }))
  
  validation {
    condition = alltrue([
      for k, v in var.instances : v.image_name != null || v.image_id != null
    ])
    error_message = "Each instance must specify either image_name or image_id."
  }
}

# SSH Key Configuration
variable "create_keypair" {
  description = "Whether to create a new SSH keypair"
  type        = bool
  default     = false
}

variable "keypair_name" {
  description = "Name of the SSH keypair to create or use"
  type        = string
  default     = "k0sctl-key"
}

variable "ssh_public_key" {
  description = "SSH public key content (required if create_keypair is true)"
  type        = string
  default     = ""
  sensitive   = true
}

# Application Credential Configuration
variable "create_app_credential" {
  description = "Whether to create an application credential"
  type        = bool
  default     = false
}

variable "app_cred_name" {
  description = "Name of the application credential to create"
  type        = string
  default     = "k0sctl-app-cred"
}

variable "app_cred_description" {
  description = "Description of the application credential"
  type        = string
  default     = "Application credential for k0sctl infrastructure"
}

variable "app_cred_roles" {
  description = "List of roles to assign to the application credential"
  type        = list(string)
  default     = ["member"]
}

variable "app_cred_expiration" {
  description = "Expiration time for the application credential (RFC3339 format)"
  type        = string
  default     = null
}

variable "app_cred_unrestricted" {
  description = "Whether the application credential has unrestricted access"
  type        = bool
  default     = false
}

# k0sctl Configuration
variable "generate_k0sctl_config" {
  description = "Whether to generate k0sctl.yaml configuration file"
  type        = bool
  default     = false
}

variable "k0sctl_config_path" {
  description = "Path where to save the k0sctl.yaml file"
  type        = string
  default     = "./k0sctl.yaml"
}

variable "k0s_version" {
  description = "k0s version to use"
  type        = string
  default     = "1.33.2+k0s.0"
}

variable "k0s_dynamic_config" {
  description = "Whether to enable k0s dynamic configuration"
  type        = bool
  default     = true
}

# Load Balancer Configuration
variable "create_loadbalancer" {
  description = "Whether to create a load balancer for controllers"
  type        = bool
  default     = false
}

variable "loadbalancer_name" {
  description = "Name of the load balancer"
  type        = string
  default     = ""
}

variable "loadbalancer_provider" {
  description = "Provider for the load balancer (e.g., octavia, amphora)"
  type        = string
  default     = "octavia"
}

variable "loadbalancer_algorithm" {
  description = "Load balancing algorithm (ROUND_ROBIN, LEAST_CONNECTIONS, SOURCE_IP, SOURCE_IP_PORT)"
  type        = string
  default     = "LEAST_CONNECTIONS"
}

variable "loadbalancer_health_monitor_delay" {
  description = "The time, in seconds, between sending probes to members"
  type        = number
  default     = 5
}

variable "loadbalancer_health_monitor_timeout" {
  description = "The maximum time, in seconds, that a monitor waits to connect before it times out"
  type        = number
  default     = 3
}

variable "loadbalancer_health_monitor_max_retries" {
  description = "The number of allowed connection failures before changing the member status to INACTIVE"
  type        = number
  default     = 3
}

variable "controller_instance_keys" {
  description = "List of instance keys that should be controllers (used for load balancer pool members)"
  type        = list(string)
  default     = []
}

# Tags
variable "tags" {
  description = "Tags to apply to resources that support them"
  type        = map(string)
  default     = {}
}