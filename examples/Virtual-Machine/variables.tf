variable "location" {
  description = "The Azure region where all resources will be deployed"
  type        = string
  default     = "East US"
}

variable "admin_username" {
  description = "Admin username for all virtual machines"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key content for VM authentication"
  type        = string
  # Example: file("~/.ssh/id_rsa.pub")
}

# Example 1: Single VM Variables
variable "single_vm_rg_name" {
  description = "Resource group name for single VM example"
  type        = string
  default     = "single-vm-rg"
}

variable "vm_size" {
  description = "Size of the virtual machine for single VM example"
  type        = string
  default     = "Standard_B2s"
  
  validation {
    condition = contains([
      "Standard_B1s", "Standard_B1ms", "Standard_B2s", "Standard_B2ms",
      "Standard_D2s_v3", "Standard_D4s_v3", "Standard_D8s_v3",
      "Standard_E4s_v3", "Standard_E8s_v3"
    ], var.vm_size)
    error_message = "VM size must be a valid Azure VM size."
  }
}

# Example 2: Multi-Tier Application Variables
variable "multi_tier_rg_name" {
  description = "Resource group name for multi-tier application example"
  type        = string
  default     = "multi-tier-rg"
}

# Example 3: Secure VM Variables
variable "secure_vm_rg_name" {
  description = "Resource group name for secure VM example"
  type        = string
  default     = "secure-vm-rg"
}

variable "allowed_ssh_source_ip" {
  description = "IP address or CIDR range allowed to SSH to secure VM (e.g., 'YOUR_IP/32')"
  type        = string
  default     = "*"
  
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/[0-9]{1,2})?$|^\\*$", var.allowed_ssh_source_ip))
    error_message = "allowed_ssh_source_ip must be a valid IP address with optional CIDR notation (e.g., '192.168.1.100/32') or '*' for any source."
  }
}

# Optional: Environment and Tagging Variables
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project for resource tagging"
  type        = string
  default     = "vm-examples"
}



