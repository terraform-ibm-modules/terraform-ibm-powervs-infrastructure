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

module "power_workspace" {
  source = "./submodules/power_workspace"

  powervs_zone                = var.powervs_zone
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_workspace_name      = var.powervs_workspace_name
  tags                        = var.tags
  powervs_image_names         = var.powervs_image_names
  powervs_sshkey_name         = var.powervs_sshkey_name
  ssh_public_key              = var.ssh_public_key
  powervs_management_network  = var.powervs_management_network
  powervs_backup_network      = var.powervs_backup_network
}

module "cloud_connection_create" {
  source                       = "./submodules/power_cloudconnection_create"
  depends_on                   = [module.power_workspace]
  count                        = var.reuse_cloud_connections ? 0 : 1
  powervs_zone                 = var.powervs_zone
  powervs_resource_group_name  = var.powervs_resource_group_name
  powervs_workspace_name       = var.powervs_workspace_name
  transit_gateway_name         = var.transit_gateway_name
  cloud_connection_name_prefix = var.cloud_connection_name_prefix
  cloud_connection_count       = var.cloud_connection_count
  cloud_connection_speed       = var.cloud_connection_speed
  cloud_connection_gr          = var.cloud_connection_gr
  cloud_connection_metered     = var.cloud_connection_metered

}

module "cloud_connection_attach" {
  source                      = "./submodules/power_cloudconnection_attach"
  depends_on                  = [module.power_workspace, module.cloud_connection_create]
  powervs_zone                = var.powervs_zone
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_workspace_name      = var.powervs_workspace_name
  cloud_connection_count      = var.cloud_connection_count
  powervs_subnet_names        = [var.powervs_management_network.name, var.powervs_backup_network.name]
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

resource "time_sleep" "wait_for_squid_setup_to_complete" {
  depends_on      = [module.power_management_service_squid]
  create_duration = "60s"
}

module "power_management_service_dns" {

  source     = "./submodules/power_management_services_setup"
  depends_on = [module.cloud_connection_attach, module.power_management_service_squid, time_sleep.wait_for_squid_setup_to_complete]
  count      = var.dns_forwarder_config["dns_enable"] ? 1 : 0

  access_host_or_ip          = var.access_host_or_ip
  target_server_ip           = var.dns_forwarder_config["server_host_or_ip"]
  ssh_private_key            = var.ssh_private_key
  service_config             = var.dns_forwarder_config
  perform_proxy_client_setup = var.perform_proxy_client_setup
}

module "power_management_service_ntp" {

  source     = "./submodules/power_management_services_setup"
  depends_on = [module.cloud_connection_attach, module.power_management_service_squid, module.power_management_service_dns, time_sleep.wait_for_squid_setup_to_complete]
  count      = var.ntp_forwarder_config["ntp_enable"] ? 1 : 0

  access_host_or_ip          = var.access_host_or_ip
  target_server_ip           = var.ntp_forwarder_config["server_host_or_ip"]
  ssh_private_key            = var.ssh_private_key
  service_config             = var.ntp_forwarder_config
  perform_proxy_client_setup = var.perform_proxy_client_setup
}

module "power_management_service_nfs" {

  source     = "./submodules/power_management_services_setup"
  depends_on = [module.cloud_connection_attach, module.power_management_service_squid, module.power_management_service_dns, module.power_management_service_ntp, time_sleep.wait_for_squid_setup_to_complete]
  count      = var.nfs_config["nfs_enable"] ? 1 : 0

  access_host_or_ip          = var.access_host_or_ip
  target_server_ip           = var.nfs_config["server_host_or_ip"]
  ssh_private_key            = var.ssh_private_key
  service_config             = var.nfs_config
  perform_proxy_client_setup = var.perform_proxy_client_setup
}
