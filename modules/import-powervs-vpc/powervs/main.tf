data "ibm_resource_instance" "powervs_workspace_ds" {
  name = var.pi_workspace_name
}

data "ibm_pi_images" "powervs_workspace_images_ds" {
  pi_cloud_instance_id = data.ibm_resource_instance.powervs_workspace_ds.guid
}

locals {
  pi_cloud_instance_id = data.ibm_resource_instance.powervs_workspace_ds.guid
}

data "ibm_pi_network" "powervs_management_network_ds" {
  pi_network_name      = var.pi_management_network_name
  pi_cloud_instance_id = local.pi_cloud_instance_id
}

data "ibm_pi_network" "powervs_backup_network_ds" {
  pi_network_name      = var.pi_backup_network_name
  pi_cloud_instance_id = local.pi_cloud_instance_id
}
