variable "project_name" {
  description = "Name of the OpenStack project/tenant"
  type        = string
  
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 64
    error_message = "Project name must be between 1 and 64 characters."
  }
}

variable "project_description" {
  description = "Description of the OpenStack project/tenant"
  type        = string
  default     = ""
}

variable "user_name" {
  description = "Name of the user to create"
  type        = string
  
  validation {
    condition     = length(var.user_name) > 0 && length(var.user_name) <= 64
    error_message = "User name must be between 1 and 64 characters."
  }
}

variable "create_user" {
  description = "Whether to create a user for the project"
  type        = bool
  default     = true
}

variable "assign_admin_role" {
  description = "Whether to assign admin role to the user"
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Role to assign to the user (if assign_admin_role is true)"
  type        = string
  default     = "admin"
}

variable "password_length" {
  description = "Length of the generated password"
  type        = number
  default     = 16
  
  validation {
    condition     = var.password_length >= 8 && var.password_length <= 128
    error_message = "Password length must be between 8 and 128 characters."
  }
}

variable "password_special" {
  description = "Include special characters in password"
  type        = bool
  default     = false
}

variable "password_override_special" {
  description = "Special characters to use in password"
  type        = string
  default     = "_%@"
}

variable "user_domain_name" {
  description = "User domain name in OpenStack"
  type        = string
  default     = "Default"
}

variable "project_domain_name" {
  description = "Project domain name in OpenStack"
  type        = string
  default     = "Default"
}

variable "tags" {
  description = "Tags to apply to the project"
  type        = list(string)
  default     = []
}

variable "enabled" {
  description = "Whether the project is enabled"
  type        = bool
  default     = true
}