#############################
# Landing Zone module
#############################

module "landing_zone" {
  source    = "terraform-ibm-modules/landing-zone/ibm//patterns//vsi//module"
  version   = "5.15.2"
  providers = { ibm = ibm.ibm-is }

  ssh_public_key       = var.ssh_public_key
  region               = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
  prefix               = var.prefix
  override_json_string = local.override_json_string
}

#####################################################
# VPN Client to Site module
#####################################################

module "client_to_site_vpn" {
  source    = "terraform-ibm-modules/client-to-site-vpn/ibm"
  version   = "1.7.1"
  providers = { ibm = ibm.ibm-is }

  count = var.client_to_site_vpn.enable ? 1 : 0

  vpn_gateway_name              = "${var.prefix}-vpc-pvs-vpn"
  resource_group_id             = module.landing_zone.resource_group_data["slz-management-rg"]
  access_group_name             = "${var.prefix}-client-to-site-vpn-access-group"
  subnet_ids                    = [for subnet in module.landing_zone.subnet_data : subnet.id if subnet.name == "${var.prefix}-vpn-vpn-zone-1"]
  client_ip_pool                = var.client_to_site_vpn.client_ip_pool
  secrets_manager_id            = var.client_to_site_vpn.secrets_manager_id
  server_cert_crn               = var.client_to_site_vpn.server_cert_crn
  vpn_client_access_group_users = var.client_to_site_vpn.vpn_client_access_group_users
  vpn_server_routes             = local.vpn_server_routes
}

# Allows VPN Server <=> Transit Gateway traffic
resource "ibm_is_vpc_routing_table" "transit" {
  count    = var.client_to_site_vpn.enable ? 1 : 0
  provider = ibm.ibm-is

  vpc                              = [for vpc in module.landing_zone.vpc_data : vpc.vpc_id if vpc.vpc_name == "${var.prefix}-vpn-vpc"][0]
  name                             = "${var.prefix}-route-table-vpn-server-transit"
  route_transit_gateway_ingress    = true
  accept_routes_from_resource_type = ["vpn_server"]
}

# Allows VPN Clients <=> Transit Gateway traffic
resource "ibm_is_vpc_address_prefix" "client_prefix" {
  count      = var.client_to_site_vpn.enable ? 1 : 0
  depends_on = [module.landing_zone, module.client_to_site_vpn]

  provider = ibm.ibm-is
  zone     = "${lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)}-1"
  name     = "${var.prefix}-prefix-vpn-client"
  vpc      = [for vpc in module.landing_zone.vpc_data : vpc.vpc_id if vpc.vpc_name == "${var.prefix}-vpn-vpc"][0]
  cidr     = var.client_to_site_vpn.client_ip_pool
}

#####################################################
# Ansible: Configure Network Management Services
#####################################################

module "landing_zone_configure_proxy_server" {
  source = "../ansible-configure-network-services"
  count  = local.private_svs_vsi_exists ? 1 : 0

  access_host_or_ip          = local.access_host_or_ip
  target_server_ip           = local.inet_svs_ip
  ssh_private_key            = var.ssh_private_key
  network_services_config    = local.squid_config
  perform_proxy_client_setup = null
}

resource "time_sleep" "wait_for_squid_setup_to_complete" {
  depends_on = [module.landing_zone_configure_proxy_server]
  count      = local.private_svs_vsi_exists ? 1 : 0

  create_duration = "120s"
}

module "landing_zone_configure_network_services" {
  source     = "../ansible-configure-network-services"
  depends_on = [time_sleep.wait_for_squid_setup_to_complete]

  access_host_or_ip          = local.access_host_or_ip
  target_server_ip           = local.private_svs_vsi_exists ? local.private_svs_ip : local.inet_svs_ip
  ssh_private_key            = var.ssh_private_key
  network_services_config    = local.network_services_config
  perform_proxy_client_setup = local.private_svs_vsi_exists ? local.perform_proxy_client_setup : null
}

#####################################################
# PowerVS Workspace Module
#####################################################

module "powervs_infra" {
  source    = "terraform-ibm-modules/powervs-workspace/ibm"
  version   = "1.7.2"
  providers = { ibm = ibm.ibm-pi }

  pi_zone                       = var.powervs_zone
  pi_resource_group_name        = var.powervs_resource_group_name
  pi_workspace_name             = "${var.prefix}-${var.powervs_zone}-power-workspace"
  pi_ssh_public_key             = { "name" = "${var.prefix}-${var.powervs_zone}-pcs-ssh-key", value = var.ssh_public_key }
  pi_cloud_connection           = var.cloud_connection
  pi_private_subnet_1           = var.powervs_management_network
  pi_private_subnet_2           = var.powervs_backup_network
  pi_transit_gateway_connection = { "enable" : true, "transit_gateway_id" : module.landing_zone.transit_gateway_data.id }
  pi_tags                       = var.tags
  pi_image_names                = var.powervs_image_names
}
