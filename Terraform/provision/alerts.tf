module "naming-convention-alerts" {
  source         = "../naming-convention/alerts"
  resource-type  = "vm"
  alerts_trigger = "high_cpu"
}

resource "azurerm_monitor_action_group" "noc_email" {
  name                = "ag-noc-email"
  resource_group_name = module.rg_secure_internal_platform.resource_group_name
  short_name          = "noc-email"

  email_receiver {
    name          = "NOC Engineer"
    email_address = var.alert_email
  }
}

resource "azurerm_monitor_metric_alert" "vm_high_cpu" {
  name                = module.naming-convention-alerts.alert_name
  resource_group_name = module.rg_secure_internal_platform.resource_group_name
  scopes              = [azurerm_windows_virtual_machine.windows_vm_workstation.id]
  description         = "Alert for high CPU usage on VM"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  frequency   = "PT5M"
  window_size = "PT5M"
  severity    = 2

  action {
    action_group_id = azurerm_monitor_action_group.noc_email.id
  }
}
