#################################################################################################
# This solution creates a schematics workspace for a pre-existing VPC and PowerVS Infrastructure.
# The schematics workspace id can be used to install the deployable architecture automations to
# create and configure the Power LPARs for SAP.
#################################################################################################

############################################################################
# Import Existing PowerVS Infrastructure Data
############################################################################

module "powervs_workspace_ds" {
  source    = "../../modules/import-powervs-vpc/powervs"
  providers = { ibm = ibm.ibm-pi }

  pi_workspace_guid          = var.powervs_workspace_guid
  pi_management_network_name = var.powervs_management_network_name
  pi_backup_network_name     = var.powervs_backup_network_name
}


############################################################################
# Import data of access host(jump host) Intel VSI
############################################################################

module "access_host" {
  source   = "../../modules/import-powervs-vpc/vpc"
  vsi_name = var.access_host.vsi_name
}

data "ibm_tg_gateway" "tgw_ds" {
  name = var.transit_gateway_name
}

############################################################################
# Create ACL and SG Rules required for schematics on Access Hosts VPC subnet
############################################################################

data "ibm_is_subnet" "management_subnets_ds" {
  for_each = toset(local.management_vsi_subnets)

  identifier = each.value
}

data "ibm_is_network_acl" "management_acls_ds" {
  for_each    = data.ibm_is_subnet.management_subnets_ds
  network_acl = each.value.network_acl
}

module "management_vpc_acl_rules" {
  for_each = data.ibm_is_network_acl.management_acls_ds

  source                = "../../modules/import-powervs-vpc/acl"
  ibm_is_network_acl_id = each.value.id
  acl_rules             = local.management_vpc_acl_rules
  skip_deny_rules       = false
}

module "management_sg_rules" {
  for_each = toset(local.management_sgs)

  source   = "../../modules/import-powervs-vpc/security-group"
  sg_id    = each.value
  sg_rules = local.management_sg_rules
}
