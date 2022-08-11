
locals {
  workspace_values = var.workspace_id != null && var.workspace_id != "" ? data.ibm_schematics_workspace.schematics_workspace[0].template_inputs : null
  ibm_pvs_zone_region_map = {
    "syd04"    = "syd"
    "syd05"    = "syd"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "lon04"    = "lon"
    "lon06"    = "lon"
    "tok04"    = "tok"
    "us-east"  = "us-east"
    "us-south" = "us-south"
    "dal12"    = "us-south"
    "tor01"    = "tor"
    "osa21"    = "osa"
    "sao01"    = "sao"
  }

}

provider "ibm" {
  alias            = "ibm-pvs"
  region           = lookup(local.ibm_pvs_zone_region_map, var.pvs_zone, null)
  zone             = var.pvs_zone
  ibmcloud_api_key = var.ibmcloud_api_key
}


data "ibm_schematics_workspace" "schematics_workspace" {
  count        = var.workspace_id != null && var.workspace_id != "" ? 1 : 0
  workspace_id = var.workspace_id
}

module "pvs" {
  source = "../../"

  pvs_zone                 = var.pvs_zone
  pvs_resource_group_name  = var.pvs_resource_group_name
  pvs_service_name         = var.workspace_id != null && var.workspace_id != "" ? "${local.workspace_values[index(local.workspace_values.*.name, "prefix")].value}-${var.pvs_service_name}" : "${var.prefix}-${var.pvs_service_name}"
  tags                     = var.tags
  pvs_sshkey_name          = var.workspace_id != null && var.workspace_id != "" ? "${local.workspace_values[index(local.workspace_values.*.name, "prefix")].value}-${var.pvs_sshkey_name}" : "${var.prefix}-${var.pvs_sshkey_name}"
  ssh_public_key           = var.workspace_id != null && var.workspace_id != "" ? local.workspace_values[index(local.workspace_values.*.name, "ssh_public_key")].value : var.ssh_public_key
  pvs_management_network   = var.pvs_management_network
  pvs_backup_network       = var.pvs_backup_network
  transit_gw_name          = var.transit_gw_name
  cloud_connection_count   = var.cloud_connection_count
  cloud_connection_speed   = var.cloud_connection_speed
  cloud_connection_gr      = var.cloud_connection_gr
  cloud_connection_metered = var.cloud_connection_metered
}
