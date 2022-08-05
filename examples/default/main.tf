#####################################################
# PVS Configuration
# Copyright 2022 IBM
#####################################################

provider "ibm" {
  region           = lookup(var.ibm_pvs_zone_region_map, var.pvs_zone, null)
  zone             = var.pvs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

data "ibm_schematics_workspace" "schematics_workspace" {
  count        = var.workspace_id != null && var.workspace_id != "" ? 1 : 0
  workspace_id = var.workspace_id
}

locals {
  workspace_values = var.workspace_id != null && var.workspace_id != "" ? data.ibm_schematics_workspace.schematics_workspace.0.template_inputs : null
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
  ibmcloud_api_key         = var.ibmcloud_api_key
}
