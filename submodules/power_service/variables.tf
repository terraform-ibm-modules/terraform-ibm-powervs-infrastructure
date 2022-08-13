variable "pvs_zone" {
  description = "IBM Cloud PowerVS Zone."
  type        = string
}

variable "pvs_resource_group_name" {
  description = "Existing Resource Group Name"
  type        = string
}

variable "pvs_service_name" {
  description = "Name of IBM Cloud PowerVS service which will be created"
  type        = string
}

variable "pvs_sshkey_name" {
  description = "Name of IBM Cloud PowerVS SSH Key which will be created"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH Key for PowerVM creation"
  type        = string
}

variable "pvs_management_network" {
  description = "IBM Cloud PowerVS Management Subnet name and cidr which will be created."
  type        = map(any)
}

variable "pvs_backup_network" {
  description = "IBM Cloud PowerVS Backup Network name and cidr which will be created."
  type        = map(any)
}

#####################################################
# Optional Parameters
#####################################################

variable "tags" {
  description = "List of Tag names for IBM Cloud PowerVS service"
  type        = list(string)
  default     = null
}
