#####################################################
# VPN Client to Site module
#####################################################

#####################################################
# Locals for VPN config
#####################################################

locals {
  default_server_routes = {
    "vpc-vsis" = {
      destination = "10.0.0.0/8"
      action      = "deliver"
    }
  }
  powervs_server_routes = [
    {
      route_name  = "mgmt_net"
      destination = var.powervs_management_network.cidr
      action      = "deliver"
    },
    {
      route_name  = "bkp_net"
      destination = var.powervs_backup_network.cidr
      action      = "deliver"
    }
  ]
  vpn_server_routes = merge(local.default_server_routes, tomap({
    for instance in local.powervs_server_routes :
    instance.route_name => {
      destination = instance.destination
      action      = instance.action
    }
    if !startswith(instance.destination, "10.")
  }))
}

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
resource "ibm_is_vpc_address_prefix" "vpn_address_prefix" {
  provider   = ibm.ibm-is
  count      = var.client_to_site_vpn.enable ? 1 : 0
  depends_on = [module.landing_zone, module.client_to_site_vpn]

  zone = "${lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)}-1"
  name = "${var.prefix}-vpn-address-prefix"
  vpc  = [for vpc in module.landing_zone.vpc_data : vpc.vpc_id if vpc.vpc_name == "${var.prefix}-edge-vpc"][0]
  cidr = var.client_to_site_vpn.client_ip_pool
}
