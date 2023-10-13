#####################################################
# VPC landing zone module
#####################################################

module "landing_zone" {
  source    = "terraform-ibm-modules/landing-zone/ibm//patterns//vsi//module"
  version   = "4.13.0"
  providers = { ibm = ibm.ibm-is }

  ssh_public_key       = var.ssh_public_key
  region               = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
  prefix               = var.prefix
  override_json_string = local.preset
}

#####################################################
# PowerVS Infrastructure module
#####################################################

module "powervs_infra" {
  source = "../../"

  powervs_zone                = var.powervs_zone
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_workspace_name      = local.powervs_workspace_name
  tags                        = var.tags
  powervs_image_names         = local.powervs_image_names
  powervs_sshkey_name         = local.powervs_sshkey_name
  ssh_public_key              = var.ssh_public_key
  powervs_management_network  = var.powervs_management_network
  powervs_backup_network      = var.powervs_backup_network
  transit_gateway_id          = module.landing_zone.transit_gateway_data.id
  cloud_connection_count      = var.cloud_connection["count"]
  cloud_connection_speed      = var.cloud_connection["speed"]
  cloud_connection_gr         = var.cloud_connection["global_routing"]
  cloud_connection_metered    = var.cloud_connection["metered"]
}

#####################################################
# PowerVS Instance module
#####################################################

module "demo_pi_instance" {
  source     = "git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-instance.git?ref=v0.3.0"
  depends_on = [module.powervs_infra]

  pi_zone                 = var.powervs_zone
  pi_resource_group_name  = var.powervs_resource_group_name
  pi_workspace_name       = local.powervs_workspace_name
  pi_sshkey_name          = local.powervs_sshkey_name
  pi_instance_name        = local.powervs_instance_name
  pi_os_image_name        = local.powervs_instance_boot_image
  pi_networks             = local.powervs_subnets
  pi_sap_profile_id       = local.powervs_instance_sap_profile_id
  pi_number_of_processors = local.powervs_instance_cores
  pi_memory_size          = local.powervs_instance_memory
  pi_server_type          = local.sap_system_creation_enabled ? null : "s922"
  pi_cpu_proc_type        = local.sap_system_creation_enabled ? null : "shared"
  pi_storage_config       = local.powervs_instance_storage_config
}
