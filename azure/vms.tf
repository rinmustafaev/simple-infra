locals {
  vms = {
    vm1 = {
      name                   = "vm1"
      network_interface_name = "private-nic-vm1"
      os_disk_name           = "private-os-disk-vm1"
      computer_name          = "vm1"
    }
    vm2 = {
      name                   = "vm2"
      network_interface_name = "private-nic-vm2"
      os_disk_name           = "private-os-disk-vm2"
      computer_name          = "vm2"
    }
  }
}

resource "azurerm_network_interface" "private" {
  for_each = local.vms

  name                = each.value.network_interface_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "private-ip-config-${each.key}"
    subnet_id                     = azurerm_subnet.this["private"].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  for_each = local.vms

  name                  = each.value.name
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  network_interface_ids = [azurerm_network_interface.private[each.key].id]
  availability_set_id   = azurerm_availability_set.this.id
  size                  = "Standard_B1ls"

  admin_username                  = "adminuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = each.value.os_disk_name
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "vms" {
  name                = "vm-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_network_security_rule" "inbound_internal" {
  name                        = "allow-intercommunication"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.vms.name
}

resource "azurerm_network_security_rule" "outbound_all" {
  name                        = "allow-outbound"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "Internet"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.vms.name
}