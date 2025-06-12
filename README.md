# Azure Virtual Machine Terraform Module

This Terraform module creates one or multiple Azure Linux Virtual Machines with advanced configuration options. The module uses a map-based approach to define VM configurations, making it flexible for both single and multi-VM deployments.

## Features

- ✅ **Multiple VM Support**: Deploy one or multiple VMs using a single module call
- ✅ **Linux Virtual Machines**: Optimized for Linux-based workloads
- ✅ **SSH Key Authentication**: Secure access with SSH public keys
- ✅ **Advanced Security Options**: Support for Secure Boot, vTPM, and encryption at host
- ✅ **Flexible Storage**: Multiple disk types and sizes with customizable caching
- ✅ **Availability Zones**: Support for Azure Availability Zones
- ✅ **Managed Identity**: Optional system-assigned managed identity
- ✅ **Custom Tagging**: Resource-level tagging support
- ✅ **Network Integration**: Works with existing network interfaces

## Architecture

The module uses a `for_each` loop with a map of VM configurations, allowing you to define multiple VMs with different specifications in a single module call. Each VM is configured independently with its own settings for size, networking, storage, and security options.

## Usage Examples

### Single Virtual Machine

```hcl
module "single_vm" {
  source = "./child_modules/Virtual-Machine"

  vm_rg_name     = "my-vm-resource-group"
  vm_rg_location = "East US"

  virtual_machines = {
    "web-server-01" = {
      size                    = "Standard_B2s"
      admin_username         = "azureuser"
      network_interface_ids  = [azurerm_network_interface.web.id]
      
      ssh_key_username = "azureuser"
      ssh_public_key   = file("~/.ssh/id_rsa.pub")
      
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"
      os_disk_size_gb             = 30
      
      image_publisher = "Canonical"
      image_offer     = "0001-com-ubuntu-server-focal"
      image_sku       = "20_04-lts-gen2"
      image_version   = "latest"
      
      tags = {
        Environment = "Production"
        Project     = "WebApp"
      }
    }
  }
}
```

### Multiple Virtual Machines with Different Configurations

```hcl
module "multi_tier_vms" {
  source = "./child_modules/Virtual-Machine"

  vm_rg_name     = "multi-tier-rg"
  vm_rg_location = "East US"

  virtual_machines = {
    "web-server-01" = {
      size                    = "Standard_B2s"
      admin_username         = "azureuser"
      network_interface_ids  = [azurerm_network_interface.web1.id]
      zone                   = "1"
      
      ssh_key_username = "azureuser"
      ssh_public_key   = file("~/.ssh/id_rsa.pub")
      
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"
      os_disk_size_gb             = 30
      
      image_publisher = "Canonical"
      image_offer     = "0001-com-ubuntu-server-focal"
      image_sku       = "20_04-lts-gen2"
      image_version   = "latest"
      
      tags = {
        Tier = "Web"
        Environment = "Production"
      }
    }
    
    "app-server-01" = {
      size                    = "Standard_D2s_v3"
      admin_username         = "azureuser"
      network_interface_ids  = [azurerm_network_interface.app1.id]
      zone                   = "2"
      
      ssh_key_username = "azureuser"
      ssh_public_key   = file("~/.ssh/id_rsa.pub")
      
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"
      os_disk_size_gb             = 50
      
      image_publisher = "RedHat"
      image_offer     = "RHEL"
      image_sku       = "8-lvm-gen2"
      image_version   = "latest"
      
      enable_system_identity = true
      
      tags = {
        Tier = "Application"
        Environment = "Production"
      }
    }
    
    "db-server-01" = {
      size                    = "Standard_E4s_v3"
      admin_username         = "azureuser"
      network_interface_ids  = [azurerm_network_interface.db1.id]
      zone                   = "3"
      
      ssh_key_username = "azureuser"
      ssh_public_key   = file("~/.ssh/id_rsa.pub")
      
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"
      os_disk_size_gb             = 100
      
      image_publisher = "Canonical"
      image_offer     = "0001-com-ubuntu-server-focal"
      image_sku       = "20_04-lts-gen2"
      image_version   = "latest"
      
      # Enhanced security for database server
      secure_boot_enabled        = true
      vtpm_enabled              = true
      encryption_at_host_enabled = true
      enable_system_identity     = true
      
      tags = {
        Tier = "Database"
        Environment = "Production"
        Backup = "Required"
      }
    }
  }
}
```

### High-Security VM with Advanced Features

