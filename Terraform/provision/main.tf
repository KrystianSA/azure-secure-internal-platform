module "rg_secure_internal_platform" {
  source              = "../modules/resource-group"
  resource_group_name = "secure-internal-platform"
  location            = var.location
  environment         = var.environment
  project             = var.project
}

resource "azurerm_resource_group" "network_watcher_rg" {
  name     = "NetworkWatcherRG"
  location = var.location
  tags = {
    environment = var.environment
    project     = var.project
  }
}
