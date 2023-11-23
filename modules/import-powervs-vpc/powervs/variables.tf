variable "pi_workspace_name" {
  description = "PowerVS infrastructure workspace name."
  type        = string
}

variable "pi_management_network_name" {
  description = "Name of management network in created PowerVS infrastructure."
  type        = string
}

variable "pi_backup_network_name" {
  description = "Name of backup network in created PowerVS infrastructure."
  type        = string
}
