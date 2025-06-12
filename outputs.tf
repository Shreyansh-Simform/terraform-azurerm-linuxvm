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

output "vm_details" {
  description = "Complete VM information"
  value = {
    for k, v in azurerm_linux_virtual_machine.myvm : k => {
      id                = v.id
      name              = v.name
      size              = v.size
      admin_username    = v.admin_username
      private_ip_address = v.private_ip_address
      network_interface_ids = v.network_interface_ids
    }
  }
}

