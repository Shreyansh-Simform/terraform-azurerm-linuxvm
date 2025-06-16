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


//Virtual Network Variables for Virtual Machines
#VNET Name
variable "vm_virtual_network_name" {
  description = "The name of the Azure Virtual Network."
  type        = string
}

#VNET Address Space
variable "vm_vnet_address_space" {
  description = "The address space for the Virtual Network."
  type        = list(string)
}

#Subnet Variables for Virtual Machines
#Subnet Name
variable "vm_subnet_name" {
  description = "The name of the subnet within the Virtual Network."
  type        = string 
}

#Subnet Address Prefixes
variable "vm_subnet_address_prefixes" {
  description = "The address prefixes for the subnet."
  type        = list(string)
}

#Subnet Delegation Variables for Virtual Machines
#Enable Subnet Delegation
variable "enable_subnet_delegation" {
  description = "Enable subnet delegation for Container Instance groups. If true, delegation will be added to the subnet."
  type        = bool
  default     = false
}

#Delegation Service Name
variable "delegation_service_name" {
  description = "The name of the service to delegate the subnet to. Only used when enable_subnet_delegation is true."
  type        = string
  default     = null

  validation {
    condition     = var.enable_subnet_delegation == false ? var.delegation_service_name == null : true
    error_message = "delegation_service_name can only be set when enable_subnet_delegation is true."
  }
}

#Delegation Service Actions
variable "delegation_service_actions" {
  description = "List of actions that the delegated service can perform on the subnet. Only used when enable_subnet_delegation is true."
  type        = list(string)
  default     = null

  validation {
    condition     = var.enable_subnet_delegation == false ? var.delegation_service_actions == null : true
    error_message = "delegation_service_actions can only be set when enable_subnet_delegation is true."
  }
}

//Configuration block for defining multiple public IPs
variable "public_ip_name" {
  description = "Map of public IP configurations where key is the IP name"
  type = map(object({
    allocation_method = string  # Static or Dynamic
    sku              = optional(string, "Basic")  # Basic or Standard
    ip_version       = optional(string, "IPv4")  # IPv4 or IPv6
    
    # Support for existing public IPs
    use_existing                    = optional(bool, false)  # Set to true to use existing IP
    existing_resource_group_name    = optional(string)      # Required if use_existing is true
  }))
}


//Network Interface Variables for Virtual Machines
variable "network_interfaces" {
  description = "Map of network interface configurations"
  type = map(object({
    subnet_name                   = string           # Reference to subnet name
    private_ip_address_allocation = string           # Static or Dynamic
    private_ip_address           = optional(string)  # Required if allocation is Static
    public_ip_name               = optional(string)  # Reference to public IP name (optional)
    enable_ip_forwarding         = optional(bool, false)
    enable_accelerated_networking = optional(bool, false)
    network_security_group       = optional(string)  # Reference to NSG name (optional)
    
    # Support for existing network interfaces
    use_existing                    = optional(bool, false)  # Set to true to use existing NIC
    existing_resource_group_name    = optional(string)      # Required if use_existing is true
  }))

}


#Network Security Group Variables for Virtual Machines
variable "network_security_groups" {
  description = "Map of network security group configurations"
  type = map(object({
    security_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string)
      destination_port_range     = optional(string)
      source_address_prefix      = optional(string)
      destination_address_prefix = optional(string)
    })), [])
  }))
  default = {}
}

#Virtual Machine Variables

//Configuration block for defining multiple virtual machines
variable "virtual_machines" {
  description = "Map of virtual machine configurations"
  type = map(object({
    size                    = string           # VM size (e.g., Standard_B1s, Standard_D2s_v3)
    admin_username         = string            # Admin username for the VM
    network_interface_names = list(string)     # List of network interface names to attach

    # SSH Key configuration
    ssh_key_username = string                 # Username for SSH key (usually same as admin_username)
    ssh_public_key   = string     

    #Admin password
    admin_password = optional(string)         # Optional admin password (if not using SSH key)
    
    # OS Disk configuration
    os_disk_caching              = string # None, ReadOnly, ReadWrite
    os_disk_storage_account_type = string # Standard_LRS, StandardSSD_LRS, Premium_LRS
    os_disk_size_gb              = number # Optional disk size override
    
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
 
    # Availability Set configuration
    availability_set_id = optional(string) # ID of the availability set to use

    #For Custom Data
    custom_data = optional(string) # Base64 encoded custom data script
  }))
}

#Tags Variables for Virtual Machines
variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

# Data Disk Variables

# Configuration for new data disks to create
variable "new_data_disks" {
  description = "Map of new data disk configurations to create"
  type = map(object({
    storage_account_type = string  # Standard_LRS, StandardSSD_LRS, Premium_LRS
    disk_size_gb        = number   # Size of the disk in GB
  }))
  default = {}
}

# Configuration for existing data disks to use
variable "existing_data_disks" {
  description = "Map of existing data disk configurations to use"
  type = map(object({
    resource_group_name = string  # Resource group where the existing disk is located
  }))
  default = {}
}

# Configuration for attaching data disks to VMs
variable "vm_data_disk_attachments" {
  description = "Map of data disk attachments to VMs"
  type = map(object({
    vm_name   = string  # Name of the VM to attach the disk to
    disk_name = string  # Name of the disk (from new_data_disks or existing_data_disks)
    lun       = number  # Logical Unit Number (0-63)
    caching   = string  # None, ReadOnly, ReadWrite
  }))
  default = {}
}




