provider "azurerm" {
  features {}
  use_oidc                        = false
  resource_provider_registrations = "none"
  subscription_id                 = var.subscription_id
  environment                     = "public"
  use_msi                         = false
  use_cli                         = true
  storage_use_azuread             = true
}
