data "ibm_is_instance" "vsi" {
  name = var.vsi_name
}

data "ibm_is_vpc" "vpc" {
  identifier = data.ibm_is_instance.vsi.vpc
}

locals {
  vsi_info = {
    floating_ip            = var.fip_enabled ? var.attached_fip : null
    id                     = data.ibm_is_instance.vsi.id
    ipv4_address           = data.ibm_is_instance.vsi.primary_network_interface[0].primary_ip[0].address
    secondary_ipv4_address = length(data.ibm_is_instance.vsi.network_interfaces) == 0 ? null : data.ibm_is_instance.vsi.network_interfaces[0].primary_ipv4_address
    name                   = var.vsi_name
    vpc_id                 = data.ibm_is_instance.vsi.vpc
    vpc_name               = data.ibm_is_vpc.vpc.name
    zone                   = data.ibm_is_instance.vsi.zone
  }
  ssh_public_key_name = data.ibm_is_instance.vsi.keys[0].name
  #ssh_public_key_id   = data.ibm_is_instance.vsi.keys[0].id
}

data "ibm_is_ssh_key" "jump_host_ssh_key" {
  count = length(data.ibm_is_instance.vsi.keys) > 0 ? 1 : 0
  name  = local.ssh_public_key_name
}
