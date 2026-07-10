data "azurerm_client_config" "current" {}

data "azuread_user" "Krystian" {
  object_id = var.krystian_object_id
}
