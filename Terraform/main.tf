resource "azurerm_resource_group" "resource_group" {
  location = var.location
  name     = "rg-secure-internal-platform"
  tags = {
    environment = "lab"
    project     = "secure-internal-platform"
  }
}
