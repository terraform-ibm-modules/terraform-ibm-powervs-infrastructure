###########################################################
# PowerVS Workspace module
###########################################################

locals {
  powervs_custom_image1 = (
    var.powervs_custom_images.powervs_custom_image1.image_name == "" &&
    var.powervs_custom_images.powervs_custom_image1.file_name == "" &&
    var.powervs_custom_images.powervs_custom_image1.storage_tier == ""
  ) ? null : var.powervs_custom_images.powervs_custom_image1
  powervs_custom_image2 = (
    var.powervs_custom_images.powervs_custom_image2.image_name == "" &&
    var.powervs_custom_images.powervs_custom_image2.file_name == "" &&
    var.powervs_custom_images.powervs_custom_image2.storage_tier == ""
  ) ? null : var.powervs_custom_images.powervs_custom_image2
  powervs_custom_image3 = (
    var.powervs_custom_images.powervs_custom_image3.image_name == "" &&
    var.powervs_custom_images.powervs_custom_image3.file_name == "" &&
    var.powervs_custom_images.powervs_custom_image3.storage_tier == ""
  ) ? null : var.powervs_custom_images.powervs_custom_image3
  powervs_custom_image_cos_configuration = (
    var.powervs_custom_image_cos_configuration.bucket_name == "" &&
    var.powervs_custom_image_cos_configuration.bucket_access == "" &&
    var.powervs_custom_image_cos_configuration.bucket_region == ""
  ) ? null : var.powervs_custom_image_cos_configuration
}

module "powervs_workspace" {
  source  = "terraform-ibm-modules/powervs-workspace/ibm"
  version = "3.2.1"

  providers = { ibm = ibm.ibm-pi }

  pi_zone                                 = var.powervs_zone
  pi_resource_group_name                  = var.powervs_resource_group_name
  pi_workspace_name                       = "${var.prefix}-${var.powervs_zone}-power-workspace"
  pi_ssh_public_key                       = { "name" = "${var.prefix}-${var.powervs_zone}-pvs-ssh-key", value = var.ssh_public_key }
  pi_private_subnet_1                     = var.powervs_management_network
  pi_private_subnet_2                     = var.powervs_backup_network
  pi_transit_gateway_connection           = { "enable" : true, "transit_gateway_id" : module.landing_zone.transit_gateway_data.id }
  pi_tags                                 = var.tags
  pi_custom_image1                        = local.powervs_custom_image1
  pi_custom_image2                        = local.powervs_custom_image2
  pi_custom_image3                        = local.powervs_custom_image3
  pi_custom_image_cos_configuration       = local.powervs_custom_image_cos_configuration
  pi_custom_image_cos_service_credentials = var.powervs_custom_image_cos_service_credentials
}
