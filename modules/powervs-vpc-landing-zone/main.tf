#############################
# Landing Zone module
#############################

module "landing_zone" {
  source    = "terraform-ibm-modules/landing-zone/ibm//patterns//vsi//module"
  version   = "5.21.0"
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
  resource_group_id             = module.landing_zone.resource_group_data["slz-edge-rg"]
  access_group_name             = "${var.prefix}-client-to-site-vpn-access-group"
  subnet_ids                    = [for subnet in module.landing_zone.subnet_data : subnet.id if subnet.name == "${var.prefix}-edge-vpn-zone-1"]
  client_ip_pool                = var.client_to_site_vpn.client_ip_pool
  secrets_manager_id            = var.client_to_site_vpn.secrets_manager_id
  server_cert_crn               = var.client_to_site_vpn.server_cert_crn
  vpn_client_access_group_users = var.client_to_site_vpn.vpn_client_access_group_users
  vpn_server_routes             = local.vpn_server_routes
}

# Allows VPN Server <=> Transit Gateway traffic
resource "ibm_is_vpc_routing_table" "transit" {
  provider = ibm.ibm-is
  count    = var.client_to_site_vpn.enable ? 1 : 0

  vpc                              = [for vpc in module.landing_zone.vpc_data : vpc.vpc_id if vpc.vpc_name == "${var.prefix}-edge-vpc"][0]
  name                             = "${var.prefix}-route-table-vpn-server-transit"
  route_transit_gateway_ingress    = true
  accept_routes_from_resource_type = ["vpn_server"]
}

# Allows VPN Clients <=> Transit Gateway traffic
resource "ibm_is_vpc_address_prefix" "client_prefix" {
  provider   = ibm.ibm-is
  count      = var.client_to_site_vpn.enable ? 1 : 0
  depends_on = [module.landing_zone, module.client_to_site_vpn]

  zone = "${lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)}-1"
  name = "${var.prefix}-prefix-vpn-client"
  vpc  = [for vpc in module.landing_zone.vpc_data : vpc.vpc_id if vpc.vpc_name == "${var.prefix}-edge-vpc"][0]
  cidr = var.client_to_site_vpn.client_ip_pool
}

resource "ibm_is_share" "nfs" {
  provider = ibm.ibm-is

  name                = "nfs"
  size                = 1000
  profile             = "dp2"
  access_control_mode = "security_group"
  iops                = 5000
  zone                = "${lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)}-1"
}

resource "ibm_is_share_mount_target" "nfs" {
  provider = ibm.ibm-is

  share = ibm_is_share.nfs.id
  name  = "nfs"
  virtual_network_interface {
    name            = "nfs"
    resource_group  = module.landing_zone.resource_group_data["slz-workload-rg"]
    subnet          = [for subnet in module.landing_zone.subnet_data : subnet.id if subnet.name == "${var.prefix}-edge-vsi-workload-zone-1"][0]
    security_groups = [for security_group in module.landing_zone.vpc_data[0].vpc_data.security_group : security_group.group_id if security_group.group_name == "workload-sg"]
  }

}

#####################################################
# PowerVS Workspace Module
#####################################################

module "powervs_infra" {
  source    = "terraform-ibm-modules/powervs-workspace/ibm"
  version   = "1.11.0"
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


#####################################################
# Ansible Host module setup and execution
#####################################################

module "configure_network_services" {
  source = "../ansible"

  bastion_host_ip    = local.access_host_or_ip
  ansible_host_or_ip = local.inet_svs_ip
  ssh_private_key    = var.ssh_private_key

  src_script_template_name    = "ansible_exec.sh.tftpl"
  dst_script_file_name        = "configure_network_services.sh"
  src_playbook_template_name  = "configure_network_services_playbook.yml.tftpl"
  dst_playbook_file_name      = "configure_network_services_playbook.yml"
  playbook_template_vars      = local.playbook_template_vars
  src_inventory_template_name = "configure_network_services_inventory.tftpl"
  dst_inventory_file_name     = "configure_network_services_inventory"
  inventory_template_vars     = local.inventory_template_vars
}
