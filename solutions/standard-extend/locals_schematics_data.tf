locals {
  location = regex("^[a-z/-]+", var.prerequisite_workspace_id)
}

data "ibm_schematics_workspace" "schematics_workspace" {
  workspace_id = var.prerequisite_workspace_id
  location     = local.location
}

data "ibm_schematics_output" "schematics_output" {
  workspace_id = var.prerequisite_workspace_id
  location     = local.location
  template_id  = data.ibm_schematics_workspace.schematics_workspace.runtime_data[0].id
}


locals {

  standard_output      = jsondecode(data.ibm_schematics_output.schematics_output.output_json)
  prefix               = local.standard_output[0].prefix.value == "" ? "ext" : local.standard_output[0].prefix.value
  ssh_public_key       = local.standard_output[0].powervs_ssh_public_key.value.value
  transit_gateway_name = local.standard_output[0].transit_gateway_name.value
  transit_gateway_id   = local.standard_output[0].transit_gateway_id.value
  ansible_host_or_ip   = local.standard_output[0].ansible_host_or_ip.value

  access_host_or_ip_exists   = contains(keys(local.standard_output[0]), "access_host_or_ip") ? true : false
  access_host_or_ip          = local.access_host_or_ip_exists ? local.standard_output[0].access_host_or_ip.value : ""
  proxy_host_or_ip_exists    = contains(keys(local.standard_output[0]), "proxy_host_or_ip_port") && local.access_host_or_ip != "" ? true : false
  proxy_host_or_ip_port      = local.proxy_host_or_ip_exists ? local.standard_output[0].proxy_host_or_ip_port.value : ""
  dns_host_or_ip_exists      = contains(keys(local.standard_output[0]), "dns_host_or_ip") && local.access_host_or_ip != "" ? true : false
  dns_host_or_ip             = local.dns_host_or_ip_exists ? local.standard_output[0].dns_host_or_ip.value : ""
  nfs_host_or_ip_path_exists = contains(keys(local.standard_output[0]), "nfs_host_or_ip_path") && local.access_host_or_ip != "" ? true : false
  nfs_host_or_ip_path        = local.nfs_host_or_ip_path_exists ? local.standard_output[0].nfs_host_or_ip_path.value : ""
  ntp_host_or_ip_exists      = contains(keys(local.standard_output[0]), "ntp_host_or_ip") && local.access_host_or_ip != "" ? true : false
  ntp_host_or_ip             = local.ntp_host_or_ip_exists ? local.standard_output[0].ntp_host_or_ip.value : ""
  network_services_config    = local.standard_output[0].network_services_config.value

  valid_powervs_zone_used   = local.standard_output[0].powervs_zone != var.powervs_zone ? true : false
  validate_powervs_zone_msg = "A Power workspace already exists in the provided PowerVS zone. Please use a different zone."
  # tflint-ignore: terraform_unused_declarations
  validate_json_chk = regex("^${local.validate_powervs_zone_msg}$", (local.valid_powervs_zone_used ? local.validate_powervs_zone_msg : ""))

  standard_mgt_net        = local.standard_output[0].powervs_management_subnet.value.cidr
  standard_bkp_net        = local.standard_output[0].powervs_backup_subnet.value.cidr
  valid_mgt_subnet_used   = local.standard_mgt_net != var.powervs_management_network["cidr"] ? true : false
  validate_mgt_subnet_msg = "This management subnet CIDR already exists in the infrastructure. Please use another CIDR block."
  # tflint-ignore: terraform_unused_declarations
  validate_mgt_subnet_chk = regex("^${local.validate_mgt_subnet_msg}$", (local.valid_mgt_subnet_used ? local.validate_mgt_subnet_msg : ""))

  valid_bkp_subnet_used   = local.standard_bkp_net != var.powervs_backup_network["cidr"] ? true : false
  validate_bkp_subnet_msg = "This backup subnet CIDR already exists in the infrastructure. Please use another CIDR block."
  # tflint-ignore: terraform_unused_declarations
  validate_bkp_subnet_chk = regex("^${local.validate_bkp_subnet_msg}$", (local.valid_bkp_subnet_used ? local.validate_bkp_subnet_msg : ""))

  powervs_workspace_name = "${local.prefix}-${var.powervs_zone}-power-workspace"
  powervs_ssh_public_key = { "name" = "${local.prefix}-${var.powervs_zone}-ssh-pvs-key", value = local.ssh_public_key }
}
