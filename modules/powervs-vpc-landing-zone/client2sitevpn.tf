#####################################################
# Creates:
# - Optional Secrets Manager
# - Optional certificates
# - Optional Client 2 site VPN
#####################################################

#####################################################
# Locals
#####################################################

locals {

  sm_guid   = var.client_to_site_vpn.enable && var.existing_sm_instance_guid == null ? ibm_resource_instance.secrets_manager[0].guid : var.existing_sm_instance_guid
  sm_region = var.client_to_site_vpn.enable && var.existing_sm_instance_region == null ? lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null) : var.existing_sm_instance_region

  root_ca_name         = "${var.prefix}-root-ca"
  root_ca_common_name  = "example.com"
  intermediate_ca_name = "${var.prefix}-intermediate-ca"
  cert_common_name     = "example"

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

  vpn_server_routes = merge(local.default_server_routes,
    tomap(
      {
        for instance in local.powervs_server_routes :
        instance.route_name => {
          destination = instance.destination
          action      = instance.action
        }
        if !startswith(instance.destination, "10.")
      }
    )
  )
}


# Create a new SM instance if not using an existing one
resource "ibm_resource_instance" "secrets_manager" {
  provider = ibm.ibm-sm
  count    = var.client_to_site_vpn.enable && var.existing_sm_instance_guid == null ? 1 : 0

  name              = "${var.prefix}-sm-instance"
  service           = "secrets-manager"
  plan              = var.sm_service_plan
  location          = local.sm_region
  resource_group_id = module.landing_zone.resource_group_data["${var.prefix}-slz-edge-rg"]
  timeouts {
    create = "20m" # Extending provisioning time to 20 minutes
  }
}

# Configure private cert engine if provisioning a new SM instance
module "private_secret_engine" {
  source     = "terraform-ibm-modules/secrets-manager-private-cert-engine/ibm"
  version    = "1.3.3"
  providers  = { ibm = ibm.ibm-sm }
  count      = var.client_to_site_vpn.enable && var.existing_sm_instance_guid == null ? 1 : 0
  depends_on = [ibm_resource_instance.secrets_manager]

  secrets_manager_guid      = local.sm_guid
  region                    = local.sm_region
  root_ca_name              = local.root_ca_name
  root_ca_common_name       = local.root_ca_common_name
  root_ca_max_ttl           = "8760h"
  intermediate_ca_name      = local.intermediate_ca_name
  certificate_template_name = var.certificate_template_name
}

# Create a secret group to place the certificate in
module "secrets_manager_group" {
  source    = "terraform-ibm-modules/secrets-manager-secret-group/ibm"
  version   = "1.2.2"
  providers = { ibm = ibm.ibm-sm }
  count     = var.client_to_site_vpn.enable ? 1 : 0

  region                   = local.sm_region
  secrets_manager_guid     = local.sm_guid
  secret_group_name        = "${var.prefix}-certificates-secret-group"
  secret_group_description = "secret group used for private certificates"

}

# Create private cert to use for VPN server
module "secrets_manager_private_certificate" {
  source     = "terraform-ibm-modules/secrets-manager-private-cert/ibm"
  version    = "1.3.1"
  providers  = { ibm = ibm.ibm-sm }
  count      = var.client_to_site_vpn.enable ? 1 : 0
  depends_on = [module.private_secret_engine]


  cert_name              = "${var.prefix}-cts-vpn-private-cert"
  cert_description       = "an example private cert"
  cert_template          = var.certificate_template_name
  cert_secrets_group_id  = module.secrets_manager_group[0].secret_group_id
  cert_common_name       = local.cert_common_name
  secrets_manager_guid   = local.sm_guid
  secrets_manager_region = local.sm_region

}

# Create client to site VPN Server
module "client_to_site_vpn" {
  source    = "terraform-ibm-modules/client-to-site-vpn/ibm"
  version   = "1.7.20"
  providers = { ibm = ibm.ibm-is }
  count     = var.client_to_site_vpn.enable ? 1 : 0

  vpn_gateway_name              = "${var.prefix}-vpc-pvs-vpn"
  resource_group_id             = module.landing_zone.resource_group_data["${var.prefix}-slz-edge-rg"]
  access_group_name             = "${var.prefix}-client-to-site-vpn-access-group"
  subnet_ids                    = [for subnet in module.landing_zone.subnet_data : subnet.id if subnet.name == "${var.prefix}-edge-vpn-zone-1"]
  client_ip_pool                = var.client_to_site_vpn.client_ip_pool
  secrets_manager_id            = local.sm_guid
  server_cert_crn               = module.secrets_manager_private_certificate[0].secret_crn
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
