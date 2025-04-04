#####################################################
# VPC landing zone presets
#####################################################

locals {
  ibm_powervs_zone_cloud_region_map = {
    "syd04"    = "au-syd"
    "syd05"    = "au-syd"
    "sao01"    = "br-sao"
    "sao04"    = "br-sao"
    "tor01"    = "ca-tor"
    "mon01"    = "ca-tor"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "mad02"    = "eu-es"
    "mad04"    = "eu-es"
    "lon04"    = "eu-gb"
    "lon06"    = "eu-gb"
    "osa21"    = "jp-osa"
    "tok04"    = "jp-tok"
    "us-south" = "us-south"
    "dal10"    = "us-south"
    "dal12"    = "us-south"
    "dal14"    = "us-south"
    "us-east"  = "us-east"
    "wdc06"    = "us-east"
    "wdc07"    = "us-east"
  }
}

#####################################################
# Locals for verifying and extracting IPs
# from landing zone outputs to configure OS
#####################################################

locals {

  key_fip_vsi_exists     = contains(keys(module.landing_zone), "fip_vsi") ? true : false
  key_floating_ip_exists = local.key_fip_vsi_exists ? contains(keys(module.landing_zone.fip_vsi[0]), "floating_ip") ? true : false : false
  access_host_or_ip      = local.key_floating_ip_exists ? module.landing_zone.fip_vsi[0].floating_ip : ""

  key_vsi_list_exists = contains(keys(module.landing_zone), "vsi_list") ? true : false
  # network_services_vsi_exists = local.key_vsi_list_exists ? contains(module.landing_zone.vsi_names, "${var.prefix}-network-services-001") ? true : false : false
  network_services_vsi_exists = local.key_vsi_list_exists ? length([for vsi_name in module.landing_zone.vsi_names : vsi_name if can(regex("${var.prefix}-network-services", vsi_name))]) > 0 ? true : false : false
  network_services_vsi_ip     = local.network_services_vsi_exists ? [for vsi in module.landing_zone.vsi_list : vsi.ipv4_address if can(regex("${var.prefix}-network-services", vsi.name))][0] : ""

  monitoring_vsi_exists = local.key_vsi_list_exists ? length([for vsi_name in module.landing_zone.vsi_names : vsi_name if can(regex("${var.prefix}-monitoring", vsi_name))]) > 0 ? true : false : false
  monitoring_vsi_ip     = local.monitoring_vsi_exists ? [for vsi in module.landing_zone.vsi_list : vsi.ipv4_address if can(regex("${var.prefix}-monitoring", vsi.name))][0] : ""

  ###### For preset floating ip and network services vsi should exist.
  valid_json_used   = local.key_floating_ip_exists && local.network_services_vsi_exists ? true : false
  validate_json_msg = "Wrong JSON preset used. Please use one of the JSON preset supported for Power."
  # tflint-ignore: terraform_unused_declarations
  validate_json_chk = regex("^${local.validate_json_msg}$", (local.valid_json_used ? local.validate_json_msg : ""))

}
