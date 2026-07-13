resource "azurerm_windows_virtual_machine" "windows_vm_workstation" {
  admin_password        = var.admin_password
  admin_username        = "adminKrystianSa"
  license_type          = "Windows_Client"
  location              = var.location
  name                  = "vm-workstation1"
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  resource_group_name   = module.rg_secure_internal_platform.resource_group_name
  size                  = "Standard_B2ts_v2"
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
      admin_password
    ]
  }
}

resource "azurerm_virtual_machine_extension" "aad_login_extension" {
  auto_upgrade_minor_version = true
  name                       = "AADLoginForWindows"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  settings = jsonencode({
    mdmId = ""
  })
  type                 = "AADLoginForWindows"
  type_handler_version = "1.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.windows_vm_workstation.id
}

resource "azurerm_network_interface" "vm_nic" {
  location            = var.location
  name                = "vm-workstation1699"
  resource_group_name = module.rg_secure_internal_platform.resource_group_name
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vm_subnet.id
  }
}

resource "azurerm_network_interface_security_group_association" "vm_nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_role_assignment" "vm_role_assignment" {
  scope                = azurerm_windows_virtual_machine.windows_vm_workstation.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = data.azuread_user.Krystian.object_id
}
