variable "subscription_id" {
  description = "The subscription ID to deploy resources into."
  type        = string
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "The Azure region to deploy resources into."
  type        = string
  default     = "polandcentral"
}

variable "krystian_object_id" {
  description = "The object ID of the user to assign the role to."
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "The tenant ID for the Azure Active Directory."
  type        = string
}