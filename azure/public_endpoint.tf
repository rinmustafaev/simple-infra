
resource "azurerm_public_ip" "this" {
  for_each            = { inbound = true, outbound = true }
  name                = "public-ip-${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "this" {
  name                = "load-balancer"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "public-ip-config"
    public_ip_address_id = azurerm_public_ip.this["inbound"].id
  }
  frontend_ip_configuration {
    name                 = "snat-config"
    public_ip_address_id = azurerm_public_ip.this["outbound"].id
  }
}

resource "azurerm_lb_backend_address_pool" "external_vms" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "external-address-pool"
}

resource "azurerm_lb_backend_address_pool" "all_vms" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "all-address-pool"
}

resource "azurerm_lb_rule" "inbound" {
  name                           = "AllowTLS"
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "public-ip-config"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.external_vms.id]
  probe_id                       = azurerm_lb_probe.tls.id
}

resource "azurerm_lb_probe" "tls" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "tls-probe"
  port            = 443
  protocol        = "Tcp"
}

resource "azurerm_network_interface_backend_address_pool_association" "external" {
  network_interface_id    = azurerm_network_interface.private["vm1"].id
  ip_configuration_name   = "private-ip-config-vm1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.external_vms.id
}

resource "azurerm_lb_outbound_rule" "this" {
  name                     = "outbound-rule"
  loadbalancer_id          = azurerm_lb.this.id
  protocol                 = "All"
  backend_address_pool_id  = azurerm_lb_backend_address_pool.all_vms.id
  allocated_outbound_ports = 512
  frontend_ip_configuration {
    name = "snat-config"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "all_vms" {
  for_each                = local.vms
  network_interface_id    = azurerm_network_interface.private[each.key].id
  ip_configuration_name   = "private-ip-config-${each.key}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.all_vms.id
}