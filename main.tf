#####################################################
# IBM Cloud PowerVS Configuration
#####################################################

module "initial_validation" {
  source = "./submodules/initial_validation"
  cloud_connection_validate = {
    reuse_cloud_connections = var.reuse_cloud_connections
    transit_gateway_name    = var.transit_gateway_name
  }
}

module "power_service" {
  source = "./submodules/power_service"

  pvs_zone                = var.pvs_zone
  pvs_resource_group_name = var.pvs_resource_group_name
  pvs_service_name        = var.pvs_service_name
  tags                    = var.tags
  pvs_sshkey_name         = var.pvs_sshkey_name
  ssh_public_key          = var.ssh_public_key
  pvs_management_network  = var.pvs_management_network
  pvs_backup_network      = var.pvs_backup_network
}

module "cloud_connection_create" {
  source                   = "./submodules/power_cloudconnection_create"
  depends_on               = [module.power_service]
  count                    = var.reuse_cloud_connections ? 0 : 1
  pvs_zone                 = var.pvs_zone
  pvs_resource_group_name  = var.pvs_resource_group_name
  pvs_service_name         = var.pvs_service_name
  transit_gateway_name     = var.transit_gateway_name
  cloud_connection_count   = var.cloud_connection_count
  cloud_connection_speed   = var.cloud_connection_speed
  cloud_connection_gr      = var.cloud_connection_gr
  cloud_connection_metered = var.cloud_connection_metered

}

module "cloud_connection_attach" {
  source                  = "./submodules/power_cloudconnection_attach"
  depends_on              = [module.power_service, module.cloud_connection_create]
  pvs_zone                = var.pvs_zone
  pvs_resource_group_name = var.pvs_resource_group_name
  pvs_service_name        = var.pvs_service_name
  cloud_connection_count  = var.cloud_connection_count
  pvs_subnet_names        = [var.pvs_management_network.name, var.pvs_backup_network.name]
}

module "power_management_service_squid" {

  source     = "./submodules/power_management_services_setup"
  depends_on = [module.cloud_connection_attach]
  count      = var.squid_config["squid_enable"] ? 1 : 0

  access_host_or_ip          = var.access_host_or_ip
  target_server_ip           = var.squid_config["server_host_or_ip"]
  ssh_private_key            = var.ssh_private_key
  service_config             = var.squid_config
  perform_proxy_client_setup = var.perform_proxy_client_setup
}

module "power_management_service_dns" {

  source     = "./submodules/power_management_services_setup"
  depends_on = [module.cloud_connection_attach, module.power_management_service_squid]
  count      = var.dns_forwarder_config["dns_enable"] ? 1 : 0

  access_host_or_ip          = var.access_host_or_ip
  target_server_ip           = var.dns_forwarder_config["server_host_or_ip"]
  ssh_private_key            = var.ssh_private_key
  service_config             = var.dns_forwarder_config
  perform_proxy_client_setup = var.perform_proxy_client_setup
}

module "power_management_service_ntp" {

  source     = "./submodules/power_management_services_setup"
  depends_on = [module.cloud_connection_attach, module.power_management_service_squid, module.power_management_service_dns]
  count      = var.ntp_forwarder_config["ntp_enable"] ? 1 : 0

  access_host_or_ip          = var.access_host_or_ip
  target_server_ip           = var.ntp_forwarder_config["server_host_or_ip"]
  ssh_private_key            = var.ssh_private_key
  service_config             = var.ntp_forwarder_config
  perform_proxy_client_setup = var.perform_proxy_client_setup
}

module "power_management_service_nfs" {

  source     = "./submodules/power_management_services_setup"
  depends_on = [module.cloud_connection_attach, module.power_management_service_squid, module.power_management_service_dns, module.power_management_service_ntp]
  count      = var.nfs_config["nfs_enable"] ? 1 : 0

  access_host_or_ip          = var.access_host_or_ip
  target_server_ip           = var.nfs_config["server_host_or_ip"]
  ssh_private_key            = var.ssh_private_key
  service_config             = var.nfs_config
  perform_proxy_client_setup = var.perform_proxy_client_setup
}
