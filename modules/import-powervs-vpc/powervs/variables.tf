variable "pi_workspace_guid" {
  description = "An existing PowerVS infrastructure workspace GUID."
  type        = string
}

variable "pi_management_network_name" {
  description = "The name of existing management network in PowerVS infrastructure."
  type        = string
}

variable "pi_backup_network_name" {
  description = "The name of existing backup network in PowerVS infrastructure."
  type        = string
}
