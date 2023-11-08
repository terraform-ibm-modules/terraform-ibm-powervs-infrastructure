provider "ibm" {
  region           = var.powervs_region
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

data "ibm_resource_instance" "power_workspace" {
  name = var.powervs_workspace_name
}

data "ibm_pi_catalog_images" "catalog_images_ds" {
  sap                  = true
  pi_cloud_instance_id = data.ibm_resource_instance.power_workspace.guid
}

locals {
  catalog_images     = { for stock_image in data.ibm_pi_catalog_images.catalog_images_ds.images : stock_image.name => stock_image.image_id }
  pvs_default_images = ["IBMi-75-01-2924-2", "IBMi-75-01-2984-2", "7300-01-01", "7300-00-01", "SLES15-SP4-SAP", "SLES15-SP4-SAP-NETWEAVER", "RHEL8-SP6-SAP", "RHEL8-SP6-SAP-NETWEAVER"]
  powervs_image_map = {
    for image_name in local.pvs_default_images : image_name => lookup(local.catalog_images, image_name)
  }
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
