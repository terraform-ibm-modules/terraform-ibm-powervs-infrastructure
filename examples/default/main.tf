#####################################################
# PVS Configuration
# Copyright 2022 IBM
#####################################################

provider "ibm" {
  region           = lookup(local.ibm_pvs_zone_region_map, var.pvs_zone, null)
  zone             = var.pvs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

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

  ### Check if both groups were given
  exist_both_resource_group_cdn = !(var.resource_group != null && var.existing_resource_group != null)
  exist_both_resource_group_msg = "only 'resource_group_name' or 'existing_resource_group_name' can be given, but both have been given"
  # tflint-ignore: terraform_unused_declarations
  exist_both_resource_group_check = regex("^${local.exist_both_resource_group_msg}$", (local.exist_both_resource_group_cdn ? local.exist_both_resource_group_msg : ""))

  resource_group = var.existing_resource_group != null ? data.ibm_resource_group.existing_resource_group[0].name : ibm_resource_group.resource_group[0].name
}

data "ibm_resource_group" "existing_resource_group" {
  count = var.existing_resource_group != null ? 1 : 0
  name  = var.existing_resource_group
}

resource "ibm_resource_group" "resource_group" {
  count    = var.existing_resource_group != null ? 0 : 1
  name     = var.resource_group
  quota_id = null
}

resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "ssh_key" {
  name       = var.prefix
  public_key = tls_private_key.tls_key.public_key_pem
}

module "pvs" {
  source = "../../"

  pvs_zone                 = var.pvs_zone
  pvs_resource_group_name  = local.resource_group
  pvs_service_name         = "${var.prefix}-${var.pvs_service_name}"
  tags                     = var.resource_tags
  pvs_sshkey_name          = "${var.prefix}-${var.pvs_sshkey_name}"
  ssh_public_key           = ibm_is_ssh_key.ssh_key.public_key
  pvs_management_network   = var.pvs_management_network
  pvs_backup_network       = var.pvs_backup_network
  transit_gw_name          = var.transit_gw_name
  cloud_connection_count   = var.cloud_connection_count
  cloud_connection_speed   = var.cloud_connection_speed
  cloud_connection_gr      = var.cloud_connection_gr
  cloud_connection_metered = var.cloud_connection_metered
  ibmcloud_api_key         = var.ibmcloud_api_key
}
