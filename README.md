# Azure Virtual Machine Terraform Module

This Terraform module creates a complete Azure Virtual Machine infrastructure including resource groups, virtual networks, subnets, network security groups, public IPs, network interfaces, and multiple Linux Virtual Machines. The module uses a map-based approach for flexible single or multi-VM deployments with comprehensive networking capabilities.

## Features

- ✅ **Complete Infrastructure**: Creates all necessary networking components
- ✅ **Multiple VM Support**: Deploy one or multiple VMs using a single module call
- ✅ **Linux Virtual Machines**: Optimized for Linux-based workloads
- ✅ **Comprehensive Networking**: Automatic creation of VNet, subnet, NICs, and Public IPs
- ✅ **Network Security Groups**: Configurable security rules per network interface
- ✅ **SSH Key Authentication**: Secure access with SSH public keys
- ✅ **Advanced Security Options**: Support for Secure Boot, vTPM, and encryption at host
- ✅ **Flexible Storage**: Multiple disk types and sizes with customizable caching
- ✅ **Availability Zones**: Support for Azure Availability Zones
- ✅ **Managed Identity**: Optional system-assigned managed identity
- ✅ **Subnet Delegation**: Optional subnet delegation for specialized services
- ✅ **Custom Data Support**: Bootstrap scripts and cloud-init support

## Architecture

The module creates a complete virtual machine infrastructure:
1. **Resource Group**: Central container for all resources
2. **Virtual Network & Subnet**: Network foundation with optional delegation
3. **Public IP Addresses**: Configurable static/dynamic public IPs
4. **Network Security Groups**: Firewall rules and security policies
5. **Network Interfaces**: VM network connectivity with NSG associations
6. **Linux Virtual Machines**: Configurable VMs with advanced security features

## Usage Examples

### Complete Single VM Deployment

```hcl
module "single_vm_complete" {
  source = "./child_modules/Virtual-Machine"

  # Resource Group
  vm_rg_name     = "my-vm-rg"
  vm_rg_location = "East US"

  # Virtual Network
  vm_virtual_network_name = "my-vnet"
  vm_vnet_address_space   = ["10.0.0.0/16"]

  # Subnet
  vm_subnet_name               = "default-subnet"
  vm_subnet_address_prefixes   = ["10.0.1.0/24"]
  enable_subnet_delegation     = false

  # Public IPs
  public_ip_name = {
    "web-server-pip" = {
      allocation_method = "Static"
      sku              = "Standard"
      ip_version       = "IPv4"
    }
  }

  # Network Security Groups
  network_security_groups = {
    "web-nsg" = {
      security_rules = [
        {
          name                       = "SSH"
          priority                   = 1001
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "HTTP"
          priority                   = 1002
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  }

  # Network Interfaces
  network_interfaces = {
    "web-server-nic" = {
      subnet_name                   = "default-subnet"
      private_ip_address_allocation = "Dynamic"
      public_ip_name               = "web-server-pip"
      enable_ip_forwarding         = false
      enable_accelerated_networking = false
      network_security_group       = "web-nsg"
    }
  }

  # Virtual Machines
  virtual_machines = {
    "web-server-01" = {
      size                    = "Standard_B2s"
      admin_username         = "azureuser"
      network_interface_names = ["web-server-nic"]
      
      ssh_key_username = "azureuser"
      ssh_public_key   = file("~/.ssh/id_rsa.pub")
      
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"
      os_disk_size_gb             = 30
      
      image_publisher = "Canonical"
      image_offer     = "0001-com-ubuntu-server-focal"
      image_sku       = "20_04-lts-gen2"
      image_version   = "latest"
      
      zone = "1"
    }
  }
}
```

### Multi-Tier Application with 3 VMs

