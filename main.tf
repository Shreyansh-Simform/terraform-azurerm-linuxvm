# Create multiple/single Linux virtual machines using the configurations 
resource "azurerm_linux_virtual_machine" "myvm" {
  for_each = var.virtual_machines

  name                  = each.key
  location              = var.vm_rg_location
  resource_group_name   = var.vm_rg_name
  size                  = each.value.size
  admin_username        = each.value.admin_username
  network_interface_ids = each.value.network_interface_ids

  disable_password_authentication = each.value.disable_password_authentication
  provision_vm_agent              = each.value.provision_vm_agent
  allow_extension_operations      = each.value.allow_extension_operations

  zone          = lookup(each.value, "zone", null)

  secure_boot_enabled         = lookup(each.value, "secure_boot_enabled", false)
  vtpm_enabled                = lookup(each.value, "vtpm_enabled", false)
  encryption_at_host_enabled  = lookup(each.value, "encryption_at_host_enabled", false)

  identity {
    type = lookup(each.value, "enable_system_identity", false) ? "SystemAssigned" : "None"
  }

  os_disk {
    caching              = each.value.os_disk_caching
    storage_account_type = each.value.os_disk_storage_account_type
    disk_size_gb         = each.value.os_disk_size_gb
  }

  source_image_reference {
    publisher = each.value.image_publisher
    offer     = each.value.image_offer
    sku       = each.value.image_sku
    version   = each.value.image_version
  }

  admin_ssh_key {
    username   = each.value.ssh_key_username
    public_key = each.value.ssh_public_key
  }

  tags = lookup(each.value, "tags", {})

  lifecycle {
    prevent_destroy = true
    create_before_destroy = false
  }
}
