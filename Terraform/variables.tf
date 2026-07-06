variable "subscription_id" {
  description = "The subscription ID to deploy resources into."
  type        = string
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}
