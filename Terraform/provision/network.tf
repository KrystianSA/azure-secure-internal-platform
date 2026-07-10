resource "azurerm_bastion_host" "bastion_host" {
  location            = var.location
  name                = "vn-secure-internal-platform-Bastion"
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "Standard"
  ip_configuration {
    name                 = "IpConf"
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
    subnet_id            = azurerm_subnet.bastion_subnet.id
  }
}

resource "azurerm_network_security_group" "vm_nsg" {
  location            = var.location
  name                = "vm-workstation1-nsg"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_network_security_rule" "allow_rdp_from_bastion_rule" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "3389"
  direction                   = "Inbound"
  name                        = "AllowRDPFromBastion"
  network_security_group_name = "vm-workstation1-nsg"
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.resource_group.name
  source_address_prefix       = "10.0.1.0/26"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.vm_nsg,
  ]
}

resource "azurerm_network_security_rule" "deny_all_vnet_inbound_rule" {
  access                      = "Deny"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  direction                   = "Inbound"
  name                        = "DenyAllVnetInbound"
  network_security_group_name = "vm-workstation1-nsg"
  priority                    = 200
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.resource_group.name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.vm_nsg,
  ]
}

resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_private_dns_a_record" "private_dns_a_record" {
  name                = "sasecinternalplatform"
  records             = ["10.0.2.4"]
  resource_group_name = azurerm_resource_group.resource_group.name
  ttl                 = 3600
  zone_name           = "privatelink.blob.core.windows.net"
  depends_on = [
    azurerm_private_dns_zone.private_dns_zone,
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_vnet_link" {
  name                  = "otskfqfi7uhq2"
  private_dns_zone_name = "privatelink.blob.core.windows.net"
  resource_group_name   = azurerm_resource_group.resource_group.name
  virtual_network_id    = azurerm_virtual_network.virtual_network.id
  depends_on = [
    azurerm_private_dns_zone.private_dns_zone,
  ]
}

resource "azurerm_private_endpoint" "storage_private_endpoint" {
  location            = var.location
  name                = "pe-secure-internal-platform"
  resource_group_name = azurerm_resource_group.resource_group.name
  subnet_id           = azurerm_subnet.private_endpoint_subnet.id
  private_service_connection {
    is_manual_connection           = false
    name                           = "pe-secure-internal-platform_d5f09d0e-6228-4deb-898d-7ace0fd3b037"
    private_connection_resource_id = "/subscriptions/d38e5122-d146-4fb3-b1cd-b4b5449e32c4/resourcegroups/rg-secure-internal-platform/providers/Microsoft.Storage/storageAccounts/sasecinternalplatform"
    subresource_names              = ["blob"]
  }
}

resource "azurerm_public_ip" "bastion_public_ip" {
  allocation_method   = "Static"
  location            = var.location
  name                = "vn-secure-internal-platform-bastion"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_virtual_network" "virtual_network" {
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  name                = "vn-secure-internal-platform"
  resource_group_name = azurerm_resource_group.resource_group.name
  tags = {
    environment = "lab"
    project     = "secure-internal-platform"
  }
}

resource "azurerm_subnet" "bastion_subnet" {
  address_prefixes     = ["10.0.1.0/26"]
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = "vn-secure-internal-platform"
  depends_on = [
    azurerm_virtual_network.virtual_network,
  ]
}

resource "azurerm_subnet" "private_endpoint_subnet" {
  address_prefixes                = ["10.0.2.0/24"]
  default_outbound_access_enabled = false
  name                            = "snet-pe"
  resource_group_name             = azurerm_resource_group.resource_group.name
  virtual_network_name            = "vn-secure-internal-platform"
  depends_on = [
    azurerm_virtual_network.virtual_network,
  ]
}

resource "azurerm_subnet" "vm_subnet" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "snet-vm"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = "vn-secure-internal-platform"
  depends_on = [
    azurerm_virtual_network.virtual_network,
  ]
}