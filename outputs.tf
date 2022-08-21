output "pvs_management_network_name" {
  description = "Name of the created management network."
  value       = var.pvs_management_network["name"]
}

output "pvs_backup_network_name" {
  description = "Name of the created backup network."
  value       = var.pvs_backup_network["name"]
}

output "pvs_zone" {
  description = "Name of the IBM PowerVS zone where elements were created."
  value       = var.pvs_zone
}

output "pvs_resource_group_name" {
  description = "Name of the IBM PowerVS resource group where elements were created."
  value       = var.pvs_resource_group_name
}

output "pvs_service_name" {
  description = "Name of the service where elements were created."
  value       = var.pvs_service_name
}

output "pvs_ssh_key_name" {
  description = "Name of the created ssh key."
  value       = var.pvs_service_name
}
