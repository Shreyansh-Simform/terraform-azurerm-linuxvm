# Resource Group Outputs
output "resource_group_id" {
  description = "The ID of the created resource group"
  value       = azurerm_resource_group.vmrg.id
}

output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.vmrg.name
}

# Virtual Network and Subnet Outputs
output "virtual_network_id" {
  description = "The ID of the created virtual network"
  value       = azurerm_virtual_network.myvnet.id
}

output "virtual_network_name" {
  description = "The name of the created virtual network"
  value       = azurerm_virtual_network.myvnet.name
}

output "subnet_id" {
  description = "The ID of the created subnet"
  value       = azurerm_subnet.vm-subnet.id
}

output "subnet_name" {
  description = "The name of the created subnet"
  value       = azurerm_subnet.vm-subnet.name
}

# Public IP Outputs
output "public_ip_ids" {
  description = "Map of public IP names to their IDs"
  value       = { for k, v in azurerm_public_ip.my-pubip : k => v.id }
}

output "public_ip_addresses" {
  description = "Map of public IP names to their IP addresses"
  value       = { for k, v in azurerm_public_ip.my-pubip : k => v.ip_address }
}

output "public_ip_details" {
  description = "Complete public IP information"
  value = {
    for k, v in azurerm_public_ip.my-pubip : k => {
      id                = v.id
      ip_address        = v.ip_address
      allocation_method = v.allocation_method
      sku              = v.sku
      ip_version       = v.ip_version
    }
  }
}

# Network Security Group Outputs
output "network_security_group_ids" {
  description = "Map of NSG names to their IDs"
  value       = { for k, v in azurerm_network_security_group.network-nsg : k => v.id }
}

output "network_security_group_names" {
  description = "List of NSG names created"
  value       = keys(azurerm_network_security_group.network-nsg)
}

# Network Interface Outputs
output "network_interface_ids" {
  description = "Map of network interface names to their IDs"
  value       = { for k, v in azurerm_network_interface.vm-nic : k => v.id }
}

output "network_interface_private_ips" {
  description = "Map of network interface names to their private IP addresses"
  value       = { for k, v in azurerm_network_interface.vm-nic : k => v.private_ip_address }
}

output "network_interface_details" {
  description = "Complete network interface information"
  value = {
    for k, v in azurerm_network_interface.vm-nic : k => {
      id                = v.id
      name              = v.name
      private_ip_address = v.private_ip_address
      mac_address       = v.mac_address
    }
  }
}

# Virtual Machine Outputs
output "vm_ids" {
  description = "Map of VM names to their IDs"
  value       = { for k, v in azurerm_linux_virtual_machine.myvm : k => v.id }
}

output "vm_names" {
  description = "List of VM names"
  value       = keys(azurerm_linux_virtual_machine.myvm)
}

output "vm_private_ips" {
  description = "Map of VM names to their primary private IP addresses"
  value       = { 
    for k, v in azurerm_linux_virtual_machine.myvm : k => v.private_ip_address 
  }
}

output "vm_public_ips" {
  description = "Map of VM names to their public IP addresses (if any)"
  value = {
    for vm_name, vm in azurerm_linux_virtual_machine.myvm : vm_name => {
      
    }
  }
}

output "vm_sizes" {
  description = "Map of VM names to their sizes"
  value       = { for k, v in azurerm_linux_virtual_machine.myvm : k => v.size }
}

output "vm_zones" {
  description = "Map of VM names to their availability zones"
  value       = { for k, v in azurerm_linux_virtual_machine.myvm : k => v.zone }
}

output "vm_details" {
  description = "Complete VM information"
  value = {
    for k, v in azurerm_linux_virtual_machine.myvm : k => {
      id                     = v.id
      name                   = v.name
      size                   = v.size
      zone                   = v.zone
      admin_username         = v.admin_username
      private_ip_address     = v.private_ip_address
      network_interface_ids  = v.network_interface_ids
      resource_group_name    = v.resource_group_name
      location              = v.location
      computer_name         = v.computer_name
    }
  }
}

# Summary Outputs
output "deployment_summary" {
  description = "Summary of all created resources"
  value = {
    resource_group = {
      name = azurerm_resource_group.vmrg.name
      id   = azurerm_resource_group.vmrg.id
    }
    virtual_network = {
      name = azurerm_virtual_network.myvnet.name
      id   = azurerm_virtual_network.myvnet.id
    }
    subnet = {
      name = azurerm_subnet.vm-subnet.name
      id   = azurerm_subnet.vm-subnet.id
    }
    public_ips_count         = length(azurerm_public_ip.my-pubip)
    network_interfaces_count = length(azurerm_network_interface.vm-nic)
    security_groups_count    = length(azurerm_network_security_group.network-nsg)
    virtual_machines_count   = length(azurerm_linux_virtual_machine.myvm)
    vm_names                = keys(azurerm_linux_virtual_machine.myvm)
  }
}

