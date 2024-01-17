output "powervs_workspace_name" {
  description = "The name of the PowerVS workspace."
  value       = data.ibm_pi_workspace.powervs_workspace.pi_workspace_name
}

output "powervs_workspace_guid" {
  description = "The GUID of PowerVS workspace."
  value       = data.ibm_resource_instance.powervs_workspace_ds.guid
}

output "powervs_workspace_crn" {
  description = "PowerVS infrastructure workspace CRN."
  value       = data.ibm_resource_instance.powervs_workspace_ds.crn
}

output "powervs_resource_group_name" {
  description = "IBM Cloud resource group in which PowerVS infrastructure exists."
  value       = data.ibm_resource_instance.powervs_workspace_ds.resource_group_name
}

output "powervs_images" {
  description = "Object containing imported PowerVS image names and image ids."
  value = {
    for image in data.ibm_pi_images.powervs_workspace_images_ds.image_info : image.name => image.id
  }
}

output "cloud_connections_count" {
  description = "The data of the cloud connections which attcahed to the Power Virtual Server Workspace."
  value       = length(data.ibm_pi_cloud_connections.cloud_connections.connections)
}

output "powervs_management_network_subnet" {
  description = "Subnet details of management network in existing PowerVS infrastructure."
  value = tomap({
    "cidr" = data.ibm_pi_network.powervs_management_network_ds.cidr
    "id"   = data.ibm_pi_network.powervs_management_network_ds.id
    "name" = var.pi_management_network_name
  })
}

output "powervs_backup_network_subnet" {
  description = "Subnet details of backup network in existing PowerVS infrastructure."
  value = tomap({
    "cidr" = data.ibm_pi_network.powervs_backup_network_ds.cidr
    "id"   = data.ibm_pi_network.powervs_backup_network_ds.id
    "name" = var.pi_backup_network_name
  })
}
