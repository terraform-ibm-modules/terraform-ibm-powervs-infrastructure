######################################################################
# Import data of management and edge vpc vsis
######################################################################
module "access_host" {
  source   = "../../modules/import-powervs-vpc/vpc"
  vsi_name = var.access_host.vsi_name
  fip = {
    is_attached  = true
    attached_fip = var.access_host.floating_ip
  }
}

data "ibm_tg_gateway" "tgw_ds" {
  name = var.transit_gateway_name
}

######################################################################
# Create ACL Rules for management VPC subnet ACLs
######################################################################

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
  acl_rules             = local.managemnt_vpc_acl_rules
  skip_deny_rules       = false
}

######################################################################
# Create Security Group Rules for management VPC
######################################################################


module "management_sg_rules" {
  for_each = toset(local.management_sgs)

  source   = "../../modules/import-powervs-vpc/security-group"
  sg_id    = each.value
  sg_rules = local.managemnt_sg_rules
}
