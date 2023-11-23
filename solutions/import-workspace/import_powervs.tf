provider "ibm" {
  alias            = "ibm-pi"
  region           = lookup(local.ibm_powervs_zone_region_map, var.powervs_zone, null)
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

module "power_workspace_data_retrieval" {
  source    = "../../modules/import-powervs-vpc/powervs"
  providers = { ibm = ibm.ibm-pi }

  pi_workspace_name          = var.powervs_workspace_name
  pi_management_network_name = var.powervs_management_network_name
  pi_backup_network_name     = var.powervs_backup_network_name
}
