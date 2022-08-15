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
