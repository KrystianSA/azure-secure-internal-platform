resource "azurerm_resource_group_policy_assignment" "not_allowed_public_ip" {
  name                 = "not_allowed_public_ip"
  resource_group_id    = module.rg_secure_internal_platform.resource_group_id
  policy_definition_id = data.azurerm_policy_definition_built_in.not_allowed_resource_types.id
  description          = "This policy denies the creation of public IP addresses in the resource group."

  parameters = <<PARAMS
{
  "listOfResourceTypesNotAllowed": {
    "value": [
      "Microsoft.Network/publicIPAddresses"
    ]
  }
}
PARAMS

  non_compliance_message {
    content = "Creation of public IP addresses is not allowed in this resource group."
  }
}

locals {
  policy_data = jsondecode(file("${path.module}/policies-definitions/deny_open_ports_policy.json"))
}

resource "azurerm_policy_definition" "deny_open_ports_policy" {
  name         = "deny-open-ports-policy"
  policy_type  = "Custom"
  mode         = local.policy_data.mode
  display_name = local.policy_data.displayName
  description  = local.policy_data.description
  policy_rule  = jsonencode(local.policy_data.policyRule)
  parameters   = jsonencode(local.policy_data.parameters)

}

resource "azurerm_resource_group_policy_assignment" "not_allowed_inbound_traffic_from_internet_on_nsg" {
  name                 = "not_allowed_inbound_traffic_from_internet_on_nsg"
  resource_group_id    = module.rg_secure_internal_platform.resource_group_id
  policy_definition_id = azurerm_policy_definition.deny_open_ports_policy.id
}

data "azurerm_bastion_host" "bastion_rg_secure_internal_platform_id" {
  name                = azurerm_bastion_host.bastion_host.name
  resource_group_name = module.rg_secure_internal_platform.resource_group_name
}

resource "azurerm_resource_policy_exemption" "bastion_not_allowed_public_ip_policy_exemption" {
  name                 = "bastion_not_allowed_public_ip_policy_exemption"
  resource_id          = data.azurerm_bastion_host.bastion_rg_secure_internal_platform_id.id
  policy_assignment_id = azurerm_resource_group_policy_assignment.not_allowed_public_ip.id
  exemption_category   = "Waiver"
}
