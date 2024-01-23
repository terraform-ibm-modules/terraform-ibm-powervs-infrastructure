data "ibm_is_instance" "vsi_ds" {
  name = var.vsi_name
}

data "ibm_is_vpc" "vpc_ds" {
  identifier = data.ibm_is_instance.vsi_ds.vpc
}

locals {
  ssh_public_key_name = data.ibm_is_instance.vsi_ds.keys[0].name
}

data "ibm_is_ssh_key" "jump_host_ssh_key_ds" {
  count = length(data.ibm_is_instance.vsi_ds.keys) > 0 ? 1 : 0
  name  = local.ssh_public_key_name
}
