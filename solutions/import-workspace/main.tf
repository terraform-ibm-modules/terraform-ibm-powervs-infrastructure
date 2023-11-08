locals {
  ibm_powervs_zone_region_map = {
    "lon04"    = "lon"
    "lon06"    = "lon"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "tor01"    = "tor"
    "mon01"    = "mon"
    "osa21"    = "osa"
    "tok04"    = "tok"
    "syd04"    = "syd"
    "syd05"    = "syd"
    "sao01"    = "sao"
    "us-south" = "us-south"
    "dal10"    = "us-south"
    "dal12"    = "us-south"
    "us-east"  = "us-east"
  }

  ibm_powervs_zone_cloud_region_map = {
    "syd04"    = "au-syd"
    "syd05"    = "au-syd"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "lon04"    = "eu-gb"
    "lon06"    = "eu-gb"
    "tok04"    = "jp-tok"
    "tor01"    = "ca-tor"
    "osa21"    = "jp-osa"
    "sao01"    = "br-sao"
    "mon01"    = "ca-tor"
    "us-south" = "us-south"
    "dal10"    = "us-south"
    "dal12"    = "us-south"
    "us-east"  = "us-east"
  }
}

provider "ibm" {
  region           = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

module "access_host" {
  source       = "./module/vpc"
  vsi_ip       = var.access_host.name
  fip_enabled  = true
  attached_fip = var.access_host.floating_ip
}

module "edge_vsi" {
  source = "./module/vpc"
  vsi_ip = var.proxy_host.name
}

module "workload_vsi" {
  source = "./module/vpc"
  vsi_ip = var.workload_host.name
}

locals {
  proxy_host_or_ip_port = join(":", [module.edge_vsi.vsi_info.ipv4_address, var.proxy_host.port])
  nfs_host_or_ip_path   = join(":", [module.workload_vsi.vsi_info.ipv4_address, var.workload_host.nfs_path])
}

locals {
  vsi_list  = [module.access_host.vsi_info, module.edge_vsi.vsi_info, module.workload_vsi.vsi_info]
  vpc_names = [module.access_host.vsi_info.vpc_name, module.edge_vsi.vsi_info.vpc_name, module.workload_vsi.vsi_info.vpc_name]
  # can replace with input vars
  vsi_names = [module.access_host.vsi_info.name, module.edge_vsi.vsi_info.name, module.workload_vsi.vsi_info.name]
}

data "ibm_tg_gateway" "ds_tggateway" {
  name = var.transit_gateway_name
}

locals {
  cloud_connections = tolist([for each in data.ibm_tg_gateway.ds_tggateway.connections : each.name if each.network_type == "directlink"])
}

module "power_workspace_data_retrieval" {
  source                 = "./module/powervs"
  ibmcloud_api_key       = var.ibmcloud_api_key
  powervs_region         = lookup(local.ibm_powervs_zone_region_map, var.powervs_zone, null)
  powervs_zone           = var.powervs_zone
  powervs_workspace_name = var.powervs_workspace_name
  #powervs_sshkey_name             = var.powervs_sshkey_name
  powervs_management_network_name = var.powervs_management_network_name
  powervs_backup_network_name     = var.powervs_backup_network_name
}

locals {
  new_preset = templatefile("${path.module}/../../modules/powervs-vpc-landing-zone/presets/3vpc.preset.json.tftpl", { external_access_ip = "", nfs_volume_size = "", vsi_image = "" })
  preset     = jsondecode(local.new_preset)

  managemnt_vpc_acl_rules = flatten([for s in local.preset.vpcs : s.network_acls if s.prefix == "management"])[0].rules
  management_vsi_subnets  = flatten([module.access_host.vsi_as_is.primary_network_interface[*].subnet, module.access_host.vsi_as_is.network_interfaces[*].subnet])
  edge_vpc_acl_rules      = flatten([for s in local.preset.vpcs : s.network_acls if s.prefix == "edge"])[0].rules
  edge_vsi_subnets        = flatten([module.edge_vsi.vsi_as_is.primary_network_interface[*].subnet, module.edge_vsi.vsi_as_is.network_interfaces[*].subnet])
  workload_vpc_acl_rules  = flatten([for s in local.preset.vpcs : s.network_acls if s.prefix == "workload"])[0].rules
  workload_vsi_subnets    = flatten([module.workload_vsi.vsi_as_is.primary_network_interface[*].subnet, module.workload_vsi.vsi_as_is.network_interfaces[*].subnet])
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


module "management_vpc_acl_rules_creation" {
  for_each = data.ibm_is_network_acl.management_acls

  source                = "./module/acl"
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

module "edge_vpc_acl_rules_creation" {
  for_each = data.ibm_is_network_acl.edge_acls

  source                = "./module/acl"
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

module "workload_vpc_acl_rules_creation" {
  for_each = data.ibm_is_network_acl.workload_acls

  source                = "./module/acl"
  ibm_is_network_acl_id = each.value.id
  acl_rules             = local.workload_vpc_acl_rules
}

locals {
  # security rules from presets
  managemnt_sg_rules = flatten([for s in local.preset.vsi : (s.security_group.name == "management" ? [s.security_group.rules] : [])])
  edge_sg_rules      = flatten([for s in local.preset.vsi : (s.security_group.name == "inet-svs" ? [s.security_group.rules] : [])])
  workload_sg_rules  = flatten([for s in local.preset.vsi : (s.security_group.name == "workload" ? [s.security_group.rules] : [])])
  # list of security groups from each VSI
  management_sgs = distinct(flatten([module.access_host.vsi_as_is.primary_network_interface[*].security_groups, module.access_host.vsi_as_is.network_interfaces[*].security_groups]))
  edge_sgs       = distinct(flatten([module.edge_vsi.vsi_as_is.primary_network_interface[*].security_groups, module.edge_vsi.vsi_as_is.network_interfaces[*].security_groups]))
  workload_sgs   = distinct(flatten([module.workload_vsi.vsi_as_is.primary_network_interface[*].security_groups, module.workload_vsi.vsi_as_is.network_interfaces[*].security_groups]))
}

module "management_sg_rules_creation" {
  for_each = toset(local.management_sgs)

  source   = "./module/security-group"
  sg_id    = each.value
  sg_rules = local.managemnt_sg_rules
}

module "edge_sg_rules_creation" {
  for_each = toset(local.edge_sgs)

  source   = "./module/security-group"
  sg_id    = each.value
  sg_rules = local.edge_sg_rules
}

module "wokload_sg_rules_creation" {
  for_each = toset(local.workload_sgs)

  source   = "./module/security-group"
  sg_id    = each.value
  sg_rules = local.workload_sg_rules
}
