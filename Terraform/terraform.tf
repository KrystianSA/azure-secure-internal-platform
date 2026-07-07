terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "satfrestate"
    container_name       = "tfstate-secure-internal-platform"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.58.0"

    }
  }
}
