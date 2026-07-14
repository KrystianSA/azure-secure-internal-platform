resource "azurerm_storage_account" "storage_account_private_files" {
  name                            = "sasecinternalplatform"
  resource_group_name             = module.rg_secure_internal_platform.resource_group_name
  location                        = var.location
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

resource "azurerm_storage_account" "storage_account_flow_logs" {
  name                       = "saflowlogs"
  resource_group_name        = module.rg_secure_internal_platform.resource_group_name
  location                   = var.location
  account_tier               = "Standard"
  account_kind               = "StorageV2"
  account_replication_type   = "LRS"
  https_traffic_only_enabled = true
}
