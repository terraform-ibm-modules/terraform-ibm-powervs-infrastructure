data "ibm_pi_workspace" "powervs_workspace_ds" {
  pi_cloud_instance_id = var.pi_workspace_guid
}

data "ibm_pi_images" "powervs_workspace_images_ds" {
  pi_cloud_instance_id = var.pi_workspace_guid
}

data "ibm_pi_network" "powervs_management_network_ds" {
  pi_network_name      = var.pi_management_network_name
  pi_cloud_instance_id = var.pi_workspace_guid
}

data "ibm_pi_network" "powervs_backup_network_ds" {
  pi_network_name      = var.pi_backup_network_name
  pi_cloud_instance_id = var.pi_workspace_guid
}
