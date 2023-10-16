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
  override_json_string = local.new_preset
}

#####################################################
# PowerVS Infrastructure module
#####################################################

module "powervs_infra" {
  source = "../../"

  powervs_zone                = var.powervs_zone
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_workspace_name      = "${var.prefix}-${var.powervs_zone}-power-workspace"
  tags                        = var.tags
  powervs_image_names         = var.powervs_image_names
  powervs_sshkey_name         = "${var.prefix}-${var.powervs_zone}-ssh-pvs-key"
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
# VPC VSI Management Services OS configuration
#####################################################

module "vsi_configure_proxy_server" {

  source = "../../submodules/ansible_configure_network_services"

  access_host_or_ip          = local.access_host_or_ip
  target_server_ip           = local.inet_svs_ip
  ssh_private_key            = var.ssh_private_key
  service_config             = local.squid_config
  perform_proxy_client_setup = null
}

resource "time_sleep" "wait_for_squid_setup_to_complete" {
  depends_on = [module.vsi_configure_proxy_server]

  create_duration = "120s"
}

module "landing_zone_configure_network_services" {

  source     = "../../submodules/ansible_configure_network_services"
  depends_on = [time_sleep.wait_for_squid_setup_to_complete]

  access_host_or_ip          = local.access_host_or_ip
  target_server_ip           = local.private_svs_ip
  ssh_private_key            = var.ssh_private_key
  service_config             = local.network_services_config
  perform_proxy_client_setup = local.perform_proxy_client_setup
}
