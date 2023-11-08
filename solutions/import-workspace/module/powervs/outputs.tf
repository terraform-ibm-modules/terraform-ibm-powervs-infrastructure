output "powervs_workspace_guid" {
  description = "The GUID of PowerVS workspace"
  value       = data.ibm_resource_instance.power_workspace.guid
}

output "powervs_workspace_crn" {
  description = "PowerVS infrastructure workspace CRN."
  value       = data.ibm_resource_instance.power_workspace.crn
}

output "powervs_resource_group_name" {
  description = "IBM Cloud resource group where PowerVS infrastructure is created."
  value       = data.ibm_resource_instance.power_workspace.resource_group_name
}

output "powervs_images" {
  description = "Object containing imported PowerVS image names and image ids."
  value       = local.powervs_image_map
}

/*output "powervs_management_network_name" {
  description = "Name of management network in created PowerVS infrastructure."
  value       = var.powervs_management_network_name
}

output "powervs_backup_network_name" {
  description = "Name of backup network in created PowerVS infrastructure."
  value       = var.powervs_backup_network_name
} */

output "powervs_management_network_subnet" {
  description = "Subnet CIDR  of management network in created PowerVS infrastructure."
  value = tomap({
    "cidr" = data.ibm_pi_network.pvs_management_network.cidr
    "id"   = data.ibm_pi_network.pvs_management_network.id
    "name" = var.powervs_management_network_name
  })
}

output "powervs_backup_network_subnet" {
  description = "Subnet CIDR of backup network in created PowerVS infrastructure."
  value = tomap({
    "cidr" = data.ibm_pi_network.pvs_backup_network.cidr
    "id"   = data.ibm_pi_network.pvs_backup_network.id
    "name" = var.powervs_backup_network_name
  })
}
