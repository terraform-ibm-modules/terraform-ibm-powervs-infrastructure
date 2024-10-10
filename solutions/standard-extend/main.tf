module "powervs_workspace" {
  # source    = "terraform-ibm-modules/powervs-workspace/ibm"
  # version   = "2.0.0"
  source = "github.com/terraform-ibm-modules/terraform-ibm-powervs-workspace.git?ref=byoi"

  pi_zone                                 = var.powervs_zone
  pi_resource_group_name                  = var.powervs_resource_group_name
  pi_workspace_name                       = local.powervs_workspace_name
  pi_ssh_public_key                       = local.powervs_ssh_public_key
  pi_private_subnet_1                     = var.powervs_management_network
  pi_private_subnet_2                     = var.powervs_backup_network
  pi_transit_gateway_connection           = { "enable" : true, "transit_gateway_id" : local.transit_gateway_id }
  pi_tags                                 = var.tags
  pi_image_names                          = var.powervs_image_names
  custom_pi_images                        = var.custom_pi_images
  custom_pi_image_cos_configuration       = var.custom_pi_image_cos_configuration
  custom_pi_image_cos_service_credentials = var.custom_pi_image_cos_service_credentials
}
