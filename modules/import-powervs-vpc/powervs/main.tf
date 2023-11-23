data "ibm_resource_instance" "power_workspace" {
  name = var.pi_workspace_name
}

data "ibm_pi_images" "powervs_workspace_images_ds" {
  pi_cloud_instance_id = data.ibm_resource_instance.power_workspace.guid
}

locals {
  pi_cloud_instance_id = data.ibm_resource_instance.power_workspace.guid
}

data "ibm_pi_network" "pvs_management_network" {
  pi_network_name      = var.pi_management_network_name
  pi_cloud_instance_id = local.pi_cloud_instance_id
}

data "ibm_pi_network" "pvs_backup_network" {
  pi_network_name      = var.pi_backup_network_name
  pi_cloud_instance_id = local.pi_cloud_instance_id
}
