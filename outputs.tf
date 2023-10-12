output "powervs_workspace_name" {
  description = "PowerVS infrastructure workspace name."
  value       = var.powervs_workspace_name
}

output "powervs_workspace_crn" {
  description = "PowerVS infrastructure workspace CRN."
  value       = module.powervs_workspace.powervs_workspace_crn
}

output "powervs_sshkey_name" {
  description = "SSH public key name in created PowerVS infrastructure."
  value       = var.powervs_sshkey_name
}

output "powervs_zone" {
  description = "Zone where PowerVS infrastructure is created."
  value       = var.powervs_zone
}

output "powervs_resource_group_name" {
  description = "IBM Cloud resource group where PowerVS infrastructure is created."
  value       = var.powervs_resource_group_name
}

output "cloud_connection_count" {
  description = "Number of cloud connections configured in created PowerVS infrastructure."
  value       = local.per_enabled ? 0 : var.cloud_connection_count
}

output "powervs_management_network_name" {
  description = "Name of management network in created PowerVS infrastructure."
  value       = var.powervs_management_network.name
}

output "powervs_backup_network_name" {
  description = "Name of backup network in created PowerVS infrastructure."
  value       = var.powervs_backup_network.name
}
