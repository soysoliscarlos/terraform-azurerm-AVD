variable "resource_group_location" {
  default     = "eastus2"
  description = "Location of the resource group."
}

variable "rg_name" {
  type        = string
  default     = "RG-AVD"
  description = "Name of the Resource group in which to deploy service objects"
}

variable "workspace" {
  type        = string
  description = "Name of the Azure Virtual Desktop workspace"
  default     = "AVD-Workspace"
}

variable "hostpool" {
  type        = string
  description = "Name of the Azure Virtual Desktop host pool"
  default     = "AVD-HP"
}

variable "rfc3339" {
  type        = string
  default     = "" # Ex. "2023-12-13T12:43:13Z
  description = "Registration token expiration # Ex. 2023-01-31T12:00:00Z (No more than a month)"
}

variable "prefix" {
  type        = string
  default     = "avd"
  description = "Prefix of the name of the AVD machine(s)"
}

variable "rdsh_count" {
  description = "Number of AVD machines to deploy"
  default     = 1
}

variable "vm_size" {
  description = "Size of the machine to deploy"
  default     = "Standard_D2s_v3"
}

variable "local_admin_username" {
  type        = string
  default     = "azureadmin"
  description = "local admin username"
}

variable "local_admin_password" {
  type        = string
  default     = "Password135."
  description = "local admin password"
  sensitive   = true
}

variable "vnet_range" {
  type        = list(string)
  default     = ["10.2.0.0/24"]
  description = "Address range for deployment VNet"
}
variable "subnet_range" {
  type        = list(string)
  default     = ["10.2.0.0/24"]
  description = "Address range for session host subnet"
}

variable "avd_users" {
  description = "AVD users, must indicate the UPN"
  default = [
    "",
  ]
}

variable "aad_group_name" {
  type        = string
  default     = "AVDUsers"
  description = "Azure Active Directory Group for AVD users"
}