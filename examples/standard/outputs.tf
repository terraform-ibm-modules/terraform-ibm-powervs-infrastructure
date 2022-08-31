output "entered_data_non_sensitive" {
  description = "User input (non sensitive)"
  value = {
    pvs_zone                 = var.pvs_zone
    pvs_resource_group_name  = var.pvs_resource_group_name
    prefix                   = var.prefix
    pvs_service_name         = "${var.prefix}-power-service"
    tags                     = var.tags
    pvs_image_names          = var.pvs_image_names
    pvs_sshkey_name          = "${var.prefix}-ssh-pvs-key"
    ssh_public_key           = var.ssh_public_key
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
    dns_forwarder_config     = local.dns_config
    ntp_forwarder_config     = local.ntp_config
    nfs_config               = local.nfs_config
  }
}
