####################################################
# Locals for outputs
####################################################
locals {
  dns_server_provided = var.dns_server != ""
  ntp_server_provided = var.ntp_server != ""
  nfs_server_provided = var.nfs_server.vsi_name != ""

  proxy_host_or_ip_port = join(":", [module.edge_vsi.vsi_details.ipv4_address, var.proxy_host.port])
  nfs_host_or_ip_path   = local.nfs_server_provided ? join(":", [module.nfs_server[0].vsi_details.ipv4_address, var.nfs_server.nfs_path]) : ""
  dns_host_ip           = local.dns_server_provided ? module.dns_server[0].vsi_details.ipv4_address : ""
}

locals {
  proxy_and_workload_vsis = flatten([
    module.edge_vsi.vsi_details,
    local.dns_server_provided ? [module.dns_server[0].vsi_details] : [],
    local.ntp_server_provided ? [module.ntp_server[0].vsi_details] : [],
    local.nfs_server_provided ? [module.nfs_server[0].vsi_details] : []
  ])

  filtered_hosts = distinct([for vsi in local.proxy_and_workload_vsis : vsi if vsi.name != var.access_host.vsi_name])
  vsi_list       = flatten([[module.access_host.vsi_details], local.filtered_hosts])
  vpc_names      = local.vsi_list[*].vpc_name
  vsi_names      = local.vsi_list[*].name
}

locals {
  cloud_connections = tolist([for each in data.ibm_tg_gateway.tgw_ds.connections : each.name if each.network_type == "directlink"])
}

####################################################
# Locals for creating ACL rules
####################################################

locals {
  acl_preset             = templatefile("${path.module}/../../modules/import-powervs-vpc/presets/vpc_acl_rules.json.tftpl", { access_host_ip = module.access_host.vsi_details.ipv4_address, inet_host_ip = module.edge_vsi.vsi_details.ipv4_address, workload_host_ip = local.dns_host_ip })
  imported_acl_preset    = jsondecode(local.acl_preset)
  mng_common_preset_tpl  = templatefile("${path.module}/../../modules/import-powervs-vpc/presets/common_acl_rules.json.tftpl", { host_ip = module.access_host.vsi_details.ipv4_address })
  mng_common_preset      = jsondecode(local.mng_common_preset_tpl)
  edge_common_preset_tpl = templatefile("${path.module}/../../modules/import-powervs-vpc/presets/common_acl_rules.json.tftpl", { host_ip = module.edge_vsi.vsi_details.ipv4_address })
  edge_common_preset     = jsondecode(local.edge_common_preset_tpl)
  wrk_common_preset_tpl  = templatefile("${path.module}/../../modules/import-powervs-vpc/presets/common_acl_rules.json.tftpl", { host_ip = local.dns_host_ip })
  wrk_common_preset      = jsondecode(local.wrk_common_preset_tpl)
  # access control list rules from presets
  managemnt_vpc_acl_rules = flatten([local.imported_acl_preset.management_acl[0].rules[*], local.mng_common_preset.common_acl[0].rules[*]])
  edge_vpc_acl_rules      = [local.imported_acl_preset.edge_acl[0].rules[*], flatten([local.imported_acl_preset.edge_acl[0].rules[*], local.edge_common_preset.common_acl[0].rules[*]])][var.access_host.vsi_name == var.proxy_host.vsi_name ? 0 : 1]
  dns_vpc_acl_rules = try(
    [local.imported_acl_preset.workload_acl[0].rules[*], flatten([local.imported_acl_preset.workload_acl[0].rules[*], local.wrk_common_preset.common_acl[0].rules[*]])][(var.access_host.vsi_name == var.dns_server) || (var.proxy_host.vsi_name == var.dns_server) ? 0 : 1],
  [])
  # list of subnets from each vpc
  management_vsi_subnets = flatten([module.access_host.vsi_ds.primary_network_interface[*].subnet, module.access_host.vsi_ds.network_interfaces[*].subnet])
  edge_vsi_subnets       = flatten([module.edge_vsi.vsi_ds.primary_network_interface[*].subnet, module.edge_vsi.vsi_ds.network_interfaces[*].subnet])
  dns_server_vsi_subnets = try(flatten([module.dns_server.vsi_ds.primary_network_interface[*].subnet, module.dns_server.vsi_ds.network_interfaces[*].subnet]), [])
}

####################################################
# Locals for creating Security Group rules
####################################################

locals {
  sg_preset          = templatefile("${path.module}/../../modules/import-powervs-vpc/presets/vpc_sg_rules.json.tftpl", { access_host_ip = module.access_host.vsi_details.ipv4_address, inet_host_ip = module.edge_vsi.vsi_details.ipv4_address, workload_host_ip = local.dns_host_ip })
  imported_sg_preset = jsondecode(local.sg_preset)
  # security rules from presets
  common_sg_rules    = local.imported_sg_preset.common_sg.rules[*]
  managemnt_sg_rules = flatten([local.imported_sg_preset.management_sg.rules[*], local.common_sg_rules])
  edge_sg_rules      = [local.imported_sg_preset.edge_sg.rules[*], flatten([local.imported_sg_preset.edge_sg.rules[*], local.common_sg_rules])][var.access_host.vsi_name == var.proxy_host.vsi_name ? 0 : 1]
  dns_sg_rules       = [local.imported_sg_preset.workload_sg.rules[*], flatten([local.imported_sg_preset.workload_sg.rules[*], local.common_sg_rules])][(var.access_host.vsi_name == var.dns_server) || (var.proxy_host.vsi_name == var.dns_server) ? 0 : 1]

  # list of security groups from each VSI
  management_sgs = distinct(flatten([module.access_host.vsi_ds.primary_network_interface[*].security_groups, module.access_host.vsi_ds.network_interfaces[*].security_groups]))
  edge_sgs       = distinct(flatten([module.edge_vsi.vsi_ds.primary_network_interface[*].security_groups, module.edge_vsi.vsi_ds.network_interfaces[*].security_groups]))
  dns_sgs        = local.dns_server_provided ? distinct(flatten([module.dns_server[0].vsi_ds.primary_network_interface[*].security_groups, module.dns_server[0].vsi_ds.network_interfaces[*].security_groups])) : []
}

# Would just removing the ACL rules for the private networks suffice?
