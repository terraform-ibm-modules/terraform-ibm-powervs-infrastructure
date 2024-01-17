output "powervs_workspace_name" {
  description = "The name of the PowerVS workspace."
  value       = data.ibm_pi_workspace.powervs_workspace_ds.pi_workspace_name
}

output "powervs_workspace_id" {
  description = "PowerVS infrastructure workspace ID."
  value       = data.ibm_pi_workspace.powervs_workspace_ds.id
}

output "powervs_workspace_crn" {
  description = "PowerVS infrastructure workspace CRN."
  value       = data.ibm_pi_workspace.powervs_workspace_ds.pi_workspace_details.crn
}


output "powervs_images" {
  description = "Object containing imported PowerVS image names and image ids."
  value = {
    for image in data.ibm_pi_images.powervs_workspace_images_ds.image_info : image.name => image.id
  }
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
