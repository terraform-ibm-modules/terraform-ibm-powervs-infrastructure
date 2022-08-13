#####################################################
# PowerVS Infrastructure configuration Configuration
# Copyright 2022 IBM
#####################################################

locals {
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
  region    =   lookup(local.ibm_pvs_zone_region_map,var.pvs_zone, null)
  zone      =   var.pvs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

data "ibm_schematics_workspace" "schematics_workspace" {
  slz_workspace_id = var.slz_workspace_id
}

data "ibm_schematics_output" "schematics_output" {
  slz_workspace_id = var.slz_workspace_id
  template_id  = data.ibm_schematics_workspace.schematics_workspace.runtime_data[0].id
}

module "powervs_infra" {
  source = "../.."
  
  pvs_zone                    = var.pvs_zone
  pvs_resource_group_name     = var.pvs_resource_group_name
  pvs_service_name            = "${data.ibm_schematics_output.schematics_output.output_values.prefix}-power-service"
  tags                        = var.tags
  pvs_sshkey_name             = "${data.ibm_schematics_output.schematics_output.output_values.prefix}-ssh-pvs-key" 
  ssh_public_key              = data.ibm_schematics_output.schematics_output.output_values.ssh_public_key
  pvs_management_network      = var.pvs_management_network
  pvs_backup_network          = var.pvs_backup_network
  transit_gateway_name        = data.ibm_schematics_output.schematics_output.output_values.transit_gateway_name
  reuse_cloud_connections     = var.reuse_cloud_connections
  cloud_connection_count      = var.cloud_connection_count
  cloud_connection_speed      = var.cloud_connection_speed
  cloud_connection_gr         = var.cloud_connection_gr
  cloud_connection_metered    = var.cloud_connection_metered
}