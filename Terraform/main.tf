# main.tf
resource "azurerm_storage_account" "main" {
  name                            = "sasecinternalplatform"
  resource_group_name             = "rg-secure-internal-platform"
  location                        = "polandcentral"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  allowed_copy_scope              = "AAD"
  default_to_oauth_authentication = true
  tags = {
    environment = "lab"
    project     = "secure-internal-platform"
  }
  lifecycle {
    ignore_changes = [shared_access_key_enabled]
  }
}
resource "azurerm_resource_group" "res-0" {
  location = "polandcentral"
  name     = "rg-secure-internal-platform"
  tags = {
    environment = "lab"
    project     = "secure-internal-platform"
  }
}
resource "azurerm_windows_virtual_machine" "res-1" {
  admin_password        = var.admin_password
  admin_username        = "adminKrystianSa"
  license_type          = "Windows_Client"
  location              = "polandcentral"
  name                  = "vm-workstation1"
  network_interface_ids = [azurerm_network_interface.res-4.id]
  #  os_managed_disk_id    = "/subscriptions/d38e5122-d146-4fb3-b1cd-b4b5449e32c4/resourceGroups/RG-SECURE-INTERNAL-PLATFORM/providers/Microsoft.Compute/disks/vm-workstation1_OsDisk_1_8ed303180768498fbd1849e5243d2db3"
  resource_group_name = azurerm_resource_group.res-0.name
  size                = "Standard_B2ts_v2"
  tags = {
    environment = "lab"
    project     = "secure-internal-platform"
  }
  additional_capabilities {
  }
  boot_diagnostics {
  }
  identity {
    type = "SystemAssigned"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    offer     = "Windows-10"
    publisher = "MicrosoftWindowsDesktop"
    sku       = "win10-22h2-ent"
    version   = "latest"
  }
  lifecycle {
    ignore_changes = [
      admin_password # ← Terraform nie będzie zmieniał hasła przy każdym apply!
    ]
  }
}
resource "azurerm_virtual_machine_extension" "res-2" {
  auto_upgrade_minor_version = true
  name                       = "AADLoginForWindows"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  settings = jsonencode({
    mdmId = ""
  })
  type                 = "AADLoginForWindows"
  type_handler_version = "1.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_bastion_host" "res-3" {
  location            = "polandcentral"
  name                = "vn-secure-internal-platform-Bastion"
  resource_group_name = azurerm_resource_group.res-0.name
  sku                 = "Standard"
  ip_configuration {
    name                 = "IpConf"
    public_ip_address_id = azurerm_public_ip.res-14.id
    subnet_id            = azurerm_subnet.res-16.id
  }
}
resource "azurerm_network_interface" "res-4" {
  location            = "polandcentral"
  name                = "vm-workstation1699"
  resource_group_name = azurerm_resource_group.res-0.name
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.res-18.id
  }
}
resource "azurerm_network_interface_security_group_association" "res-5" {
  network_interface_id      = azurerm_network_interface.res-4.id
  network_security_group_id = azurerm_network_security_group.res-6.id
}
resource "azurerm_network_security_group" "res-6" {
  location            = "polandcentral"
  name                = "vm-workstation1-nsg"
  resource_group_name = azurerm_resource_group.res-0.name
}
resource "azurerm_network_security_rule" "res-7" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "3389"
  direction                   = "Inbound"
  name                        = "AllowRDPFromBastion"
  network_security_group_name = "vm-workstation1-nsg"
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.res-0.name
  source_address_prefix       = "10.0.1.0/26"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-6,
  ]
}
resource "azurerm_network_security_rule" "res-8" {
  access                      = "Deny"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  direction                   = "Inbound"
  name                        = "DenyAllVnetInbound"
  network_security_group_name = "vm-workstation1-nsg"
  priority                    = 200
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.res-0.name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-6,
  ]
}
resource "azurerm_private_dns_zone" "res-9" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.res-0.name
}
resource "azurerm_private_dns_a_record" "res-10" {
  name                = "sasecinternalplatform"
  records             = ["10.0.2.4"]
  resource_group_name = azurerm_resource_group.res-0.name
  ttl                 = 3600
  zone_name           = "privatelink.blob.core.windows.net"
  depends_on = [
    azurerm_private_dns_zone.res-9,
  ]
}
resource "azurerm_private_dns_zone_virtual_network_link" "res-12" {
  name                  = "otskfqfi7uhq2"
  private_dns_zone_name = "privatelink.blob.core.windows.net"
  resource_group_name   = azurerm_resource_group.res-0.name
  virtual_network_id    = azurerm_virtual_network.res-15.id
  depends_on = [
    azurerm_private_dns_zone.res-9,
  ]
}
resource "azurerm_private_endpoint" "res-13" {
  location            = "polandcentral"
  name                = "pe-secure-internal-platform"
  resource_group_name = azurerm_resource_group.res-0.name
  subnet_id           = azurerm_subnet.res-17.id
  private_service_connection {
    is_manual_connection           = false
    name                           = "pe-secure-internal-platform_d5f09d0e-6228-4deb-898d-7ace0fd3b037"
    private_connection_resource_id = "/subscriptions/d38e5122-d146-4fb3-b1cd-b4b5449e32c4/resourcegroups/rg-secure-internal-platform/providers/Microsoft.Storage/storageAccounts/sasecinternalplatform"
    subresource_names              = ["blob"]
  }
}
resource "azurerm_public_ip" "res-14" {
  allocation_method   = "Static"
  location            = "polandcentral"
  name                = "vn-secure-internal-platform-bastion"
  resource_group_name = azurerm_resource_group.res-0.name
}
resource "azurerm_virtual_network" "res-15" {
  address_space       = ["10.0.0.0/16"]
  location            = "polandcentral"
  name                = "vn-secure-internal-platform"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    environment = "lab"
    project     = "secure-internal-platform"
  }
}
resource "azurerm_subnet" "res-16" {
  address_prefixes     = ["10.0.1.0/26"]
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.res-0.name
  virtual_network_name = "vn-secure-internal-platform"
  depends_on = [
    azurerm_virtual_network.res-15,
  ]
}
resource "azurerm_subnet" "res-17" {
  address_prefixes                = ["10.0.2.0/24"]
  default_outbound_access_enabled = false
  name                            = "snet-pe"
  resource_group_name             = azurerm_resource_group.res-0.name
  virtual_network_name            = "vn-secure-internal-platform"
  depends_on = [
    azurerm_virtual_network.res-15,
  ]
}
resource "azurerm_subnet" "res-18" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "snet-vm"
  resource_group_name  = azurerm_resource_group.res-0.name
  virtual_network_name = "vn-secure-internal-platform"
  depends_on = [
    azurerm_virtual_network.res-15,
  ]
}
resource "azurerm_storage_container" "res-21" {
  name               = "test"
  storage_account_id = "/subscriptions/d38e5122-d146-4fb3-b1cd-b4b5449e32c4/resourceGroups/rg-secure-internal-platform/providers/Microsoft.Storage/storageAccounts/sasecinternalplatform"
}
