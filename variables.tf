#Resource Group Variables for Virtual Machines

//Resource Group Name
variable "vm_rg_name"{
  description = "The name of the Azure Resource Group where the resources will be deployed."
  type        = string
}

//Resource Group Location
variable "vm_rg_location" {
  description = "The Azure region where the resources will be deployed."
  type        = string
}


#Virtual Machine Variables

//Configuration block for defining multiple virtual machines
variable "virtual_machines" {
  description = "Map of virtual machine configurations"
  type = map(object({
    size                    = string           # VM size (e.g., Standard_B1s, Standard_D2s_v3)
    admin_username         = string            # Admin username for the VM
    network_interface_ids = list(string)       # List of network interface IDs to attach
    
    # SSH Key configuration
    ssh_key_username = string                 # Username for SSH key (usually same as admin_username)
    ssh_public_key   = string                 # SSH public key content
    
    # OS Disk configuration
    os_disk_caching              = string # None, ReadOnly, ReadWrite
    os_disk_storage_account_type = string # Standard_LRS, StandardSSD_LRS, Premium_LRS
    os_disk_size_gb             = number  # Optional disk size override
    
    # Source Image configuration
    image_publisher = string # Image publisher
    image_offer     = string # Image offer
    image_sku       = string # Image SKU
    image_version   = string # Image version
    
    # Optional VM settings
    disable_password_authentication = optional(bool, true)       # Disable password auth (SSH only)
    provision_vm_agent             = optional(bool, true)        # Install VM agent
    allow_extension_operations     = optional(bool, true)        # Allow extensions

    # Advanced Options
    zone                           = optional(string)           # e.g., "1", "2"
    secure_boot_enabled            = optional(bool, false)
    vtpm_enabled                   = optional(bool, false)
    encryption_at_host_enabled     = optional(bool, false)
    enable_system_identity         = optional(bool, false)
 
    # Tags
    tags = optional(map(string), {})

  }))
  
}



