# Example: Complete Multi-Tier Infrastructure with Virtual Machines
# This example demonstrates creating a complete infrastructure with multiple VMs,
# networking components, and security configurations using the VM module

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Example 1: Complete Single VM Infrastructure
module "single_vm_example" {
  source = "../../"  # Points to the Virtual-Machine module

  # Resource Group Configuration
  vm_rg_name     = var.single_vm_rg_name
  vm_rg_location = var.location

  # Virtual Network Configuration
  vm_virtual_network_name = "single-vm-vnet"
  vm_vnet_address_space   = ["10.0.0.0/16"]

  # Subnet Configuration
  vm_subnet_name               = "default-subnet"
  vm_subnet_address_prefixes   = ["10.0.1.0/24"]
  enable_subnet_delegation     = false

  # Public IP Configuration
  public_ip_name = {
    "single-vm-pip" = {
      allocation_method = "Static"
      sku              = "Standard"
      ip_version       = "IPv4"
    }
  }

  # Network Security Groups
  network_security_groups = {
    "single-vm-nsg" = {
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

  # Network Interface Configuration
  network_interfaces = {
    "single-vm-nic" = {
      subnet_name                   = "default-subnet"
      private_ip_address_allocation = "Dynamic"
      public_ip_name               = "single-vm-pip"
      enable_ip_forwarding         = false
      enable_accelerated_networking = false
      network_security_group       = "single-vm-nsg"
    }
  }

  # Virtual Machine Configuration
  virtual_machines = {
    "web-server" = {
      size                    = var.vm_size
      admin_username         = var.admin_username
      network_interface_names = ["single-vm-nic"]
      
      ssh_key_username = var.admin_username
      ssh_public_key   = var.ssh_public_key
      
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

# Example 2: Multi-Tier Application Infrastructure
module "multi_tier_example" {
  source = "../../"  # Points to the Virtual-Machine module

  # Resource Group Configuration
  vm_rg_name     = var.multi_tier_rg_name
  vm_rg_location = var.location

  # Virtual Network Configuration
  vm_virtual_network_name = "multi-tier-vnet"
  vm_vnet_address_space   = ["10.1.0.0/16"]

  # Subnet Configuration
  vm_subnet_name               = "app-subnet"
  vm_subnet_address_prefixes   = ["10.1.1.0/24"]
  enable_subnet_delegation     = false

  # Public IP Configuration
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
          source_address_prefix      = "10.1.1.0/24"
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
          source_address_prefix      = "10.1.1.0/24"
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

  # Network Interface Configuration
  network_interfaces = {
    "web-nic" = {
      subnet_name                   = "app-subnet"
      private_ip_address_allocation = "Static"
      private_ip_address           = "10.1.1.10"
      public_ip_name               = "web-pip"
      network_security_group       = "web-nsg"
    }
    "app-nic" = {
      subnet_name                   = "app-subnet"
      private_ip_address_allocation = "Static"
      private_ip_address           = "10.1.1.20"
      network_security_group       = "app-nsg"
    }
    "db-nic" = {
      subnet_name                   = "app-subnet"
      private_ip_address_allocation = "Static"
      private_ip_address           = "10.1.1.30"
      network_security_group       = "db-nsg"
    }
    "bastion-nic" = {
      subnet_name                   = "app-subnet"
      private_ip_address_allocation = "Dynamic"
      public_ip_name               = "bastion-pip"
      network_security_group       = "ssh-nsg"
    }
  }

  # Virtual Machine Configuration
  virtual_machines = {
    "web-server" = {
      size                    = "Standard_B2s"
      admin_username         = var.admin_username
      network_interface_names = ["web-nic"]
      zone                   = "1"
      
      ssh_key_username = var.admin_username
      ssh_public_key   = var.ssh_public_key
      
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"
      os_disk_size_gb             = 30
      
      image_publisher = "Canonical"
      image_offer     = "0001-com-ubuntu-server-focal"
      image_sku       = "20_04-lts-gen2"
      image_version   = "latest"
    }
    
    "app-server" = {
      size                    = "Standard_D2s_v3"
      admin_username         = var.admin_username
      network_interface_names = ["app-nic"]
      zone                   = "2"
      
      ssh_key_username = var.admin_username
      ssh_public_key   = var.ssh_public_key
      
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"
      os_disk_size_gb             = 50
      
      image_publisher = "Canonical"
      image_offer     = "0001-com-ubuntu-server-focal"
      image_sku       = "20_04-lts-gen2"
      image_version   = "latest"
      
      enable_system_identity = true
    }
    
    "db-server" = {
      size                    = "Standard_E4s_v3"
      admin_username         = var.admin_username
      network_interface_names = ["db-nic"]
      zone                   = "3"
      
      ssh_key_username = var.admin_username
      ssh_public_key   = var.ssh_public_key
      
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
      
      disable_password_authentication = true
      provision_vm_agent             = true
      allow_extension_operations     = true
    }
  }
}

# Example 3: High-Security VM with Subnet Delegation
module "secure_vm_example" {
  source = "../../"  # Points to the Virtual-Machine module

  # Resource Group Configuration
  vm_rg_name     = var.secure_vm_rg_name
  vm_rg_location = var.location

  # Virtual Network Configuration
  vm_virtual_network_name = "secure-vnet"
  vm_vnet_address_space   = ["10.2.0.0/16"]

  # Subnet Configuration with Delegation
  vm_subnet_name               = "delegated-subnet"
  vm_subnet_address_prefixes   = ["10.2.1.0/24"]
  enable_subnet_delegation     = true
  delegation_service_name      = "Microsoft.ContainerInstance/containerGroups"
  delegation_service_actions   = [
    "Microsoft.Network/virtualNetworks/subnets/action"
  ]

  # Public IP Configuration
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
          source_address_prefix      = var.allowed_ssh_source_ip
          destination_address_prefix = "*"
        }
      ]
    }
  }

  # Network Interface Configuration
  network_interfaces = {
    "secure-nic" = {
      subnet_name                   = "delegated-subnet"
      private_ip_address_allocation = "Static"
      private_ip_address           = "10.2.1.10"
      public_ip_name               = "secure-pip"
      enable_accelerated_networking = true
      network_security_group       = "secure-nsg"
    }
  }

  # Virtual Machine Configuration
  virtual_machines = {
    "secure-server" = {
      size                    = "Standard_D4s_v3"
      admin_username         = var.admin_username
      network_interface_names = ["secure-nic"]
      zone                   = "1"
      
      ssh_key_username = var.admin_username
      ssh_public_key   = var.ssh_public_key
      
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


