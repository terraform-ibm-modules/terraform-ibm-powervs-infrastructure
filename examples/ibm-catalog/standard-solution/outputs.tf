output "powervs_infra" {
  description = "Standard-catalog PowerVS Infrastructure outputs for next solution consumption"
  value = {

    prefix                     = local.slz_output[0].prefix.value
    pvs_zone                   = var.pvs_zone
    pvs_resource_group_name    = var.pvs_resource_group_name
    pvs_service_name           = "${local.slz_output[0].prefix.value}-power-service"
    tags                       = var.tags
    pvs_sshkey_name            = "${local.slz_output[0].prefix.value}-ssh-pvs-key"
    ssh_public_key             = local.slz_output[0].ssh_public_key.value
    infrastructure_networks    = [var.pvs_management_network.name, var.pvs_backup_network.name]
    transit_gateway_name       = local.slz_output[0].transit_gateway_name.value
    reuse_cloud_connections    = var.reuse_cloud_connections
    cloud_connection_count     = var.cloud_connection_count
    cloud_connection_speed     = var.cloud_connection_speed
    cloud_connection_gr        = var.cloud_connection_gr
    cloud_connection_metered   = var.cloud_connection_metered
    access_host_or_ip          = local.slz_output[0].fip_vsi.value[0].floating_ip
    squid_config               = local.squid_config
    dns_forwarder_config       = local.dns_config
    ntp_forwarder_config       = local.ntp_config
    nfs_config                 = local.nfs_config
    perform_proxy_client_setup = local.perform_proxy_client_setup
  }
}
