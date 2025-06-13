# Create multiple/single Linux virtual machines using the configurations 
resource "azurerm_resource_group" "vmrg" {
  name     = var.vm_rg_name
  location = var.vm_rg_location
  tags     = var.tags
}

resource "azurerm_virtual_network" "myvnet" {
  name                = var.vm_virtual_network_name
  address_space       = var.vm_vnet_address_space
  location            = var.vm_rg_location
  resource_group_name = azurerm_resource_group.vmrg.name
  tags                = var.tags
}

resource "azurerm_subnet" "vm-subnet" {
  name                 = var.vm_subnet_name
  resource_group_name  = azurerm_resource_group.vmrg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = var.vm_subnet_address_prefixes

  dynamic "delegation" {
    for_each = var.enable_subnet_delegation && var.delegation_service_name != null && var.delegation_service_actions != null ? [1] : []
    content {
      name = "delegation"

      service_delegation {
        name    = var.delegation_service_name
        actions = var.delegation_service_actions
      }
    }
  }
}

# Create Public IP Addresses
resource "azurerm_public_ip" "my-pubip" {
  for_each = var.public_ip_name
  
  name                = each.key
  resource_group_name = azurerm_resource_group.vmrg.name
  location            = var.vm_rg_location
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
  ip_version          = each.value.ip_version
  tags                = var.tags

  lifecycle {
    prevent_destroy = true
    create_before_destroy = false
  }
}

# Azure Network Security Group Resource
resource "azurerm_network_security_group" "network-nsg" {
  for_each = var.network_security_groups

  name                = each.key
  location            = var.vm_rg_location
  resource_group_name = azurerm_resource_group.vmrg.name
  tags                = var.tags
  
  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
  
  lifecycle {
    prevent_destroy = true
    create_before_destroy = false
  }
}

# Create Network Interfaces
resource "azurerm_network_interface" "vm-nic" {
  for_each = var.network_interfaces

  name                          = each.key
  location                      = var.vm_rg_location
  resource_group_name           = var.vm_rg_name
  tags                          = var.tags
  

  ip_configuration {
    name                          = "${each.key}-internal"
    subnet_id                     = azurerm_subnet.vm-subnet.id
    private_ip_address_allocation = each.value.private_ip_address_allocation
    private_ip_address           = each.value.private_ip_address_allocation == "Static" ? each.value.private_ip_address : null
    public_ip_address_id         = each.value.public_ip_name != null ? azurerm_public_ip.my-pubip[each.value.public_ip_name].id : null
  }

  lifecycle {
    prevent_destroy = true
    create_before_destroy = false
  }

  depends_on = [
    azurerm_subnet.vm-subnet,
    azurerm_public_ip.my-pubip
  ]
}

# Associate Network Security Groups with Network Interfaces
resource "azurerm_network_interface_security_group_association" "nic-nsg-association" {
  for_each = {
    for nic_name, nic_config in var.network_interfaces : nic_name => nic_config
    if lookup(nic_config, "network_security_group", null) != null
  }

  network_interface_id      = azurerm_network_interface.vm-nic[each.key].id
  network_security_group_id = azurerm_network_security_group.network-nsg[each.value.network_security_group].id

  depends_on = [
    azurerm_network_interface.vm-nic,
    azurerm_network_security_group.network-nsg
  ]
}

# Create multiple Linux Virtual Machines using the configurations provided in the variable
resource "azurerm_linux_virtual_machine" "myvm" {
  for_each = var.virtual_machines

  name                  = each.key
  location              = var.vm_rg_location
  resource_group_name   = azurerm_resource_group.vmrg.name
  size                  = each.value.size
  admin_username        = each.value.admin_username
  network_interface_ids = [for nic_name in each.value.network_interface_names : azurerm_network_interface.vm-nic[nic_name].id]
  admin_password        = lookup(each.value, "admin_password", null)  # Optional admin password
  tags                  = var.tags

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

  availability_set_id = each.value.availability_set_id != null ? each.value.availability_set_id : null
  custom_data = each.value.custom_data != null ? each.value.custom_data : null

  lifecycle {
    prevent_destroy = true
    create_before_destroy = false
  }
}
