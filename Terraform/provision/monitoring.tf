resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  location            = var.location
  name                = "law-secure-internal-platform"
  resource_group_name = module.rg_secure_internal_platform.resource_group_name
  tags = {
    environment = "lab"
    project     = "secure-internal-platform"
  }
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting_storage_account" {
  name                       = "ds-secure-internal-platform"
  target_resource_id         = "${azurerm_storage_account.storage_account_private_files.id}/blobServices/default/"
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

resource "azurerm_monitor_diagnostic_setting" "nsg_diagnostic_setting" {
  name                       = "ds-secure-internal-platform"
  target_resource_id         = azurerm_network_security_group.vm_nsg.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id

  enabled_log {
    category_group = "AllLogs"
  }
}

resource "azurerm_network_watcher" "network_watcher" {
  location            = var.location
  name                = "NetworkWatcher_polandcentral"
  resource_group_name = azurerm_resource_group.network_watcher_rg.name
}

resource "azurerm_network_watcher_flow_log" "virtual_network_flow_logs" {
  network_watcher_name = azurerm_network_watcher.network_watcher.name
  resource_group_name  = azurerm_resource_group.network_watcher_rg.name
  name                 = "virtual_network_secure_internal_platform_flow_logs"

  target_resource_id = azurerm_virtual_network.virtual_network.id
  storage_account_id = azurerm_storage_account.storage_account_flow_logs.id
  enabled            = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.log_analytics_workspace.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.log_analytics_workspace.location
    workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
    interval_in_minutes   = 10
  }
}

resource "azurerm_monitor_data_collection_rule" "vm-workstation1_rule1" {
  name                = "dcr-vm-workstation1-secure-internal-platform"
  resource_group_name = module.rg_secure_internal_platform.resource_group_name
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
      name                  = "log-analytics-vm-workstation1"
    }
  }

  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = ["log-analytics-vm-workstation1"]
  }

  data_sources {
    windows_event_log {
      streams = ["Microsoft-Event"]
      x_path_queries = ["Application!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0 or Level=5)]]",
        "Security!*[System[(band(Keywords,13510798882111488))]]",
      "System!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0 or Level=5)]]"]
      name = "eventLogsDataSource"
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "vm-workstation1_dcra1" {
  name                    = "dcra-vm-workstation1-secure-internal-platform"
  target_resource_id      = azurerm_windows_virtual_machine.windows_vm_workstation.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.vm-workstation1_rule1.id
}