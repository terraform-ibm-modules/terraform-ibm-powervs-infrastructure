####################################################
# Locals for creating ACL rules
####################################################

locals {
  acl_preset          = templatefile("${path.module}/../../modules/import-powervs-vpc/presets/vpc_acl_rules.json.tftpl", { access_host_ip = module.access_host.vsi_primary_ip })
  imported_acl_preset = jsondecode(local.acl_preset)

  # access control list rules from presets
  management_vpc_acl_rules = flatten([local.imported_acl_preset.management_acl[0].rules[*]])
  # list of subnets from each vpc
  management_vsi_subnets = flatten([module.access_host.vsi_ds.primary_network_interface[*].subnet, module.access_host.vsi_ds.network_interfaces[*].subnet])
}

####################################################
# Locals for creating Security Group rules
####################################################

locals {
  sg_preset          = templatefile("${path.module}/../../modules/import-powervs-vpc/presets/vpc_sg_rules.json.tftpl", { access_host_ip = module.access_host.vsi_primary_ip })
  imported_sg_preset = jsondecode(local.sg_preset)

  # security rules from presets
  management_sg_rules = flatten([local.imported_sg_preset.management_sg.rules[*]])
  # list of security groups from each VSI
  management_sgs = distinct(flatten([module.access_host.vsi_ds.primary_network_interface[*].security_groups, module.access_host.vsi_ds.network_interfaces[*].security_groups]))
}

####################################################
# Locals for outputs
####################################################
locals {
  proxy_host_ip_port  = join(":", [var.proxy_server_ip_port.ip, var.proxy_server_ip_port.port])
  nfs_host_or_ip_path = var.nfs_server_ip_path.ip != "" ? join(":", [var.nfs_server_ip_path.ip, var.nfs_server_ip_path.nfs_path]) : ""
}
