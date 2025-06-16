# Outputs from the composed modules

# Network Infrastructure Outputs
output "network_infrastructure" {
  description = "Outputs from the network infrastructure module"
  value = {
    resource_group_name    = module.shared_network.resource_group_name
    public_ip_ids         = module.shared_network.public_ip_ids
    public_ip_addresses   = module.shared_network.public_ip_addresses
    network_interface_ids = module.shared_network.network_interface_ids
    virtual_network_id    = module.shared_network.virtual_network_id
    subnet_ids            = module.shared_network.subnet_ids
  }
}

# Virtual Machine Outputs
output "virtual_machines" {
  description = "Outputs from the virtual machine module"
  value = {
    vm_ids                    = module.application_vms.virtual_machine_ids
    vm_private_ips           = module.application_vms.virtual_machine_private_ips
    vm_public_ips            = module.application_vms.virtual_machine_public_ips
    resource_group_name      = module.application_vms.resource_group_name
    all_public_ips          = module.application_vms.all_public_ips
    all_network_interfaces  = module.application_vms.all_network_interfaces
  }
}

# Cross-module resource mapping
output "resource_mapping" {
  description = "Shows how resources are shared between modules"
  value = {
    shared_public_ips = {
      for ip_name in keys(module.shared_network.public_ip_ids) : 
      ip_name => {
        created_in_module = "shared_network"
        used_in_module    = "application_vms"
        resource_id       = module.shared_network.public_ip_ids[ip_name]
        ip_address        = module.shared_network.public_ip_addresses[ip_name]
      }
    }
    
    shared_network_interfaces = {
      for nic_name in keys(module.shared_network.network_interface_ids) :
      nic_name => {
        created_in_module = "shared_network"
        used_in_module    = "application_vms"
        resource_id       = module.shared_network.network_interface_ids[nic_name]
      }
    }
  }
}

# Deployment summary
output "deployment_summary" {
  description = "Summary of the composed deployment"
  value = {
    total_modules_used        = 2
    shared_public_ips        = length(module.shared_network.public_ip_ids)
    shared_network_interfaces = length(module.shared_network.network_interface_ids)
    total_vms_created        = length(module.application_vms.virtual_machine_ids)
    resource_groups_created  = 2
  }
}
