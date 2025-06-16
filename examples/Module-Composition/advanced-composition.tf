# Alternative approach: Pass module outputs directly as variables
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

# Module A: Network Infrastructure
module "shared_network" {
  source = "./child_modules/Network"
  
  # Network configuration
  resource_group_name = "shared-infra-rg"
  location           = "East US"
  
  # Network resources
  virtual_networks = {
    "shared-vnet" = {
      address_space = ["10.0.0.0/16"]
    }
  }
  
  subnets = {
    "web-subnet" = {
      address_prefixes = ["10.0.1.0/24"]
      vnet_name       = "shared-vnet"
    }
    "db-subnet" = {
      address_prefixes = ["10.0.2.0/24"]
      vnet_name       = "shared-vnet"
    }
  }
  
  public_ips = {
    "loadbalancer-ip" = {
      allocation_method = "Static"
      sku              = "Standard"
    }
    "management-ip" = {
      allocation_method = "Static"
      sku              = "Standard"
    }
  }
  
  network_interfaces = {
    "web-server-nic" = {
      subnet_name                   = "web-subnet"
      private_ip_address_allocation = "Dynamic"
      public_ip_name               = "loadbalancer-ip"
    }
    "db-server-nic" = {
      subnet_name                   = "db-subnet"
      private_ip_address_allocation = "Static"
      private_ip_address           = "10.0.2.10"
    }
    "management-nic" = {
      subnet_name                   = "web-subnet"
      private_ip_address_allocation = "Dynamic"
      public_ip_name               = "management-ip"
    }
  }
}

# Module B: Virtual Machines using shared network resources
module "application_vms" {
  source = "./child_modules/Virtual-Machine"
  
  # Basic VM settings
  vm_rg_name     = "application-vms-rg"
  vm_rg_location = "East US"
  
  # Use existing network from shared module
  vm_virtual_network_name     = "app-vnet"  # Create new VNET for VMs if needed
  vm_vnet_address_space       = ["10.1.0.0/16"]
  vm_subnet_name              = "app-subnet"
  vm_subnet_address_prefixes  = ["10.1.1.0/24"]
  
  # 🔥 METHOD 1: Reference existing resources by name and RG
  public_ip_name = {
    # Use existing IP from shared network module
    "loadbalancer-ip" = {
      allocation_method            = "Static"
      sku                         = "Standard"
      use_existing                = true
      existing_resource_group_name = module.shared_network.resource_group_name
    }
    "management-ip" = {
      allocation_method            = "Static"
      sku                         = "Standard"
      use_existing                = true
      existing_resource_group_name = module.shared_network.resource_group_name
    }
  }
  
  network_interfaces = {
    # Use existing NICs from shared network module
    "web-server-nic" = {
      subnet_name                     = "ignored"
      private_ip_address_allocation   = "ignored"
      use_existing                    = true
      existing_resource_group_name    = module.shared_network.resource_group_name
    }
    "db-server-nic" = {
      subnet_name                     = "ignored"
      private_ip_address_allocation   = "ignored"
      use_existing                    = true
      existing_resource_group_name    = module.shared_network.resource_group_name
    }
    "management-nic" = {
      subnet_name                     = "ignored"
      private_ip_address_allocation   = "ignored"
      use_existing                    = true
      existing_resource_group_name    = module.shared_network.resource_group_name
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
          source_address_prefix      = "10.0.1.0/24"  # Only from web subnet
          destination_address_prefix = "*"
        }
      ]
    }
  }
  
  # Virtual Machines using existing network resources
  virtual_machines = {
    "web-server-01" = {
      size                    = "Standard_D2s_v3"
      admin_username         = "webadmin"
      network_interface_names = ["web-server-nic"]  # Uses existing NIC
      
      ssh_key_username = "webadmin"
      ssh_public_key   = file("~/.ssh/web_rsa.pub")
      
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"
      os_disk_size_gb              = 50
      
      image_publisher = "Canonical"
      image_offer     = "0001-com-ubuntu-server-jammy"
      image_sku       = "22_04-lts-gen2"
      image_version   = "latest"
      
      # Custom data for web server setup
      custom_data = base64encode(<<-EOF
        #!/bin/bash
        apt-get update
        apt-get install -y nginx
        systemctl start nginx
        systemctl enable nginx
        EOF
      )
    }
    
    "db-server-01" = {
      size                    = "Standard_D4s_v3"
      admin_username         = "dbadmin"
      network_interface_names = ["db-server-nic"]  # Uses existing NIC
      
      ssh_key_username = "dbadmin"
      ssh_public_key   = file("~/.ssh/db_rsa.pub")
      
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"
      os_disk_size_gb              = 100
      
      image_publisher = "Canonical"
      image_offer     = "0001-com-ubuntu-server-jammy"
      image_sku       = "22_04-lts-gen2"
      image_version   = "latest"
      
      # Custom data for database server setup
      custom_data = base64encode(<<-EOF
        #!/bin/bash
        apt-get update
        apt-get install -y mysql-server
        systemctl start mysql
        systemctl enable mysql
        EOF
      )
    }
    
    "management-server" = {
      size                    = "Standard_B2s"
      admin_username         = "mgmtadmin"
      network_interface_names = ["management-nic"]  # Uses existing NIC
      
      ssh_key_username = "mgmtadmin"
      ssh_public_key   = file("~/.ssh/mgmt_rsa.pub")
      
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
    Application = "WebApp"
    Tier        = "Application"
  }
  
  # Ensure network module completes before VM module
  depends_on = [module.shared_network]
}

# Alternative approach: Direct resource ID passing
# This would require enhancing your VM module's variables.tf

# Example of how you could modify variables.tf to accept direct IDs:
variable "existing_resource_ids" {
  description = "Direct resource IDs from other modules"
  type = object({
    public_ip_ids = optional(map(string), {})      # Map of name -> resource ID
    nic_ids       = optional(map(string), {})      # Map of name -> resource ID  
    disk_ids      = optional(map(string), {})      # Map of name -> resource ID
  })
  default = {
    public_ip_ids = {}
    nic_ids       = {}
    disk_ids      = {}
  }
}

# Then in your root main.tf you could do:
module "vm_with_direct_ids" {
  source = "./child_modules/Virtual-Machine"
  
  # ... other variables ...
  
  # Pass resource IDs directly from other modules
  existing_resource_ids = {
    public_ip_ids = {
      "shared-ip-1" = module.network_infrastructure.public_ip_ids["web-ip"]
      "shared-ip-2" = module.network_infrastructure.public_ip_ids["db-ip"]
    }
    nic_ids = {
      "shared-nic-1" = module.network_infrastructure.nic_ids["web-nic"]
      "shared-nic-2" = module.network_infrastructure.nic_ids["db-nic"]
    }
    disk_ids = {
      "shared-disk-1" = module.storage_infrastructure.disk_ids["data-disk"]
    }
  }
}
