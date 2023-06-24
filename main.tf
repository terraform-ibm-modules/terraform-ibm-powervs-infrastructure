#####################################################
# IBM Cloud PowerVS Configuration
#####################################################

module "initial_validation" {
  source = "./submodules/terraform_initial_validation"
  cloud_connection_validate = {
    reuse_cloud_connections = var.reuse_cloud_connections
    transit_gateway_name    = var.transit_gateway_name
  }
}

module "powervs_workspace" {
  source = "./submodules/powervs_workspace"

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

module "powervs_cloud_connection_create" {
  source                       = "./submodules/powervs_cloudconnection_create"
  depends_on                   = [module.powervs_workspace]
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

module "powervs_cloud_connection_attach" {
  source                      = "./submodules/powervs_cloudconnection_attach"
  depends_on                  = [module.powervs_workspace, module.powervs_cloud_connection_create]
  powervs_zone                = var.powervs_zone
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_workspace_name      = var.powervs_workspace_name
  cloud_connection_count      = var.cloud_connection_count
  powervs_subnet_names        = [var.powervs_management_network.name, var.powervs_backup_network.name]
}

module "configure_squid" {

  source     = "./submodules/configure_network_services"
  depends_on = [module.powervs_cloud_connection_attach]
  count      = var.squid_config["squid_enable"] ? 1 : 0

  access_host_or_ip          = var.access_host_or_ip
  target_server_ip           = var.squid_config["server_host_or_ip"]
  ssh_private_key            = var.ssh_private_key
  service_config             = var.squid_config
  perform_proxy_client_setup = var.perform_proxy_client_setup
}

resource "time_sleep" "wait_for_squid_setup_to_complete" {
  depends_on = [module.configure_squid]
  count      = var.squid_config["squid_enable"] ? 1 : 0

  create_duration = "60s"
}

module "configure_dns" {

  source     = "./submodules/configure_network_services"
  depends_on = [module.powervs_cloud_connection_attach, module.configure_squid, time_sleep.wait_for_squid_setup_to_complete]
  count      = var.dns_forwarder_config["dns_enable"] ? 1 : 0

  access_host_or_ip          = var.access_host_or_ip
  target_server_ip           = var.dns_forwarder_config["server_host_or_ip"]
  ssh_private_key            = var.ssh_private_key
  service_config             = var.dns_forwarder_config
  perform_proxy_client_setup = var.perform_proxy_client_setup
}

module "configure_ntp" {

  source     = "./submodules/configure_network_services"
  depends_on = [module.powervs_cloud_connection_attach, module.configure_squid, module.configure_dns, time_sleep.wait_for_squid_setup_to_complete]
  count      = var.ntp_forwarder_config["ntp_enable"] ? 1 : 0

  access_host_or_ip          = var.access_host_or_ip
  target_server_ip           = var.ntp_forwarder_config["server_host_or_ip"]
  ssh_private_key            = var.ssh_private_key
  service_config             = var.ntp_forwarder_config
  perform_proxy_client_setup = var.perform_proxy_client_setup
}

module "configure_nfs" {

  source     = "./submodules/configure_network_services"
  depends_on = [module.powervs_cloud_connection_attach, module.configure_squid, module.configure_dns, module.configure_ntp, time_sleep.wait_for_squid_setup_to_complete]
  count      = var.nfs_config["nfs_enable"] ? 1 : 0

  access_host_or_ip          = var.access_host_or_ip
  target_server_ip           = var.nfs_config["server_host_or_ip"]
  ssh_private_key            = var.ssh_private_key
  service_config             = var.nfs_config
  perform_proxy_client_setup = var.perform_proxy_client_setup
}
