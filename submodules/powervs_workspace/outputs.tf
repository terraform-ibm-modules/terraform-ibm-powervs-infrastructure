output "powervs_workspace_id" {
  description = "PowerVS infrastructure workspace id. The unique identifier of the new resource instance."
  value       = ibm_resource_instance.powervs_workspace.id
}

output "powervs_workspace_guid" {
  description = "PowerVS infrastructure workspace guid. The GUID of the resource instance."
  value       = ibm_resource_instance.powervs_workspace.guid
}

output "powervs_workspace_management_subnet_id" {
  description = "PowerVS infrastructure workspace management subnet id. The unique identifier of the network."
  value       = ibm_pi_network.management_network.network_id
}

output "powervs_workspace_backup_subnet_id" {
  description = "PowerVS infrastructure workspace backup subnet id. The unique identifier of the network."
  value       = ibm_pi_network.backup_network.network_id
}
