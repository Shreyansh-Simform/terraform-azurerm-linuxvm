# Outputs for Virtual Machine Examples
# This file provides outputs for all three example scenarios

# Example 1: Single VM Outputs
output "single_vm_summary" {
  description = "Summary of single VM deployment"
  value = {
    deployment_summary = module.single_vm_example.deployment_summary
    vm_details        = module.single_vm_example.vm_details
    public_ips        = module.single_vm_example.public_ip_addresses
    resource_group    = module.single_vm_example.resource_group_name
  }
}

output "single_vm_ssh_command" {
  description = "SSH connection command for single VM"
  value = "ssh -i ~/.ssh/id_rsa ${var.admin_username}@${try(values(module.single_vm_example.public_ip_addresses)[0], "no-public-ip")}"
}

# Example 2: Multi-Tier Application Outputs
output "multi_tier_summary" {
  description = "Summary of multi-tier application deployment"
  value = {
    deployment_summary = module.multi_tier_example.deployment_summary
    vm_details        = module.multi_tier_example.vm_details
    public_ips        = module.multi_tier_example.public_ip_addresses
    private_ips       = module.multi_tier_example.vm_private_ips
    resource_group    = module.multi_tier_example.resource_group_name
  }
}

output "multi_tier_connection_info" {
  description = "Connection information for multi-tier VMs"
  value = {
    web_server = {
      private_ip = try(module.multi_tier_example.vm_private_ips["web-server"], "N/A")
      public_ip  = try(module.multi_tier_example.public_ip_addresses["web-pip"], "N/A")
      ssh_command = "ssh -i ~/.ssh/id_rsa ${var.admin_username}@${try(module.multi_tier_example.public_ip_addresses["web-pip"], "PRIVATE_IP")}"
      tier = "Web"
      zone = "1"
    }
    app_server = {
      private_ip = try(module.multi_tier_example.vm_private_ips["app-server"], "N/A")
      ssh_command = "ssh -i ~/.ssh/id_rsa ${var.admin_username}@${try(module.multi_tier_example.vm_private_ips["app-server"], "PRIVATE_IP")}"
      tier = "Application"
      zone = "2"
      note = "Access via bastion host or private network"
    }
    db_server = {
      private_ip = try(module.multi_tier_example.vm_private_ips["db-server"], "N/A")
      ssh_command = "ssh -i ~/.ssh/id_rsa ${var.admin_username}@${try(module.multi_tier_example.vm_private_ips["db-server"], "PRIVATE_IP")}"
      tier = "Database"
      zone = "3"
      security_features = ["Secure Boot", "vTPM", "Encryption at Host", "Managed Identity"]
      note = "Access via bastion host or private network"
    }
    bastion_host = {
      public_ip = try(module.multi_tier_example.public_ip_addresses["bastion-pip"], "N/A")
      ssh_command = "ssh -i ~/.ssh/id_rsa ${var.admin_username}@${try(module.multi_tier_example.public_ip_addresses["bastion-pip"], "PUBLIC_IP")}"
      purpose = "Jump server for accessing private VMs"
    }
  }
}

# Example 3: Secure VM Outputs
output "secure_vm_summary" {
  description = "Summary of secure VM deployment"
  value = {
    deployment_summary = module.secure_vm_example.deployment_summary
    vm_details        = module.secure_vm_example.vm_details
    public_ips        = module.secure_vm_example.public_ip_addresses
    security_features = ["Secure Boot", "vTPM", "Encryption at Host", "Managed Identity", "Accelerated Networking"]
    subnet_delegation = "Microsoft.ContainerInstance/containerGroups"
    resource_group    = module.secure_vm_example.resource_group_name
  }
}

output "secure_vm_connection_info" {
  description = "Connection information for secure VM"
  value = {
    ssh_command = "ssh -i ~/.ssh/id_rsa ${var.admin_username}@${try(module.secure_vm_example.public_ip_addresses["secure-pip"], "PUBLIC_IP")}"
    public_ip   = try(module.secure_vm_example.public_ip_addresses["secure-pip"], "N/A")
    private_ip  = try(module.secure_vm_example.vm_private_ips["secure-server"], "N/A")
    allowed_source = var.allowed_ssh_source_ip
    security_note = "SSH access restricted to ${var.allowed_ssh_source_ip}"
  }
}

# Combined Infrastructure Summary
output "complete_infrastructure_summary" {
  description = "Summary of all deployed infrastructure across examples"
  value = {
    total_resource_groups = 3
    total_virtual_networks = 3
    total_vms = sum([
      length(module.single_vm_example.vm_names),
      length(module.multi_tier_example.vm_names),
      length(module.secure_vm_example.vm_names)
    ])
    total_public_ips = sum([
      length(module.single_vm_example.public_ip_addresses),
      length(module.multi_tier_example.public_ip_addresses),
      length(module.secure_vm_example.public_ip_addresses)
    ])
    
    deployment_breakdown = {
      single_vm_example = {
        vms = length(module.single_vm_example.vm_names)
        resource_group = module.single_vm_example.resource_group_name
        use_case = "Simple web server deployment"
      }
      multi_tier_example = {
        vms = length(module.multi_tier_example.vm_names)
        resource_group = module.multi_tier_example.resource_group_name
        use_case = "3-tier application architecture"
      }
      secure_vm_example = {
        vms = length(module.secure_vm_example.vm_names)
        resource_group = module.secure_vm_example.resource_group_name
        use_case = "High-security VM with subnet delegation"
      }
    }
    
    availability_zones_usage = {
      zone_1 = ["web-server (single)", "web-server (multi-tier)", "secure-server"]
      zone_2 = ["app-server (multi-tier)"]
      zone_3 = ["db-server (multi-tier)"]
      total_zones_used = 3
    }
    
    security_features_summary = {
      basic_vms = 1
      enhanced_security_vms = 2
      secure_boot_enabled = 2
      vtpm_enabled = 2
      encryption_at_host = 2
      managed_identity_enabled = 2
    }
  }
}

# Network Configuration Summary
output "network_configuration_summary" {
  description = "Summary of network configurations across all examples"
  value = {
    single_vm_network = {
      vnet_cidr = "10.0.0.0/16"
      subnet_cidr = "10.0.1.0/24"
      public_access = "Direct via Public IP"
    }
    multi_tier_network = {
      vnet_cidr = "10.1.0.0/16"
      subnet_cidr = "10.1.1.0/24"
      public_access = "Web tier and Bastion only"
      private_communication = "App and DB tiers"
    }
    secure_vm_network = {
      vnet_cidr = "10.2.0.0/16"
      subnet_cidr = "10.2.1.0/24"
      public_access = "Restricted SSH access"
      special_features = "Container Instance delegation"
    }
  }
}

# Deployment Instructions
output "deployment_instructions" {
  description = "Instructions for deploying the examples"
  value = {
    prerequisites = [
      "Set ssh_public_key variable to your SSH public key content",
      "Optionally modify allowed_ssh_source_ip for secure VM",
      "Ensure Azure CLI is authenticated",
      "Have appropriate Azure permissions"
    ]
    deployment_commands = [
      "terraform init",
      "terraform plan",
      "terraform apply"
    ]
    cleanup_command = "terraform destroy"
    notes = [
      "All examples will be deployed simultaneously",
      "Each example uses separate resource groups",
      "Review security group rules before deployment",
      "Consider costs for multiple VM deployment"
    ]
  }
}

