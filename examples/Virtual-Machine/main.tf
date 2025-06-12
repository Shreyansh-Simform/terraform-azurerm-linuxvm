#Create a Resource Group
resource "azurerm_resource_group" "vm-rg" {
  name = var.resource_group_name
  location = var.resource_group_location
}

module "multi_tier_vms" {
  source = "./child_modules/Virtual-Machine"

  vm_rg_name     = azurerm_resource_group.vm_rg.name
  vm_rg_location = azurerm_resource_group.vm_rg.location

# Define multiple virtual machines with different configurations
  virtual_machines = {
    "web-server-01" = {
      size                    = "Standard_B2s"
      admin_username         = "azureuser"
      network_interface_ids  = [azurerm_network_interface.web1.id]
      zone                   = "1"
      
      ssh_key_username = "azureuser"
      ssh_public_key   = file("~/.ssh/id_rsa.pub") #Path to your SSH public key
      
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
      network_interface_ids  = [azurerm_network_interface.db1.id] #IDs of your craeted network interfaces
      # Ensure the network interface is created in the correct subnet
      # and has the necessary security rules to allow database traffic
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
      
      # VM security settings
      disable_password_authentication = true
      provision_vm_agent             = true
      allow_extension_operations     = true
      
        tags = {
            Tier = "Secure"
            Environment = "Production"
        }
      
    }
  }
}