```hcl
module "secure_vm" {
  source = "./child_modules/Virtual-Machine"

  vm_rg_name     = "security-rg"
  vm_rg_location = "East US"

  virtual_machines = {
    "secure-server-01" = {
      size                    = "Standard_D4s_v3"
      admin_username         = "secureuser"
      network_interface_ids  = [azurerm_network_interface.secure.id]
      zone                   = "1"
      
      ssh_key_username = "secureuser"
      ssh_public_key   = file("~/.ssh/secure_key.pub")
      
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"
      os_disk_size_gb             = 64
      
      image_publisher = "Canonical"
      image_offer     = "0001-com-ubuntu-server-focal"
      image_sku       = "20_04-lts-gen2"
      image_version   = "latest"
      
      # Advanced security features
      secure_boot_enabled         = true
      vtpm_enabled               = true
      encryption_at_host_enabled  = true
      enable_system_identity      = true
      
      # VM security settings
      disable_password_authentication = true
      provision_vm_agent             = true
      allow_extension_operations     = true
      
      tags = {
        SecurityLevel = "High"
        Compliance    = "Required"
        Environment   = "Production"
      }
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.myvm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |

## Inputs

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| vm_rg_name | The name of the Azure Resource Group where the resources will be deployed | `string` |
| vm_rg_location | The Azure region where the resources will be deployed | `string` |
| virtual_machines | Map of virtual machine configurations | `map(object)` |

### virtual_machines Object Structure

Each VM in the `virtual_machines` map should have the following structure:

```hcl
{
  # Required fields
  size                    = string           # VM size (e.g., Standard_B1s, Standard_D2s_v3)
  admin_username         = string            # Admin username for the VM
  network_interface_ids  = list(string)      # List of network interface IDs to attach
  ssh_key_username       = string            # Username for SSH key (usually same as admin_username)
  ssh_public_key         = string            # SSH public key content
  os_disk_caching        = string            # None, ReadOnly, ReadWrite
  os_disk_storage_account_type = string      # Standard_LRS, StandardSSD_LRS, Premium_LRS
  os_disk_size_gb        = number            # Disk size in GB
  image_publisher        = string            # Image publisher
  image_offer           = string             # Image offer  
  image_sku             = string             # Image SKU
  image_version         = string             # Image version
  
  # Optional fields (with defaults)
  disable_password_authentication = optional(bool, true)    # Disable password auth
  provision_vm_agent             = optional(bool, true)     # Install VM agent
  allow_extension_operations     = optional(bool, true)     # Allow extensions
  zone                          = optional(string)          # Availability zone (e.g., "1", "2", "3")
  secure_boot_enabled           = optional(bool, false)     # Enable Secure Boot
  vtpm_enabled                  = optional(bool, false)     # Enable vTPM
  encryption_at_host_enabled    = optional(bool, false)     # Enable encryption at host
  enable_system_identity        = optional(bool, false)     # Enable system-assigned managed identity
  tags                          = optional(map(string), {}) # Resource tags
}
```

## Outputs

| Name | Description |
|------|-------------|
| vm_ids | Map of VM names to their Azure resource IDs |
| vm_names | List of all VM names created |
| vm_private_ips | Map of VM names to their primary private IP addresses |
| vm_details | Complete VM information including ID, name, size, admin username, and network details |

## Common VM Sizes

### General Purpose (B-Series - Burstable)
| Size | vCPUs | RAM | Use Case |
|------|-------|-----|----------|
| Standard_B1s | 1 | 1 GB | Light workloads, development |
| Standard_B2s | 2 | 4 GB | Small applications, web servers |
| Standard_B4ms | 4 | 16 GB | Medium applications |

### General Purpose (D-Series - Balanced)
| Size | vCPUs | RAM | Use Case |
|------|-------|-----|----------|
| Standard_D2s_v3 | 2 | 8 GB | Web servers, small databases |
| Standard_D4s_v3 | 4 | 16 GB | Enterprise applications |
| Standard_D8s_v3 | 8 | 32 GB | Large applications |

### Memory Optimized (E-Series)
| Size | vCPUs | RAM | Use Case |
|------|-------|-----|----------|
| Standard_E4s_v3 | 4 | 32 GB | In-memory databases |
| Standard_E8s_v3 | 8 | 64 GB | Large databases, analytics |

## Common Linux Images

### Ubuntu 20.04 LTS
```hcl
image_publisher = "Canonical"
image_offer     = "0001-com-ubuntu-server-focal"
image_sku       = "20_04-lts-gen2"
image_version   = "latest"
```

### Red Hat Enterprise Linux 8
```hcl
image_publisher = "RedHat"
image_offer     = "RHEL"
image_sku       = "8-lvm-gen2"
image_version   = "latest"
```

### CentOS 8
```hcl
image_publisher = "OpenLogic"
image_offer     = "CentOS"
image_sku       = "8_5-gen2"
image_version   = "latest"
```

### Debian 11
```hcl
image_publisher = "Debian"
image_offer     = "debian-11"
image_sku       = "11-gen2"
image_version   = "latest"
```

## Storage Options

| Type | Description | Performance | Use Case |
|------|-------------|-------------|----------|
| Standard_LRS | Standard HDD, locally redundant | Low IOPS | Development, backup |
| StandardSSD_LRS | Standard SSD, locally redundant | Medium IOPS | General workloads |
| Premium_LRS | Premium SSD, locally redundant | High IOPS | Production, databases |

## Security Features

### Secure Boot
- **Purpose**: Ensures that only trusted software can boot
- **Recommendation**: Enable for production workloads
- **Setting**: `secure_boot_enabled = true`

### vTPM (Virtual Trusted Platform Module)
- **Purpose**: Hardware-based security functions
- **Recommendation**: Enable with Secure Boot for enhanced security
- **Setting**: `vtpm_enabled = true`

### Encryption at Host
- **Purpose**: Encrypts data at the compute host level
- **Recommendation**: Enable for sensitive workloads
- **Setting**: `encryption_at_host_enabled = true`

### System-Assigned Managed Identity
- **Purpose**: Provides an identity for the VM to access Azure resources
- **Recommendation**: Enable when VM needs to access other Azure services
- **Setting**: `enable_system_identity = true`

## Best Practices

### Security
1. **SSH Keys**: Always use SSH key authentication instead of passwords
2. **Security Features**: Enable Secure Boot and vTPM for production VMs
3. **Encryption**: Use encryption at host for sensitive data
4. **Network Security**: Implement proper Network Security Groups on network interfaces
5. **Identity Management**: Use system-assigned managed identity when accessing Azure resources

### Performance
1. **VM Sizing**: Choose appropriate VM sizes based on workload requirements
2. **Storage**: Use Premium SSD for production workloads requiring high IOPS
3. **Availability Zones**: Distribute VMs across zones for high availability
4. **Proximity Placement**: Consider proximity placement groups for low-latency requirements

### Management
1. **Tagging**: Use consistent tagging strategy for resource organization
2. **Naming**: Follow consistent naming conventions
3. **Resource Groups**: Group related resources logically
4. **Monitoring**: Implement Azure Monitor for VM health and performance

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**
   - Verify SSH public key format
   - Check Network Security Group rules allow SSH (port 22)
   - Ensure correct SSH key username

2. **VM Creation Failed**
   - Check Azure subscription quotas
   - Verify resource group permissions
   - Ensure network interfaces exist before VM creation

3. **Disk Performance Issues**
   - Consider upgrading to Premium SSD
   - Check if encryption at host is needed
   - Verify disk size meets requirements

4. **Zone Deployment Failed**
   - Ensure VM size is available in specified zone
   - Check regional zone availability
   - Verify network resources are zone-compatible

### Debugging Commands

```bash
# Check VM status
az vm show --resource-group <rg-name> --name <vm-name> --query "provisioningState"

# Get VM details
az vm show --resource-group <rg-name> --name <vm-name>

# Check VM sizes available in region
az vm list-sizes --location <location>

# Verify SSH connectivity
ssh -i ~/.ssh/private_key azureuser@<vm-ip>
```

## Migration Guide

### From Individual Variables to Map-Based Configuration

If migrating from a module that uses individual variables, convert them to the map format:

```hcl
# Old approach (individual variables)
vm_name = "my-vm"
vm_size = "Standard_B2s"

# New approach (map-based)
virtual_machines = {
  "my-vm" = {
    size = "Standard_B2s"
    # ... other required fields
  }
}
```

## Examples Directory

Check the `examples/` directory for additional usage patterns and configurations for specific scenarios.

## License

This module is provided as-is for educational and development purposes.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes and add tests
4. Update documentation
5. Submit a pull request

## Support

For issues and questions:
- Create an issue in the repository
- Contact the module maintainer
- Refer to Azure documentation for resource-specific questions