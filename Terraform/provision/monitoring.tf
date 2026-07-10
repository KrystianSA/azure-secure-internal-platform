resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  location            = var.location
  name                = "law-secure-internal-platform"
  resource_group_name = azurerm_resource_group.resource_group.name
  tags = {
    environment = "lab"
    project     = "secure-internal-platform"
  }
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting_storage_account" {
  name                       = "ds-secure-internal-platform"
  target_resource_id         = "${azurerm_storage_account.storage_account.id}/blobServices/default/"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id

  enabled_log {
    category = "StorageWrite"
  }

}

resource "azurerm_monitor_diagnostic_setting" "bastion_diagnostic_setting" {
  name                       = "ds-secure-internal-platform"
  target_resource_id         = azurerm_bastion_host.bastion_host.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id

  enabled_log {
    category = "BastionAuditLogs"
  }
}
