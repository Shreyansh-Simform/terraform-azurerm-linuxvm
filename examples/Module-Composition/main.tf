# Root configuration that uses both modules
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Module A: Create network infrastructure
module "network_infrastructure" {
  source = "./child_modules/Network"  # Assuming you have a network module
  
  # Network module inputs
  resource_group_name = "shared-network-rg"
  location           = "East US"
  
  # Create some public IPs
  public_ips = {
    "shared-web-ip" = {
      allocation_method = "Static"
      sku              = "Standard"
    }
    "shared-db-ip" = {
      allocation_method = "Static"
      sku              = "Standard"
    }
  }
  
  # Create some NICs
  network_interfaces = {
    "shared-web-nic" = {
      subnet_id                     = "subnet-id-here"
      private_ip_address_allocation = "Dynamic"
      public_ip_name               = "shared-web-ip"
    }
    "shared-db-nic" = {
      subnet_id                     = "subnet-id-here"
      private_ip_address_allocation = "Static"
      private_ip_address           = "10.0.1.100"
    }
  }
  
  tags = {
    Environment = "Production"
    Project     = "SharedInfra"
  }
}

# Module B: Create VMs using resources from Module A
module "virtual_machines" {
  source = "./child_modules/Virtual-Machine"
  
  # VM module basic settings
  vm_rg_name     = "vm-workloads-rg"
  vm_rg_location = "East US"
  
  # Virtual Network settings (or use existing)
  vm_virtual_network_name = "vm-vnet"
  vm_vnet_address_space   = ["10.1.0.0/16"]
  vm_subnet_name          = "vm-subnet"
  vm_subnet_address_prefixes = ["10.1.1.0/24"]
  
  # 🔥 KEY: Use existing resources from Module A
  public_ip_name = {
    # Use existing IP from Module A
    "shared-web-ip" = {
      allocation_method            = "Static"  # Required but ignored
      sku                         = "Standard" # Required but ignored
      use_existing                = true
      existing_resource_group_name = module.network_infrastructure.resource_group_name
    }
    
    # Create new IP for this module
    "vm-new-ip" = {
      allocation_method = "Dynamic"
      sku              = "Basic"
      use_existing     = false
    }
  }
  
  network_interfaces = {
    # Use existing NIC from Module A
    "shared-web-nic" = {
      subnet_name                     = "ignored"  # Required but ignored for existing
      private_ip_address_allocation   = "ignored"  # Required but ignored for existing
      use_existing                    = true
      existing_resource_group_name    = module.network_infrastructure.resource_group_name
    }
    
    # Create new NIC in this module
    "vm-internal-nic" = {
      subnet_name                   = "vm-subnet"
      private_ip_address_allocation = "Dynamic"
      use_existing                 = false
    }
  }
  
  # Network Security Groups
  network_security_groups = {
    "vm-nsg" = {
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
  
  # Virtual Machines
  virtual_machines = {
    "web-server" = {
      size                    = "Standard_B2s"
      admin_username         = "azureuser"
      network_interface_names = ["shared-web-nic"]  # Uses existing NIC from Module A
      
      ssh_key_username = "azureuser"
      ssh_public_key   = file("~/.ssh/id_rsa.pub")
      
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"
      os_disk_size_gb              = 30
      
      image_publisher = "Canonical"
      image_offer     = "0001-com-ubuntu-server-jammy"
      image_sku       = "22_04-lts-gen2"
      image_version   = "latest"
    }
    
    "internal-server" = {
      size                    = "Standard_B1s"
      admin_username         = "azureuser"
      network_interface_names = ["vm-internal-nic"]  # Uses new NIC from this module
      
      ssh_key_username = "azureuser"
      ssh_public_key   = file("~/.ssh/id_rsa.pub")
      
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"
      os_disk_size_gb              = 30
      
      image_publisher = "Canonical"
      image_offer     = "0001-com-ubuntu-server-jammy"
      image_sku       = "22_04-lts-gen2"
      image_version   = "latest"
    }
  }
  
  tags = {
    Environment = "Production"
    Project     = "WebApp"
  }
  
  # Dependency to ensure network module completes first
  depends_on = [module.network_infrastructure]
}
