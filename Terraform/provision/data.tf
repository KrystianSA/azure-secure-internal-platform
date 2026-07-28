data "azurerm_client_config" "current" {}

data "azuread_user" "Krystian" {
  object_id = var.krystian_object_id
}

data "azurerm_policy_definition_built_in" "not_allowed_resource_types" {
  display_name = "Not allowed resource types"
}

data "azurerm_network_security_group" "nsg_id" {
  name                = azurerm_network_security_group.vm_nsg.name
  resource_group_name = module.rg_secure_internal_platform.resource_group_name
}
