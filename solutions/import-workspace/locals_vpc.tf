locals {
  proxy_host_or_ip_port = join(":", [module.edge_vsi.vsi_info.ipv4_address, var.proxy_host.port])
  nfs_host_or_ip_path   = join(":", [module.workload_vsi.vsi_info.ipv4_address, var.workload_host.nfs_path])
}

locals {
  vsi_list  = [module.access_host.vsi_info, module.edge_vsi.vsi_info, module.workload_vsi.vsi_info]
  vpc_names = [module.access_host.vsi_info.vpc_name, module.edge_vsi.vsi_info.vpc_name, module.workload_vsi.vsi_info.vpc_name]
  vsi_names = [module.access_host.vsi_info.name, module.edge_vsi.vsi_info.name, module.workload_vsi.vsi_info.name]
}

locals {
  cloud_connections = tolist([for each in data.ibm_tg_gateway.ds_tggateway.connections : each.name if each.network_type == "directlink"])
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
