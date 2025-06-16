# Hybrid Resource Usage Guide

This guide explains how to use existing Azure resources alongside creating new ones in your Virtual Machine module.

## Overview

The enhanced VM module supports **hybrid resource management**, allowing you to:
- Use existing Public IPs, Network Interfaces, and Data Disks
- Create new resources when needed
- Mix both approaches in a single deployment

## Configuration Patterns

### 1. Using Existing Public IP

```hcl
public_ip_name = {
  "my-existing-ip" = {
    allocation_method            = "Static"  # These values are ignored for existing resources
    sku                         = "Standard" # but kept for variable validation
    use_existing                = true       # Key setting
    existing_resource_group_name = "my-existing-rg"  # Required for existing resources
  }
}
```

### 2. Using Existing Network Interface

```hcl
network_interfaces = {
  "my-existing-nic" = {
    subnet_name                     = "ignored-for-existing"  # Required but ignored
    private_ip_address_allocation   = "Dynamic"               # Required but ignored
    use_existing                    = true                    # Key setting
    existing_resource_group_name    = "my-existing-rg"       # Required for existing resources
  }
}
```

### 3. Using Existing Data Disk

```hcl
# Define existing disks
existing_data_disks = {
  "my-existing-disk" = {
    resource_group_name = "my-storage-rg"
  }
}

# Attach existing disk to VM
vm_data_disk_attachments = {
  "vm-to-existing-disk" = {
    vm_name   = "my-vm"
    disk_name = "my-existing-disk"  # References existing disk
    lun       = 0
    caching   = "ReadWrite"
  }
}
```

## Complete Example Scenarios

### Scenario 1: Full Hybrid Deployment

```hcl
module "hybrid_vm" {
  source = "./path/to/vm-module"

  # Basic configuration...
  vm_rg_name     = "my-vm-rg"
  vm_rg_location = "East US"
  # ... other basic settings

  # Mix of new and existing public IPs
  public_ip_name = {
    "new-ip" = {
      allocation_method = "Static"
      sku              = "Standard"
      use_existing     = false  # Will create new
    }
    "existing-ip" = {
      allocation_method            = "Static"
      sku                         = "Standard"
      use_existing                = true    # Will use existing
      existing_resource_group_name = "existing-rg"
    }
  }

  # Mix of new and existing NICs
  network_interfaces = {
    "new-nic" = {
      subnet_name                   = "vm-subnet"
      private_ip_address_allocation = "Dynamic"
      public_ip_name               = "new-ip"
      use_existing                 = false  # Will create new
    }
    "existing-nic" = {
      subnet_name                     = "ignored"
      private_ip_address_allocation   = "ignored"
      use_existing                    = true   # Will use existing
      existing_resource_group_name    = "existing-rg"
    }
  }

  # Virtual Machines using mixed resources
  virtual_machines = {
    "vm-with-new-resources" = {
      # ... VM configuration
      network_interface_names = ["new-nic"]
    }
    "vm-with-existing-resources" = {
      # ... VM configuration
      network_interface_names = ["existing-nic"]
    }
  }

  # Data disk configuration
  new_data_disks = {
    "new-disk" = {
      storage_account_type = "Premium_LRS"
      disk_size_gb        = 128
    }
  }

  existing_data_disks = {
    "existing-disk" = {
      resource_group_name = "storage-rg"
    }
  }

  vm_data_disk_attachments = {
    "new-disk-attachment" = {
      vm_name   = "vm-with-new-resources"
      disk_name = "new-disk"
      lun       = 0
      caching   = "ReadWrite"
    }
    "existing-disk-attachment" = {
      vm_name   = "vm-with-existing-resources"
      disk_name = "existing-disk"
      lun       = 0
      caching   = "ReadWrite"
    }
  }
}
```

### Scenario 2: Migration Use Case

Perfect for migrating workloads where you want to:
1. Keep existing networking (NICs, IPs)
2. Create new VMs
3. Attach existing storage

```hcl
# Keep existing network infrastructure, create new VMs
network_interfaces = {
  "legacy-app-nic" = {
    use_existing                = true
    existing_resource_group_name = "legacy-network-rg"
    # Other fields ignored but required for validation
    subnet_name                   = "ignored"
    private_ip_address_allocation = "ignored"
  }
}

virtual_machines = {
  "migrated-app-vm" = {
    size                    = "Standard_D2s_v3"  # Upgraded size
    network_interface_names = ["legacy-app-nic"] # Reuse existing NIC
    # ... rest of VM config with new OS image
  }
}
```

## Best Practices

### 1. Resource Naming
- Use consistent naming conventions
- Include environment/purpose in names
- Document which resources are existing vs new

### 2. Resource Groups
- Always specify correct resource group for existing resources
- Verify permissions to access existing resources
- Consider resource lifecycle management

### 3. Dependencies
- Existing resources must exist before deployment
- Verify existing resource compatibility
- Test with `terraform plan` before applying

### 4. Error Handling
- Common issues:
  - Resource not found: Check names and resource groups
  - Permission denied: Verify access to existing resources
  - Type mismatches: Ensure compatibility between resources

## Validation Checklist

Before deploying:
- [ ] Existing resources exist and are accessible
- [ ] Resource groups are correct
- [ ] Naming conventions are consistent
- [ ] Dependencies are properly mapped
- [ ] Permissions are sufficient
- [ ] Resource compatibility is verified

## Troubleshooting

### Common Issues:

1. **"Resource not found"**
   - Check resource names and resource group names
   - Verify the resource exists in Azure

2. **"Access denied"**
   - Ensure Terraform has proper permissions
   - Check resource group access rights

3. **"Resource type mismatch"**
   - Verify compatibility between existing and new resources
   - Check SKU and feature compatibility

### Debug Commands:

```bash
# Verify existing resources
terraform plan -target="data.azurerm_public_ip.existing_public_ips"
terraform plan -target="data.azurerm_network_interface.existing_nics"

# Check resource details
az resource show --ids "/subscriptions/.../resourceGroups/rg/providers/Microsoft.Network/publicIPAddresses/ip-name"
```
