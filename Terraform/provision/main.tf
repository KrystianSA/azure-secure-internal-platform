module "rg-secure-internal-platform" {
  source              = "../modules/resource-group"
  resource_group_name = "secure-internal-platform"
  location            = var.location
}

module "rg-network-watcher" {
  source              = "../modules/resource-group"
  resource_group_name = "NetworkWatcherRG"
  location            = var.location
}
