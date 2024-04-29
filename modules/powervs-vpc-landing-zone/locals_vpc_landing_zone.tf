#############################
# VPC landing zone presets
#############################
locals {
  external_access_ip   = var.external_access_ip != null && var.external_access_ip != "" ? length(regexall("/", var.external_access_ip)) > 0 ? var.external_access_ip : "${var.external_access_ip}/32" : ""
  override_json_string = templatefile("${path.module}/presets/preset.json.tftpl", { external_access_ip = local.external_access_ip, vsi_image = "ibm-redhat-8-8-amd64-sap-applications-1" })
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

  inet_svs_vsi_exists = local.key_vsi_list_exists ? contains(module.landing_zone.vsi_names, "${var.prefix}-jump-box-001") ? true : false : false
  inet_svs_ip         = local.inet_svs_vsi_exists ? [for vsi in module.landing_zone.vsi_list : vsi.ipv4_address if vsi.name == "${var.prefix}-jump-box-001"][0] : ""

  ###### For preset floating ip and private svs vsi should exist.
  valid_json_used   = local.key_floating_ip_exists && local.inet_svs_vsi_exists && local.private_svs_vsi_exists ? true : false
  validate_json_msg = "Wrong JSON preset used. Please use one of the JSON preset supported for Power."
  # tflint-ignore: terraform_unused_declarations
  validate_json_chk = regex("^${local.validate_json_msg}$", (local.valid_json_used ? local.validate_json_msg : ""))

}
