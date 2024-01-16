####################################################
# Locals for outputs
####################################################
locals {
  dns_server_provided = var.dns_server_ip != ""
  nfs_server_provided = var.nfs_server_ip_path.vsi_ip != ""

  proxy_host_or_ip_port = join(":", [module.edge_vsi.vsi_details.ipv4_address, var.proxy_host.port])
  nfs_host_or_ip_path   = local.nfs_server_provided ? join(":", [var.nfs_server_ip_path.vsi_ip, var.nfs_server_ip_path.nfs_path]) : ""
  dns_host_ip           = local.dns_server_provided ? var.dns_server_ip : ""
}

locals {
  vsi_list  = flatten([[module.access_host.vsi_details], module.access_host.vsi_details.name != module.edge_vsi.vsi_details.name ? [module.edge_vsi.vsi_details] : []])
  vpc_names = local.vsi_list[*].vpc_name
  vsi_names = local.vsi_list[*].name
}

####################################################
# Locals for creating ACL rules
####################################################

locals {
  acl_preset          = templatefile("${path.module}/../../modules/import-powervs-vpc/presets/vpc_acl_rules.json.tftpl", { access_host_ip = module.access_host.vsi_details.ipv4_address, inet_host_ip = "", workload_host_ip = "" })
  imported_acl_preset = jsondecode(local.acl_preset)

  # access control list rules from presets
  managemnt_vpc_acl_rules = flatten([local.imported_acl_preset.management_acl[0].rules[*]])
  # list of subnets from each vpc
  management_vsi_subnets = flatten([module.access_host.vsi_ds.primary_network_interface[*].subnet, module.access_host.vsi_ds.network_interfaces[*].subnet])
}

####################################################
# Locals for creating Security Group rules
####################################################

locals {
  sg_preset          = templatefile("${path.module}/../../modules/import-powervs-vpc/presets/vpc_sg_rules.json.tftpl", { access_host_ip = module.access_host.vsi_details.ipv4_address, inet_host_ip = "", workload_host_ip = "" })
  imported_sg_preset = jsondecode(local.sg_preset)

  # security rules from presets
  managemnt_sg_rules = flatten([local.imported_sg_preset.management_sg.rules[*]])
  # list of security groups from each VSI
  management_sgs = distinct(flatten([module.access_host.vsi_ds.primary_network_interface[*].security_groups, module.access_host.vsi_ds.network_interfaces[*].security_groups]))
}
