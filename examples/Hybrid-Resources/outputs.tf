# Output all VM details
output "virtual_machines" {
  description = "Details of all created virtual machines"
  value = {
    for vm_name, vm in module.hybrid_vm_deployment.virtual_machines : vm_name => {
      id                = vm.id
      name              = vm.name
      private_ip        = vm.private_ip_address
      public_ip         = vm.public_ip_address
      size              = vm.size
      location          = vm.location
      resource_group    = vm.resource_group_name
    }
  }
}

# Output Public IPs (both new and existing)
output "public_ips" {
  description = "All public IP addresses (new and existing)"
  value       = module.hybrid_vm_deployment.all_public_ips
}

# Output Network Interfaces (both new and existing)
output "network_interfaces" {
  description = "All network interfaces (new and existing)"
  value       = module.hybrid_vm_deployment.all_network_interfaces
}

# Output Data Disks (both new and existing)
output "data_disks" {
  description = "All data disks (new and existing)"
  value       = module.hybrid_vm_deployment.all_data_disks
}

# Summary information
output "deployment_summary" {
  description = "Summary of the hybrid deployment"
  value = {
    total_vms                = length(module.hybrid_vm_deployment.virtual_machines)
    new_public_ips_created   = length(module.hybrid_vm_deployment.new_public_ips)
    existing_public_ips_used = length(module.hybrid_vm_deployment.existing_public_ips)
    new_nics_created         = length(module.hybrid_vm_deployment.new_network_interfaces)
    existing_nics_used       = length(module.hybrid_vm_deployment.existing_network_interfaces)
    new_data_disks_created   = length(module.hybrid_vm_deployment.new_data_disks)
    existing_data_disks_used = length(module.hybrid_vm_deployment.existing_data_disks)
  }
}
