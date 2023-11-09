module "power_workspace_data_retrieval" {
  source                          = "./module/powervs"
  ibmcloud_api_key                = var.ibmcloud_api_key
  powervs_region                  = lookup(local.ibm_powervs_zone_region_map, var.powervs_zone, null)
  powervs_zone                    = var.powervs_zone
  powervs_workspace_name          = var.powervs_workspace_name
  powervs_management_network_name = var.powervs_management_network_name
  powervs_backup_network_name     = var.powervs_backup_network_name
}
