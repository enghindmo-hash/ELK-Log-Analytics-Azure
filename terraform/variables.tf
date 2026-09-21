variable "location" {
  description = "Azure region for the ELK infrastructure"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "vm_name" {
  description = "Name of the Linux VM"
  type        = string
}

variable "admin_username" {
  description = "Administrator username for the Linux VM"
  type        = string
}