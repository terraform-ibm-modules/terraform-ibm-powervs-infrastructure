variable "powervs_zone" {
  description = "IBM Cloud PowerVS Zone."
  type        = string
}

variable "powervs_resource_group_name" {
  description = "Existing Resource Group Name."
  type        = string
}

variable "powervs_workspace_name" {
  description = "Name of IBM Cloud PowerVS workspace which will be created."
  type        = string
}

variable "powervs_sshkey_name" {
  description = "Name of IBM Cloud PowerVS SSH Key which will be created."
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH Key for PowerVM creation."
  type        = string
}

variable "powervs_management_network" {
  description = "IBM Cloud PowerVS Management Subnet name and cidr which will be created."
  type = object({
    name = string
    cidr = string
  })
}

variable "powervs_backup_network" {
  description = "IBM Cloud PowerVS Backup Network name and cidr which will be created."
  type = object({
    name = string
    cidr = string
  })
}

#####################################################
# Optional Parameters
#####################################################

variable "tags" {
  description = "List of Tag names for IBM Cloud PowerVS workspace."
  type        = list(string)
}

variable "powervs_image_names" {
  description = "List of Images to be imported into cloud account from catalog images."
  type        = list(string)
}
