# Import data of management, edge and workload vpc vsis

module "access_host" {
  source       = "../../modules/import-powervs-vpc/vpc"
  vsi_name     = var.access_host.vsi_name
  fip_enabled  = true
  attached_fip = var.access_host.floating_ip
}

module "edge_vsi" {
  source   = "../../modules/import-powervs-vpc/vpc"
  vsi_name = var.proxy_host.vsi_name
}

module "workload_vsi" {
  source   = "../../modules/import-powervs-vpc/vpc"
  vsi_name = var.workload_host.vsi_name
}

data "ibm_tg_gateway" "ds_tggateway" {
  name = var.transit_gateway_name
}

# Creating acl rules for management vpc

data "ibm_is_subnet" "management_subnets" {
  for_each = toset(local.management_vsi_subnets)

  identifier = each.value
}

data "ibm_is_network_acl" "management_acls" {
  for_each    = data.ibm_is_subnet.management_subnets
  network_acl = each.value.network_acl
}


module "management_vpc_acl_rules" {
  for_each = data.ibm_is_network_acl.management_acls

  source                = "../../modules/import-powervs-vpc/acl"
  ibm_is_network_acl_id = each.value.id
  acl_rules             = local.managemnt_vpc_acl_rules
}

# Creating acl rules for edge vpc

data "ibm_is_subnet" "edge_subnets" {
  for_each = toset(local.edge_vsi_subnets)

  identifier = each.value
}

data "ibm_is_network_acl" "edge_acls" {
  for_each    = data.ibm_is_subnet.edge_subnets
  network_acl = each.value.network_acl
}

module "edge_vpc_acl_rules" {
  for_each = data.ibm_is_network_acl.edge_acls

  source                = "../../modules/import-powervs-vpc/acl"
  ibm_is_network_acl_id = each.value.id
  acl_rules             = local.edge_vpc_acl_rules
}

# Creating acl rules for workload vpc

data "ibm_is_subnet" "workload_subnets" {
  for_each = toset(local.workload_vsi_subnets)

  identifier = each.value
}

data "ibm_is_network_acl" "workload_acls" {
  for_each    = data.ibm_is_subnet.workload_subnets
  network_acl = each.value.network_acl
}

module "workload_vpc_acl_rules" {
  for_each = data.ibm_is_network_acl.workload_acls

  source                = "../../modules/import-powervs-vpc/acl"
  ibm_is_network_acl_id = each.value.id
  acl_rules             = local.workload_vpc_acl_rules
}

# Creating security group rules for management, edge and workload vpcs

module "management_sg_rules" {
  for_each = toset(local.management_sgs)

  source   = "../../modules/import-powervs-vpc/security-group"
  sg_id    = each.value
  sg_rules = local.managemnt_sg_rules
}

module "edge_sg_rules" {
  for_each = toset(local.edge_sgs)

  source   = "../../modules/import-powervs-vpc/security-group"
  sg_id    = each.value
  sg_rules = local.edge_sg_rules
}

module "wokload_sg_rules" {
  for_each = toset(local.workload_sgs)

  source   = "../../modules/import-powervs-vpc/security-group"
  sg_id    = each.value
  sg_rules = local.workload_sg_rules
}
