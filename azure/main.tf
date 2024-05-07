
locals {
  default_tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  subnet_configs = {
    public = {
      address_prefixes = ["10.0.1.0/24"]
    },
    private = {
      address_prefixes = ["10.0.2.0/24"]
    }
  }
}

resource "azurerm_resource_group" "this" {
  name     = "dev-rg"
  location = "West Europe"
}

resource "azurerm_virtual_network" "this" {
  name                = "dev-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  for_each             = local.subnet_configs
  name                 = each.key
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_availability_set" "this" {
  name                         = "availabilityset"
  location                     = azurerm_resource_group.this.location
  resource_group_name          = azurerm_resource_group.this.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}