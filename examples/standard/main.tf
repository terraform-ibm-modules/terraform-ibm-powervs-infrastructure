#####################################################
# PVS Configuration
# Copyright 2022 IBM
#####################################################

provider "ibm" {
  region           = lookup(var.ibm_pvs_zone_region_map, var.pvs_zone, null)
  zone             = var.pvs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

module "pvs" {
  source = "../../"

  pvs_zone                 = var.pvs_zone
  pvs_resource_group_name  = var.pvs_resource_group_name
  pvs_service_name         = "${var.prefix}-pvs"
  tags                     = var.tags
  pvs_sshkey_name          = "${var.prefix}-key"
  ssh_public_key           = var.ssh_public_key
  pvs_management_network   = var.pvs_management_network
  pvs_backup_network       = var.pvs_backup_network
  transit_gateway_name     = var.transit_gateway_name
  reuse_cloud_connections  = var.reuse_cloud_connections
  cloud_connection_count   = var.cloud_connection_count
  cloud_connection_speed   = var.cloud_connection_speed
  cloud_connection_gr      = var.cloud_connection_gr
  cloud_connection_metered = var.cloud_connection_metered

  #ssh_private_key              = var.ssh_private_key
  #configure_proxy              = var.configure_proxy
  #configure_ntp_forwarder      = var.configure_ntp_forwarder
  #configure_nfs_server         = var.configure_nfs_server
  #configure_dns_forwarder      = var.configure_dns_forwarder
  #access_host_or_ip            = var.access_host_or_ip
  #internet_services_host_or_ip = var.internet_services_host_or_ip
  #private_services_host_or_ip  = var.private_services_host_or_ip
  #squid_proxy_config           = var.squid_proxy_config
  #dns_forwarder_config         = var.dns_forwarder_config
  #ntp_forwarder_config         = var.ntp_forwarder_config
  #nfs_server_config            = var.nfs_server_config
  #awscli_config                = var.awscli_config
}
