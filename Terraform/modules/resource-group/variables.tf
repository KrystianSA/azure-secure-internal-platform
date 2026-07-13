variable "location" {
  description = "The Azure region to deploy resources into."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to create."
  type        = string
}

variable "environment" {
  type        = string
  description = "The environment for the resources"
}

variable "project" {
  type        = string
  description = "The project name for the resources"
}
