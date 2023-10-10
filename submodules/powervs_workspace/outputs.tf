output "powervs_workspace_crn" {
  description = "PowerVS infrastructure workspace CRN. The full deployment CRN as defined in the global catalog. The Cloud Resource Name (CRN) of the deployment location where the instance is provisioned."
  value       = ibm_resource_instance.powervs_workspace.target_crn
}

output "powervs_workspace_resource_id" {
  description = "PowerVS infrastructure workspace resource id. The unique ID of the offering. This value is provided by and stored in the global catalog."
  value       = ibm_resource_instance.powervs_workspace.resource_id
}

output "powervs_workspace_guid" {
  description = "PowerVS infrastructure workspace guid. The GUID of the resource instance."
  value       = ibm_resource_instance.powervs_workspace.guid
}

output "powervs_workspace_id" {
  description = "PowerVS infrastructure workspace id. The unique identifier of the new resource instance."
  value       = ibm_resource_instance.powervs_workspace.id
}

output "powervs_workspace_management_subnet_id" {
  description = "PowerVS infrastructure workspace management subnet id. The unique identifier of the network."
  value       = ibm_pi_network.management_network.network_id
}

output "powervs_workspace_backup_subnet_id" {
  description = "PowerVS infrastructure workspace backup subnet id. The unique identifier of the network."
  value       = ibm_pi_network.backup_network.network_id
}
