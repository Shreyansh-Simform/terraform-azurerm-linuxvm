# Example: Using Mix of Existing and New Resources
# This example demonstrates how to use existing Public IPs, NICs, and Data Disks
# alongside creating new ones in the same deployment

module "hybrid_vm_deployment" {
  source = "../../"

  # Resource Group
  vm_rg_name     = "hybrid-vm-rg"
  vm_rg_location = "East US"

  # Virtual Network
  vm_virtual_network_name = "hybrid-vnet"
  vm_vnet_address_space   = ["10.0.0.0/16"]

  # Subnet
  vm_subnet_name               = "vm-subnet"
  vm_subnet_address_prefixes   = ["10.0.1.0/24"]

  # Mix of new and existing Public IPs
  public_ip_name = {
    # New Public IP - will be created
    "vm1-new-ip" = {
      allocation_method = "Static"
      sku              = "Standard"
      use_existing     = false
    }
    
    # Existing Public IP - will be referenced
    "vm2-existing-ip" = {
      allocation_method            = "Static"  # This will be ignored for existing IPs
      sku                         = "Standard" # This will be ignored for existing IPs
      use_existing                = true
      existing_resource_group_name = "existing-resources-rg"
    }
  }

  # Mix of new and existing Network Interfaces
  network_interfaces = {
    # New Network Interface - will be created
    "vm1-new-nic" = {
      subnet_name                   = "vm-subnet"
      private_ip_address_allocation = "Dynamic"
      public_ip_name               = "vm1-new-ip"
      use_existing                 = false
    }
    
    # Existing Network Interface - will be referenced
    "vm2-existing-nic" = {
      subnet_name                     = "vm-subnet"  # These fields are ignored for existing NICs
      private_ip_address_allocation   = "Dynamic"    # but kept for consistency
      use_existing                    = true
      existing_resource_group_name    = "existing-resources-rg"
    }
    
    # Another new NIC without public IP
    "vm3-internal-nic" = {
      subnet_name                   = "vm-subnet"
      private_ip_address_allocation = "Static"
      private_ip_address           = "10.0.1.10"
      use_existing                 = false
    }
  }

  # Network Security Groups (always new in this version)
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

  # Virtual Machines using mix of new and existing NICs
  virtual_machines = {
    "vm1-with-new-resources" = {
      size                    = "Standard_B2s"
      admin_username         = "azureuser"
      network_interface_names = ["vm1-new-nic"]
      
      # SSH Configuration
      ssh_key_username = "azureuser"
      ssh_public_key   = file("~/.ssh/id_rsa.pub")  # Replace with your public key path
      
      # OS Disk
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"
      os_disk_size_gb              = 30
      
      # Image
      image_publisher = "Canonical"
      image_offer     = "0001-com-ubuntu-server-jammy"
      image_sku       = "22_04-lts-gen2"
      image_version   = "latest"
      
      # Security
      disable_password_authentication = true
      secure_boot_enabled            = true
      vtpm_enabled                   = true
    }
    
    "vm2-with-existing-nic" = {
      size                    = "Standard_B1s"
      admin_username         = "azureuser"
      network_interface_names = ["vm2-existing-nic"]  # Uses existing NIC
      
      # SSH Configuration
      ssh_key_username = "azureuser"
      ssh_public_key   = file("~/.ssh/id_rsa.pub")
      
      # OS Disk
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"
      os_disk_size_gb              = 30
      
      # Image
      image_publisher = "Canonical"
      image_offer     = "0001-com-ubuntu-server-jammy"
      image_sku       = "22_04-lts-gen2"
      image_version   = "latest"
    }
    
    "vm3-internal-only" = {
      size                    = "Standard_B1s"
      admin_username         = "azureuser"
      network_interface_names = ["vm3-internal-nic"]  # No public IP
      
      # SSH Configuration
      ssh_key_username = "azureuser"
      ssh_public_key   = file("~/.ssh/id_rsa.pub")
      
      # OS Disk
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"
      os_disk_size_gb              = 30
      
      # Image
      image_publisher = "Canonical"
      image_offer     = "0001-com-ubuntu-server-jammy"
      image_sku       = "22_04-lts-gen2"
      image_version   = "latest"
    }
  }

  # Mix of new and existing data disks
  new_data_disks = {
    "vm1-data-disk-1" = {
      storage_account_type = "Premium_LRS"
      disk_size_gb        = 128
    }
    "vm1-data-disk-2" = {
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb        = 256
    }
  }

  existing_data_disks = {
    "existing-shared-disk" = {
      resource_group_name = "existing-storage-rg"
    }
  }

  # Data disk attachments
  vm_data_disk_attachments = {
    "vm1-attachment-1" = {
      vm_name   = "vm1-with-new-resources"
      disk_name = "vm1-data-disk-1"  # New disk
      lun       = 0
      caching   = "ReadWrite"
    }
    "vm1-attachment-2" = {
      vm_name   = "vm1-with-new-resources"
      disk_name = "vm1-data-disk-2"  # New disk
      lun       = 1
      caching   = "ReadOnly"
    }
    "vm2-attachment-existing" = {
      vm_name   = "vm2-with-existing-nic"
      disk_name = "existing-shared-disk"  # Existing disk
      lun       = 0
      caching   = "ReadWrite"
    }
  }

  # Tags
  tags = {
    Environment = "Development"
    Project     = "Hybrid-Infrastructure"
    Owner       = "DevOps-Team"
    CreatedBy   = "Terraform"
  }
}
