#####################################################
# IBM Cloud PowerVS Configuration
#####################################################

locals {
  per_enabled_dc_list = ["dal10"]
  per_enabled         = contains(local.per_enabled_dc_list, var.powervs_zone)
}


#####################################################
# Validation Submodule
#####################################################

module "initial_validation" {
  source = "./submodules/terraform_initial_validation"
  cloud_connection_validate = {
    reuse_cloud_connections = var.reuse_cloud_connections
    transit_gateway_id      = var.transit_gateway_id
  }
}


#####################################################
# Workspace Submodule ( Creates Workspace, SSH key,
# Subnets, Imports catalog images )
#####################################################

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


#####################################################
# CC Create Submodule
# Non PER DC: Creates CCs, attaches CCs to TGW
# PER DC: Attaches PowerVS workspace to TGW
#####################################################

module "powervs_cloud_connection_create" {
  source = "./submodules/powervs_cloudconnection_create"
  count  = var.reuse_cloud_connections ? 0 : 1

  powervs_zone                 = var.powervs_zone
  powervs_workspace_name       = var.powervs_workspace_name
  powervs_workspace_guid       = module.powervs_workspace.powervs_workspace_guid
  powervs_workspace_id         = module.powervs_workspace.powervs_workspace_id
  transit_gateway_id           = var.transit_gateway_id
  per_enabled                  = local.per_enabled
  cloud_connection_name_prefix = var.cloud_connection_name_prefix
  cloud_connection_count       = var.cloud_connection_count
  cloud_connection_speed       = var.cloud_connection_speed
  cloud_connection_gr          = var.cloud_connection_gr
  cloud_connection_metered     = var.cloud_connection_metered

}

#####################################################
# CC Subnet Attach Submodule
# Non PER DC: Attaches Subnets to CCs
# PER DC: Skip
#####################################################

module "powervs_cloud_connection_attach" {
  source     = "./submodules/powervs_cloudconnection_attach"
  depends_on = [module.powervs_cloud_connection_create]
  count      = local.per_enabled ? 0 : 1

  powervs_workspace_guid = module.powervs_workspace.powervs_workspace_guid
  cloud_connection_count = var.cloud_connection_count
  powervs_subnet_ids     = [module.powervs_workspace.powervs_workspace_management_subnet_id, module.powervs_workspace.powervs_workspace_backup_subnet_id]
}
