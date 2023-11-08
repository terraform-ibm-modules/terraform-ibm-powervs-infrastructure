variable "ibmcloud_api_key" {
  description = "api-key"
  type        = string
  sensitive   = true
}

variable "powervs_region" {
  description = "IBM Cloud region location where IBM PowerVS infrastructure will be created."
  type        = string
}

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created."
  type        = string
}

variable "powervs_workspace_name" {
  description = "PowerVS infrastructure workspace name."
  type        = string
}

/*variable "powervs_sshkey_name" {
  description = "SSH public key name in created PowerVS infrastructure."
  type        = string
}*/

variable "powervs_management_network_name" {
  description = "Name of management network in created PowerVS infrastructure."
  type        = string
}

variable "powervs_backup_network_name" {
  description = "Name of backup network in created PowerVS infrastructure."
  type        = string
}