```hcl
module "multi_tier_infrastructure" {
  source = "./child_modules/Virtual-Machine"

  # Resource Group
  vm_rg_name     = "multi-tier-rg"
  vm_rg_location = "East US"

  # Virtual Network
  vm_virtual_network_name = "app-vnet"
  vm_vnet_address_space   = ["10.0.0.0/16"]

  # Subnet
  vm_subnet_name               = "app-subnet"
  vm_subnet_address_prefixes   = ["10.0.1.0/24"]
  enable_subnet_delegation     = false

  # Public IPs
  public_ip_name = {
    "web-pip" = {
      allocation_method = "Static"
      sku              = "Standard"
    }
    "bastion-pip" = {
      allocation_method = "Static"
      sku              = "Standard"
    }
  }

  # Network Security Groups
  network_security_groups = {
    "web-nsg" = {
      security_rules = [
        {
          name                       = "HTTP"
          priority                   = 1001
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "HTTPS"
          priority                   = 1002
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
    "app-nsg" = {
      security_rules = [
        {
          name                       = "AppPort"
          priority                   = 1001
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "8080"
          source_address_prefix      = "10.0.1.0/24"
          destination_address_prefix = "*"
        }
      ]
    }
    "db-nsg" = {
      security_rules = [
        {
          name                       = "MySQL"
          priority                   = 1001
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "3306"
          source_address_prefix      = "10.0.1.0/24"
          destination_address_prefix = "*"
        }
      ]
    }
    "ssh-nsg" = {
      security_rules = [
        {
          name                       = "SSH"
          priority                   = 1001
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  }

  # Network Interfaces
  network_interfaces = {
    "web-nic" = {
      subnet_name                   = "app-subnet"
      private_ip_address_allocation = "Static"
      private_ip_address           = "10.0.1.10"
      public_ip_name               = "web-pip"
      network_security_group       = "web-nsg"
    }
    "app-nic" = {
      subnet_name                   = "app-subnet"
      private_ip_address_allocation = "Static"
      private_ip_address           = "10.0.1.20"
      network_security_group       = "app-nsg"
    }
    "db-nic" = {
      subnet_name                   = "app-subnet"
      private_ip_address_allocation = "Static"
      private_ip_address           = "10.0.1.30"
      network_security_group       = "db-nsg"
    }
    "bastion-nic" = {
      subnet_name                   = "app-subnet"
      private_ip_address_allocation = "Dynamic"
      public_ip_name               = "bastion-pip"
      network_security_group       = "ssh-nsg"
    }
  }

  # Virtual Machines
  virtual_machines = {
    "web-server" = {
      size                    = "Standard_B2s"
      admin_username         = "azureuser"
      network_interface_names = ["web-nic"]
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
      
      custom_data = base64encode(file("./scripts/web-server-init.sh"))
    }
    
    "app-server" = {
      size                    = "Standard_D2s_v3"
      admin_username         = "azureuser"
      network_interface_names = ["app-nic"]
      zone                   = "2"
      
      ssh_key_username = "azureuser"
      ssh_public_key   = file("~/.ssh/id_rsa.pub")
      
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"
      os_disk_size_gb             = 50
      
      image_publisher = "Canonical"
      image_offer     = "0001-com-ubuntu-server-focal"
      image_sku       = "20_04-lts-gen2"
      image_version   = "latest"
      
      enable_system_identity = true
      custom_data = base64encode(file("./scripts/app-server-init.sh"))
    }
    
    "db-server" = {
      size                    = "Standard_E4s_v3"
      admin_username         = "azureuser"
      network_interface_names = ["db-nic"]
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
      
      # Enhanced security for database
      secure_boot_enabled        = true
      vtpm_enabled              = true
      encryption_at_host_enabled = true
      enable_system_identity     = true
      
      custom_data = base64encode(file("./scripts/db-server-init.sh"))
    }
  }
}
```

### High-Security VM with Container Instance Subnet Delegation

