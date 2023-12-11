####################################################
# Locals for outputs
####################################################
locals {
  proxy_host_or_ip_port = join(":", [module.edge_vsi.vsi_details.ipv4_address, var.proxy_host.port])
  nfs_host_or_ip_path   = join(":", [module.workload_vsi.vsi_details.ipv4_address, var.workload_host.nfs_path])
}

locals {
  vsi_list  = distinct(flatten([module.access_host.vsi_details, [[module.edge_vsi.vsi_details], []][var.access_host.vsi_name != var.proxy_host.vsi_name ? 0 : 1], [[module.workload_vsi.vsi_details], []][var.access_host.vsi_name != var.workload_host.vsi_name && var.proxy_host.vsi_name != var.workload_host.vsi_name ? 0 : 1]]))
  vpc_names = distinct([module.access_host.vsi_details.vpc_name, module.edge_vsi.vsi_details.vpc_name, module.workload_vsi.vsi_details.vpc_name])
  vsi_names = distinct([module.access_host.vsi_details.name, module.edge_vsi.vsi_details.name, module.workload_vsi.vsi_details.name])
}

locals {
  cloud_connections = tolist([for each in data.ibm_tg_gateway.tgw_ds.connections : each.name if each.network_type == "directlink"])
}

####################################################
# Locals for creating ACL rules
####################################################

locals {
  acl_preset             = templatefile("${path.module}/../../modules/powervs-vpc-landing-zone/presets/vpc_acl_rules.json.tftpl", { access_host_ip = module.access_host.vsi_details.ipv4_address, inet_host_ip = module.edge_vsi.vsi_details.ipv4_address, workload_host_ip = module.workload_vsi.vsi_details.ipv4_address })
  imported_acl_preset    = jsondecode(local.acl_preset)
  mng_common_preset_tpl  = templatefile("${path.module}/../../modules/powervs-vpc-landing-zone/presets/common_acl_rules.json.tftpl", { host_ip = module.access_host.vsi_details.ipv4_address })
  mng_common_preset      = jsondecode(local.mng_common_preset_tpl)
  edge_common_preset_tpl = templatefile("${path.module}/../../modules/powervs-vpc-landing-zone/presets/common_acl_rules.json.tftpl", { host_ip = module.edge_vsi.vsi_details.ipv4_address })
  edge_common_preset     = jsondecode(local.edge_common_preset_tpl)
  wrk_common_preset_tpl  = templatefile("${path.module}/../../modules/powervs-vpc-landing-zone/presets/common_acl_rules.json.tftpl", { host_ip = module.workload_vsi.vsi_details.ipv4_address })
  wrk_common_preset      = jsondecode(local.wrk_common_preset_tpl)
  # access control list rules from presets
  managemnt_vpc_acl_rules = flatten([local.imported_acl_preset.management_acl[0].rules[*], local.mng_common_preset.common_acl[0].rules[*]])
  edge_vpc_acl_rules      = [local.imported_acl_preset.edge_acl[0].rules[*], flatten([local.imported_acl_preset.edge_acl[0].rules[*], local.edge_common_preset.common_acl[0].rules[*]])][var.access_host.vsi_name == var.proxy_host.vsi_name ? 0 : 1]
  workload_vpc_acl_rules  = [local.imported_acl_preset.workload_acl[0].rules[*], [local.imported_acl_preset.workload_acl[0].rules[*], flatten([local.imported_acl_preset.workload_acl[0].rules[*], local.wrk_common_preset.common_acl[0].rules[*]])][var.proxy_host.vsi_name == var.workload_host.vsi_name ? 0 : 1]][var.access_host.vsi_name == var.workload_host.vsi_name ? 0 : 1]
  # list of subnets from each vpc
  management_vsi_subnets = flatten([module.access_host.vsi_ds.primary_network_interface[*].subnet, module.access_host.vsi_ds.network_interfaces[*].subnet])
  edge_vsi_subnets       = flatten([module.edge_vsi.vsi_ds.primary_network_interface[*].subnet, module.edge_vsi.vsi_ds.network_interfaces[*].subnet])
  workload_vsi_subnets   = flatten([module.workload_vsi.vsi_ds.primary_network_interface[*].subnet, module.workload_vsi.vsi_ds.network_interfaces[*].subnet])
}

####################################################
# Locals for creating Security Group rules
####################################################

locals {
  sg_preset          = templatefile("${path.module}/../../modules/powervs-vpc-landing-zone/presets/sg_rules.json.tftpl", { access_host_ip = module.access_host.vsi_details.ipv4_address, inet_host_ip = module.edge_vsi.vsi_details.ipv4_address, workload_host_ip = module.workload_vsi.vsi_details.ipv4_address })
  imported_sg_preset = jsondecode(local.sg_preset)
  # security rules from presets
  common_sg_rules    = local.imported_sg_preset.common_sg.rules[*]
  managemnt_sg_rules = flatten([local.imported_sg_preset.management_sg.rules[*], local.common_sg_rules])
  edge_sg_rules      = [local.imported_sg_preset.edge_sg.rules[*], flatten([local.imported_sg_preset.edge_sg.rules[*], local.common_sg_rules])][var.access_host.vsi_name == var.proxy_host.vsi_name ? 0 : 1]
  workload_sg_rules  = [local.imported_sg_preset.workload_sg.rules[*], [local.imported_sg_preset.workload_sg.rules[*], flatten([local.imported_sg_preset.workload_sg.rules[*], local.common_sg_rules])][var.proxy_host.vsi_name == var.workload_host.vsi_name ? 0 : 1]][var.access_host.vsi_name == var.workload_host.vsi_name ? 0 : 1]
  # list of security groups from each VSI
  management_sgs = distinct(flatten([module.access_host.vsi_ds.primary_network_interface[*].security_groups, module.access_host.vsi_ds.network_interfaces[*].security_groups]))
  edge_sgs       = distinct(flatten([module.edge_vsi.vsi_ds.primary_network_interface[*].security_groups, module.edge_vsi.vsi_ds.network_interfaces[*].security_groups]))
  workload_sgs   = distinct(flatten([module.workload_vsi.vsi_ds.primary_network_interface[*].security_groups, module.workload_vsi.vsi_ds.network_interfaces[*].security_groups]))
}
