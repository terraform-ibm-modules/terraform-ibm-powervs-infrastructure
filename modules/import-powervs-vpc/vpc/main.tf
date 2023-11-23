data "ibm_is_instance" "vsi_ds" {
  name = var.vsi_name
}

data "ibm_is_vpc" "vpc_ds" {
  identifier = data.ibm_is_instance.vsi_ds.vpc
}

locals {
  vsi_details = {
    floating_ip            = var.fip_enabled ? var.attached_fip : null
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
