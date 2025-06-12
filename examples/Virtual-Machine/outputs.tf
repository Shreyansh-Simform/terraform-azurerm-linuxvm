# Outputs for Virtual Machine Example
# Based on the multi-tier and secure VM configurations

# Multi-Tier VMs Module Outputs
output "multi_tier_vm_ids" {
  description = "Map of multi-tier VM names to their Azure resource IDs"
  value       = module.multi_tier_vms.vm_ids
}

output "multi_tier_vm_names" {
  description = "List of all multi-tier VM names"
  value       = module.multi_tier_vms.vm_names
}

output "multi_tier_vm_private_ips" {
  description = "Map of multi-tier VM names to their private IP addresses"
  value       = module.multi_tier_vms.vm_private_ips
}

output "multi_tier_vm_details" {
  description = "Complete information about multi-tier VMs"
  value       = module.multi_tier_vms.vm_details
}

# Secure VM Module Outputs
output "secure_vm_ids" {
  description = "Map of secure VM names to their Azure resource IDs"
  value       = module.secure_vm.vm_ids
}

output "secure_vm_names" {
  description = "List of secure VM names"
  value       = module.secure_vm.vm_names
}

output "secure_vm_private_ips" {
  description = "Map of secure VM names to their private IP addresses"
  value       = module.secure_vm.vm_private_ips
}

output "secure_vm_details" {
  description = "Complete information about secure VMs"
  value       = module.secure_vm.vm_details
}

# Combined VM Information
output "all_vm_summary" {
  description = "Summary of all created VMs across both modules"
  value = {
    multi_tier_vms = {
      total_count = length(module.multi_tier_vms.vm_names)
      vm_names    = module.multi_tier_vms.vm_names
      resource_group = azurerm_resource_group.vm_rg.name
    }
    secure_vms = {
      total_count = length(module.secure_vm.vm_names)
      vm_names    = module.secure_vm.vm_names
      resource_group = "security-rg"
    }
    grand_total = length(module.multi_tier_vms.vm_names) + length(module.secure_vm.vm_names)
  }
}

# SSH Connection Information for Multi-Tier VMs
output "multi_tier_ssh_commands" {
  description = "SSH connection commands for multi-tier VMs"
  value = {
    "web-server-01" = {
      command = "ssh -i ~/.ssh/id_rsa azureuser@${module.multi_tier_vms.vm_private_ips["web-server-01"]}"
      tier    = "Web"
      zone    = "1"
      os      = "Ubuntu 20.04"
    }
    "app-server-01" = {
      command = "ssh -i ~/.ssh/id_rsa azureuser@${module.multi_tier_vms.vm_private_ips["app-server-01"]}"
      tier    = "Application"
      zone    = "2"
      os      = "RHEL 8"
    }
    "db-server-01" = {
      command = "ssh -i ~/.ssh/id_rsa azureuser@${module.multi_tier_vms.vm_private_ips["db-server-01"]}"
      tier    = "Database"
      zone    = "3"
      os      = "Ubuntu 20.04"
    }
  }
}


# VM Configuration Summary by Tier
output "vm_configuration_by_tier" {
  description = "VM configurations organized by tier"
  value = {
    web_tier = {
      vms = ["web-server-01"]
      size = "Standard_B2s"
      storage = "Standard_LRS"
      zone = "1"
      features = ["Basic configuration", "Zone deployment"]
    }
    app_tier = {
      vms = ["app-server-01"]
      size = "Standard_D2s_v3"
      storage = "Premium_LRS"
      zone = "2"
      features = ["Managed identity", "RHEL OS", "Premium storage"]
    }
    db_tier = {
      vms = ["db-server-01"]
      size = "Standard_E4s_v3"
      storage = "Premium_LRS"
      zone = "3"
      features = ["Enhanced security", "Secure boot", "vTPM", "Encryption at host", "Managed identity"]
    }

  }
}

# Availability Zones Usage
output "availability_zones_usage" {
  description = "How VMs are distributed across availability zones"
  value = {
    zone_1 = ["web-server-01", "secure-server-01"]
    zone_2 = ["app-server-01"]
    zone_3 = ["db-server-01"]
    high_availability = "VMs distributed across 3 availability zones"
  }
}

# Operating Systems Summary
output "operating_systems_summary" {
  description = "Operating systems used across all VMs"
  value = {
    "Ubuntu_20_04" = ["web-server-01", "db-server-01", "secure-server-01"]
    "RHEL_8" = ["app-server-01"]
    total_linux_vms = 4
    total_windows_vms = 0
  }
}

