module "naming-convention" {
  source              = "../../naming-convention/resource-groups"
  resource_group_name = var.resource_group_name
}

resource "azurerm_resource_group" "resource_group" {
  name     = module.naming-convention.resources.resource_group_name
  location = var.location
  tags = {
    environment = var.environment
    project     = var.project
  }
}
