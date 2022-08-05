#####################################################
# PVS Configuration
# Copyright 2022 IBM
#####################################################

module "power-service" {
  source = "./submodules/power-service"

  pvs_zone                = var.pvs_zone
  pvs_resource_group_name = var.pvs_resource_group_name
  pvs_service_name        = var.pvs_service_name
  tags                    = var.tags
  pvs_sshkey_name         = var.pvs_sshkey_name
  ssh_public_key          = var.ssh_public_key
  pvs_management_network  = var.pvs_management_network
  pvs_backup_network      = var.pvs_backup_network
}

module "cloud-connection-create" {
  source                   = "./submodules/power-cloudconnection-create"
  depends_on               = [module.power-service]
  count                    = var.transit_gw_name != null && var.transit_gw_name != "" ? 1 : 0
  pvs_zone                 = var.pvs_zone
  pvs_resource_group_name  = var.pvs_resource_group_name
  pvs_service_name         = var.pvs_service_name
  transit_gw_name          = var.transit_gw_name
  cloud_connection_count   = var.cloud_connection_count
  cloud_connection_speed   = var.cloud_connection_speed
  cloud_connection_gr      = var.cloud_connection_gr
  cloud_connection_metered = var.cloud_connection_metered

}

module "cloud-connection-attach" {
  source                  = "./submodules/power-cloudconnection-attach"
  depends_on              = [module.power-service, module.cloud-connection-create]
  pvs_zone                = var.pvs_zone
  pvs_resource_group_name = var.pvs_resource_group_name
  pvs_service_name        = var.pvs_service_name
  pvs_subnet_names        = [var.pvs_management_network.name, var.pvs_backup_network.name]
}
