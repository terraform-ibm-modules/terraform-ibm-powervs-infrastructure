#############################
# VPC landing zone presets
#############################
locals {

  external_access_ip = var.external_access_ip != null && var.external_access_ip != "" ? length(regexall("/", var.external_access_ip)) > 0 ? var.external_access_ip : "${var.external_access_ip}/32" : ""

  ## Validate NFS Server Storage config
  valid_nfs_server_config = var.configure_nfs_server ? var.nfs_server_config != null ? var.nfs_server_config.size != null && var.nfs_server_config.size != "" && var.nfs_server_config.mount_path != null && var.nfs_server_config.mount_path != "" ? true : false : false : false
  valid_nfs_config        = var.configure_nfs_server ? local.valid_nfs_server_config : true
  validate_nfs_config_msg = "'var.configure_nfs_server' is true but 'var.nfs_server_config' has incorrect value."
  # tflint-ignore: terraform_unused_declarations
  validate_nfs_config_chk = regex("^${local.validate_nfs_config_msg}$", (local.valid_nfs_config ? local.validate_nfs_config_msg : ""))
  nfs_enable              = local.valid_nfs_config && var.configure_nfs_server ? true : false
  nfs_volume_size         = local.nfs_enable ? var.nfs_server_config.size : 0

  vsi_images = {
    "1VPC_RHEL" = "ibm-redhat-8-6-amd64-sap-applications-4"
    "3VPC_RHEL" = "ibm-redhat-8-6-amd64-sap-applications-4"
    "3VPC_SLES" = "ibm-sles-15-4-amd64-sap-applications-6"
  }

  landing_zone_preset = {
    "1VPC_RHEL" = {
      template_path = "${path.module}/presets/1vpc.preset.json.tftpl"
      template_vars = { external_access_ip = local.external_access_ip, nfs_volume_size = local.nfs_volume_size, vsi_image = local.vsi_images["1VPC_RHEL"] }
    },
    "3VPC_RHEL" = {
      template_path = "${path.module}/presets/3vpc.preset.json.tftpl"
      template_vars = { external_access_ip = local.external_access_ip, nfs_volume_size = local.nfs_volume_size, vsi_image = local.vsi_images["3VPC_RHEL"] }
    },
    "3VPC_SLES" = {
      template_path = "${path.module}/presets/3vpc.preset.json.tftpl"
      template_vars = { external_access_ip = local.external_access_ip, nfs_volume_size = local.nfs_volume_size, vsi_image = local.vsi_images["3VPC_SLES"] }
    }
  }

  landing_zone_configuration = lookup(local.landing_zone_preset, var.landing_zone_configuration, null)
  override_json_string       = templatefile(local.landing_zone_configuration.template_path, local.landing_zone_configuration.template_vars)
}


###########################################
# Locals for verifying and extracting IPs
# from landing zone outputs to configure OS
##########################################ä

locals {

  key_fip_vsi_exists     = contains(keys(module.landing_zone), "fip_vsi") ? true : false
  key_floating_ip_exists = local.key_fip_vsi_exists ? contains(keys(module.landing_zone.fip_vsi[0]), "floating_ip") ? true : false : false
  access_host_or_ip      = local.key_floating_ip_exists ? module.landing_zone.fip_vsi[0].floating_ip : ""

  key_vsi_list_exists    = contains(keys(module.landing_zone), "vsi_list") ? true : false
  private_svs_vsi_exists = local.key_vsi_list_exists ? contains(module.landing_zone.vsi_names, "${var.prefix}-private-svs-001") ? true : false : false
  private_svs_ip         = local.private_svs_vsi_exists ? [for vsi in module.landing_zone.vsi_list : vsi.ipv4_address if vsi.name == "${var.prefix}-private-svs-001"][0] : ""

  inet_svs_vsi_exists = local.key_vsi_list_exists ? contains(module.landing_zone.vsi_names, "${var.prefix}-inet-svs-001") ? true : false : false
  inet_svs_ip         = local.inet_svs_vsi_exists ? [for vsi in module.landing_zone.vsi_list : vsi.ipv4_address if vsi.name == "${var.prefix}-inet-svs-001"][0] : ""

  ###### For 3VPC presets floating ip , inet svs vsi and private svs vsi should exist.
  valid_3vpc_json_used   = contains(["3VPC_RHEL", "3VPC_SLES"], var.landing_zone_configuration) ? local.key_floating_ip_exists && local.inet_svs_vsi_exists && local.private_svs_vsi_exists : true
  validate_3vpc_json_msg = "Wrong JSON preset used. Please use one of the JSON preset supported for Power."
  # tflint-ignore: terraform_unused_declarations
  validate_3vpc_json_chk = regex("^${local.validate_3vpc_json_msg}$", (local.valid_3vpc_json_used ? local.validate_3vpc_json_msg : ""))

  ###### For 1VPC presets floating ip and inet svs vsi should exist.
  valid_1vpc_json_used   = contains(["1VPC_RHEL"], var.landing_zone_configuration) ? local.key_floating_ip_exists && local.inet_svs_vsi_exists : true
  validate_1vpc_json_msg = "Wrong JSON preset used. Please use one of the JSON preset supported for Power."
  # tflint-ignore: terraform_unused_declarations
  validate_1vpc_json_chk = regex("^${local.validate_1vpc_json_msg}$", (local.valid_1vpc_json_used ? local.validate_1vpc_json_msg : ""))
}
