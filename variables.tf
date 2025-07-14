# OpenStack Authentication
variable "auth_url" {
  description = "OpenStack authentication URL (optional if using clouds.yaml or environment variables)"
  type        = string
  default     = ""
}

variable "region_name" {
  description = "OpenStack region name"
  type        = string
  default     = "RegionOne"
}

# Project/Tenant Configuration
variable "create_project" {
  description = "Whether to create a new project/tenant"
  type        = bool
  default     = true
}

variable "project_name" {
  description = "Name of the OpenStack project/tenant"
  type        = string
  default     = "k0sctl"
}

variable "project_description" {
  description = "Description of the OpenStack project/tenant"
  type        = string
  default     = "k0sctl Kubernetes cluster project"
}

variable "project_id" {
  description = "Existing project ID (required if create_project is false)"
  type        = string
  default     = ""
}

# User Configuration
variable "create_user" {
  description = "Whether to create a user for the project"
  type        = bool
  default     = true
}

variable "user_name" {
  description = "Name of the user to create"
  type        = string
  default     = "k0sctl-admin"
}

variable "user_password_length" {
  description = "Length of the generated user password"
  type        = number
  default     = 20
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
  default     = "192.168.100.0/24"
}

variable "external_network_name" {
  description = "Name of the external network to connect to"
  type        = string
}

variable "dns_servers" {
  description = "List of DNS servers for the subnet"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

# Instance Configuration
variable "instances" {
  description = "Map of instances to create for the k0sctl cluster"
  type = map(object({
    name           = optional(string)
    flavor_name    = string
    image_name     = optional(string)
    image_id       = optional(string)
    volume_size    = optional(number, 50)
    volume_type    = optional(string)
    assign_floating_ip = optional(bool, true)
  }))
  default = {
    controller-1 = {
      flavor_name = "m1.xlarge"
      image_name  = "ubuntu-noble-server-amd64"
      volume_size = 50
    }
    worker-1 = {
      flavor_name = "m1.xlarge"
      image_name  = "ubuntu-noble-server-amd64"
      volume_size = 50
    }
    worker-2 = {
      flavor_name = "m1.xlarge"
      image_name  = "ubuntu-noble-server-amd64"
      volume_size = 50
    }
  }
}

# SSH Configuration
variable "ssh_public_key_file" {
  description = "Path to SSH public key file"
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "SSH public key content (takes precedence over ssh_public_key_file)"
  type        = string
  default     = ""
  sensitive   = true
}

# k0s Configuration
variable "k0s_version" {
  description = "k0s version to use"
  type        = string
  default     = "1.33.2+k0s.0"
}

variable "generate_k0sctl_config" {
  description = "Whether to generate k0sctl.yaml configuration file"
  type        = bool
  default     = true
}

variable "k0sctl_config_path" {
  description = "Path where to save the k0sctl.yaml file"
  type        = string
  default     = "./k0sctl.yaml"
}

# Application Credential Configuration
variable "create_app_credential" {
  description = "Whether to create an application credential for the project"
  type        = bool
  default     = true
}

variable "app_credential_name" {
  description = "Name of the application credential"
  type        = string
  default     = "k0sctl-app-cred"
}

# Load Balancer Configuration
variable "create_loadbalancer" {
  description = "Whether to create a load balancer for controllers"
  type        = bool
  default     = false
}

variable "controller_instance_keys" {
  description = "List of instance keys that should be controllers (used for load balancer pool members)"
  type        = list(string)
  default     = []
}

variable "loadbalancer_algorithm" {
  description = "Load balancing algorithm (ROUND_ROBIN, LEAST_CONNECTIONS, SOURCE_IP, SOURCE_IP_PORT)"
  type        = string
  default     = "LEAST_CONNECTIONS"
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "k0sctl"
    ManagedBy   = "terraform"
  }
}

# Output Configuration
variable "output_clouds_yaml" {
  description = "Whether to output clouds.yaml configuration"
  type        = bool
  default     = true
}

variable "clouds_yaml_path" {
  description = "Path where to save the clouds.yaml file"
  type        = string
  default     = "./clouds.yaml"
}