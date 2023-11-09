provider "ibm" {
  region           = var.powervs_region
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

data "ibm_resource_instance" "power_workspace" {
  name = var.powervs_workspace_name
}

data "ibm_pi_images" "powervs_workspace_images_ds" {
  pi_cloud_instance_id = data.ibm_resource_instance.power_workspace.guid
}

locals {
  pi_cloud_instance_id = data.ibm_resource_instance.power_workspace.guid
}

data "ibm_pi_network" "pvs_management_network" {
  pi_network_name      = var.powervs_management_network_name
  pi_cloud_instance_id = local.pi_cloud_instance_id
}

data "ibm_pi_network" "pvs_backup_network" {
  pi_network_name      = var.powervs_backup_network_name
  pi_cloud_instance_id = local.pi_cloud_instance_id
}
