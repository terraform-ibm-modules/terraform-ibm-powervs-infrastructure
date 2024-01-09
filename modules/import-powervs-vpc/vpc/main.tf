data "ibm_is_instance" "vsi_ds" {
  name = var.vsi_name
}

data "ibm_is_vpc" "vpc_ds" {
  identifier = data.ibm_is_instance.vsi_ds.vpc
}

data "ibm_is_floating_ips" "relevant_floating_ips" {
  #count          = var.fip.is_attached ? 1 : 0
  resource_group = data.ibm_is_instance.vsi_ds.resource_group
}

locals {
  relevant_fip_data = length(data.ibm_is_floating_ips.relevant_floating_ips.floating_ips) > 0 ? [for ip in data.ibm_is_floating_ips.relevant_floating_ips.floating_ips : ip if var.fip.attached_fip == ip.address] : null
  floating_ip_crn   = var.fip.is_attached && local.relevant_fip_data != null ? local.relevant_fip_data[0].crn : null
  floating_ip_id    = var.fip.is_attached && local.relevant_fip_data != null ? local.relevant_fip_data[0].id : null
  vsi_details = {
    floating_ip            = var.fip.is_attached ? var.fip.attached_fip : null
    floating_ip_crn        = local.floating_ip_crn
    floating_ip_id         = local.floating_ip_id
    id                     = data.ibm_is_instance.vsi_ds.id
    ipv4_address           = data.ibm_is_instance.vsi_ds.primary_network_interface[0].primary_ip[0].address
    secondary_ipv4_address = length(data.ibm_is_instance.vsi_ds.network_interfaces) == 0 ? null : data.ibm_is_instance.vsi_ds.network_interfaces[0].primary_ipv4_address
    name                   = var.vsi_name
    vpc_id                 = data.ibm_is_instance.vsi_ds.vpc
    vpc_name               = data.ibm_is_vpc.vpc_ds.name
    zone                   = data.ibm_is_instance.vsi_ds.zone
  }
  ssh_public_key_name = data.ibm_is_instance.vsi_ds.keys[0].name
}

data "ibm_is_ssh_key" "jump_host_ssh_key_ds" {
  count = length(data.ibm_is_instance.vsi_ds.keys) > 0 ? 1 : 0
  name  = local.ssh_public_key_name
}