```hcl
module "secure_vm_with_delegation" {
  source = "./child_modules/Virtual-Machine"

  # Resource Group
  vm_rg_name     = "security-rg"
  vm_rg_location = "East US"

  # Virtual Network
  vm_virtual_network_name = "secure-vnet"
  vm_vnet_address_space   = ["10.1.0.0/16"]

  # Subnet with delegation
  vm_subnet_name               = "delegated-subnet"
  vm_subnet_address_prefixes   = ["10.1.1.0/24"]
  enable_subnet_delegation     = true
  delegation_service_name      = "Microsoft.ContainerInstance/containerGroups"
  delegation_service_actions   = [
    "Microsoft.Network/virtualNetworks/subnets/action"
  ]

  # Public IPs
  public_ip_name = {
    "secure-pip" = {
      allocation_method = "Static"
      sku              = "Standard"
    }
  }

  # Network Security Groups
  network_security_groups = {
    "secure-nsg" = {
      security_rules = [
        {
          name                       = "SSH-Restricted"
          priority                   = 1001
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "YOUR_IP_ADDRESS/32"  # Replace with your IP
          destination_address_prefix = "*"
        }
      ]
    }
  }

  # Network Interfaces
  network_interfaces = {
    "secure-nic" = {
      subnet_name                   = "delegated-subnet"
      private_ip_address_allocation = "Static"
      private_ip_address           = "10.1.1.10"
      public_ip_name               = "secure-pip"
      enable_accelerated_networking = true
      network_security_group       = "secure-nsg"
    }
  }

  # Virtual Machines
  virtual_machines = {
    "secure-server" = {
      size                    = "Standard_D4s_v3"
      admin_username         = "secureuser"
      network_interface_names = ["secure-nic"]
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
      
      # Maximum security configuration
      secure_boot_enabled         = true
      vtpm_enabled               = true
      encryption_at_host_enabled  = true
      enable_system_identity      = true
      
      disable_password_authentication = true
      provision_vm_agent             = true
      allow_extension_operations     = true
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

## Resources Created

| Resource Type | Description |
|---------------|-------------|
| azurerm_resource_group | Resource group container |
| azurerm_virtual_network | Virtual network foundation |
| azurerm_subnet | Subnet with optional delegation |
| azurerm_public_ip | Static/Dynamic public IP addresses |
| azurerm_network_security_group | Security groups with custom rules |
| azurerm_network_interface | VM network interfaces |
| azurerm_network_interface_security_group_association | NSG-NIC associations |
| azurerm_linux_virtual_machine | Linux virtual machines |

## Input Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| vm_rg_name | Resource group name | `string` |
| vm_rg_location | Azure region | `string` |
| vm_virtual_network_name | Virtual network name | `string` |
| vm_vnet_address_space | VNet address space | `list(string)` |
| vm_subnet_name | Subnet name | `string` |
| vm_subnet_address_prefixes | Subnet address prefixes | `list(string)` |
| public_ip_name | Public IP configurations | `map(object)` |
| network_interfaces | Network interface configurations | `map(object)` |
| virtual_machines | Virtual machine configurations | `map(object)` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| enable_subnet_delegation | Enable subnet delegation | `bool` | `false` |
| delegation_service_name | Delegation service name | `string` | `null` |
| delegation_service_actions | Delegation actions | `list(string)` | `null` |
| network_security_groups | NSG configurations | `map(object)` | `{}` |

### Variable Structures

#### public_ip_name Object
```hcl
{
  allocation_method = string  # "Static" or "Dynamic"
  sku              = string  # "Basic" or "Standard" (optional, default: "Basic")
  ip_version       = string  # "IPv4" or "IPv6" (optional, default: "IPv4")
}
```

#### network_interfaces Object
```hcl
{
  subnet_name                   = string           # Reference to subnet
  private_ip_address_allocation = string           # "Static" or "Dynamic"
  private_ip_address           = string           # Required if Static (optional)
  public_ip_name               = string           # Reference to public IP (optional)
  enable_ip_forwarding         = bool             # Enable IP forwarding (optional, default: false)
  enable_accelerated_networking = bool             # Enable accelerated networking (optional, default: false)
  network_security_group       = string           # Reference to NSG (optional)
}
```

#### virtual_machines Object
```hcl
{
  # Required
  size                    = string           # VM size
  admin_username         = string            # Admin username
  network_interface_names = list(string)     # List of NIC names
  ssh_key_username       = string            # SSH username
  ssh_public_key         = string            # SSH public key
  os_disk_caching        = string            # "None", "ReadOnly", "ReadWrite"
  os_disk_storage_account_type = string      # "Standard_LRS", "StandardSSD_LRS", "Premium_LRS"
  os_disk_size_gb        = number            # Disk size in GB
  image_publisher        = string            # Image publisher
  image_offer           = string             # Image offer
  image_sku             = string             # Image SKU
  image_version         = string             # Image version
  
  # Optional
  admin_password         = string            # Admin password (optional)
  disable_password_authentication = bool     # Disable password auth (optional, default: true)
  provision_vm_agent     = bool             # Install VM agent (optional, default: true)
  allow_extension_operations = bool         # Allow extensions (optional, default: true)
  zone                   = string            # Availability zone (optional)
  secure_boot_enabled    = bool             # Enable Secure Boot (optional, default: false)
  vtpm_enabled          = bool             # Enable vTPM (optional, default: false)
  encryption_at_host_enabled = bool         # Enable encryption at host (optional, default: false)
  enable_system_identity = bool             # Enable managed identity (optional, default: false)
  availability_set_id    = string            # Availability set ID (optional)
  custom_data           = string             # Base64 custom data (optional)
}
```

## Output Values

### Resource Outputs
| Name | Description |
|------|-------------|
| resource_group_id | Resource group ID |
| resource_group_name | Resource group name |
| virtual_network_id | Virtual network ID |
| subnet_id | Subnet ID |

### Network Outputs
| Name | Description |
|------|-------------|
| public_ip_ids | Map of public IP names to IDs |
| public_ip_addresses | Map of public IP names to addresses |
| network_interface_ids | Map of NIC names to IDs |
| network_interface_private_ips | Map of NIC names to private IPs |
| network_security_group_ids | Map of NSG names to IDs |

### VM Outputs
| Name | Description |
|------|-------------|
| vm_ids | Map of VM names to IDs |
| vm_names | List of VM names |
| vm_private_ips | Map of VM names to private IPs |
| vm_sizes | Map of VM names to sizes |
| vm_zones | Map of VM names to zones |
| vm_details | Complete VM information |
| deployment_summary | Summary of all resources |

## Best Practices

### Security
1. **Network Segmentation**: Use separate subnets for different tiers
2. **NSG Rules**: Implement least-privilege security rules
3. **SSH Keys**: Always use SSH keys instead of passwords
4. **Private IPs**: Use static private IPs for servers
5. **Security Features**: Enable Secure Boot, vTPM for production
6. **Encryption**: Use Premium SSD with encryption at host

### Networking
1. **IP Planning**: Plan IP address spaces carefully
2. **Public IPs**: Use Standard SKU for production
3. **Accelerated Networking**: Enable for performance-critical VMs
4. **Load Balancing**: Consider Azure Load Balancer for multiple VMs

### Performance
1. **VM Sizing**: Right-size VMs based on workload
2. **Storage**: Use Premium SSD for I/O intensive workloads
3. **Zones**: Distribute VMs across availability zones
4. **Proximity**: Use proximity placement groups for low latency

### Management
1. **Naming**: Use consistent naming conventions
2. **Tagging**: Implement comprehensive tagging strategy
3. **Monitoring**: Enable Azure Monitor and diagnostics
4. **Backup**: Implement Azure Backup for critical VMs

## Common Configurations

### Web Server with Load Balancer Ready
```hcl
# Multiple web servers behind a load balancer
virtual_machines = {
  "web-01" = {
    size = "Standard_B2s"
    zone = "1"
    # ... other config
  }
  "web-02" = {
    size = "Standard_B2s" 
    zone = "2"
    # ... other config
  }
  "web-03" = {
    size = "Standard_B2s"
    zone = "3" 
    # ... other config
  }
}
```

### Development Environment
```hcl
# Single VM for development
virtual_machines = {
  "dev-vm" = {
    size = "Standard_B1s"
    os_disk_storage_account_type = "Standard_LRS"
    disable_password_authentication = false
    admin_password = "YourSecurePassword123!"
    # ... other config
  }
}
```

## Troubleshooting

### Common Issues
1. **VM Size Availability**: Check if VM size is available in selected zone
2. **IP Address Conflicts**: Ensure static IPs don't conflict
3. **NSG Rules**: Verify security rules allow required traffic
4. **Subnet Delegation**: Some services require specific delegation
5. **Public IP SKU**: Standard SKU required for zone deployment

### Validation Commands
```bash
# Validate configuration
terraform validate

# Plan deployment
terraform plan

# Check VM sizes in region
az vm list-sizes --location "East US"

# Verify network connectivity
az network nic show --name <nic-name> --resource-group <rg-name>
```

## Examples Directory

The `examples/` directory contains additional usage patterns for specific scenarios.

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