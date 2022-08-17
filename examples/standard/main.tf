#####################################################
# PVS Configuration
# Copyright 2022 IBM
#####################################################

provider "ibm" {
  region           = lookup(var.ibm_pvs_zone_region_map, var.pvs_zone, null)
  zone             = var.pvs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

locals {
  squid_config = merge({
    "squid_enable"      = var.configure_proxy
    "server_host_or_ip" = var.internet_services_host_or_ip
  }, var.squid_proxy_config)
  dns_forwarder_config = merge({
    "dns_enable"        = var.configure_dns_forwarder
    "server_host_or_ip" = var.private_services_host_or_ip
  }, var.dns_forwarder_config)
  ntp_forwarder_config = merge({
    "ntp_enable"        = var.configure_ntp_forwarder
    "server_host_or_ip" = var.private_services_host_or_ip
  }, var.ntp_forwarder_config)
  nfs_config = merge({
    "nfs_enable"        = var.configure_nfs_server
    "server_host_or_ip" = var.private_services_host_or_ip
  }, var.nfs_server_config)
}

module "powervs_infra" {
  source = "../../"

  pvs_zone                 = var.pvs_zone
  pvs_resource_group_name  = var.pvs_resource_group_name
  pvs_service_name         = "${var.prefix}-pvs"
  tags                     = var.tags
  pvs_sshkey_name          = "${var.prefix}-ssh-pvs-key"
  ssh_public_key           = var.ssh_public_key
  ssh_private_key          = var.ssh_private_key
  pvs_management_network   = var.pvs_management_network
  pvs_backup_network       = var.pvs_backup_network
  transit_gateway_name     = var.transit_gateway_name
  reuse_cloud_connections  = var.reuse_cloud_connections
  cloud_connection_count   = var.cloud_connection_count
  cloud_connection_speed   = var.cloud_connection_speed
  cloud_connection_gr      = var.cloud_connection_gr
  cloud_connection_metered = var.cloud_connection_metered
  access_host_or_ip        = var.access_host_or_ip
  squid_config             = local.squid_config
  dns_forwarder_config     = local.dns_forwarder_config
  ntp_forwarder_config     = local.ntp_forwarder_config
  nfs_config               = local.nfs_config
}
