
locals {
  path_rhel_preset   = "${path.module}/../../presets/slz-for-powervs/rhel-vpc-pvs.preset.json.tftpl"
  path_sles_preset   = "${path.module}/../../presets/slz-for-powervs/sles-vpc-pvs.preset.json.tftpl"
  external_access_ip = var.external_access_ip != null && var.external_access_ip != "" ? length(regexall("/", var.external_access_ip)) > 0 ? var.external_access_ip : "${var.external_access_ip}/32" : ""
  new_preset         = upper(var.landing_zone_configuration) == "RHEL" ? templatefile(local.path_rhel_preset, { external_access_ip = local.external_access_ip }) : templatefile(local.path_sles_preset, { external_access_ip = local.external_access_ip })

}

locals {
  landing_zone_config = jsondecode(module.landing_zone.config)
  nfs_disk_exists     = [for vsi in local.landing_zone_config.vsi : vsi.block_storage_volumes[0].capacity if contains(keys(vsi), "block_storage_volumes")]
  nfs_disk_size       = length(local.nfs_disk_exists) >= 1 ? local.nfs_disk_exists[0] : ""

  fip_vsi_exists           = contains(keys(module.landing_zone), "fip_vsi") ? true : false
  access_host_or_ip_exists = local.fip_vsi_exists ? contains(keys(module.landing_zone.fip_vsi[0]), "floating_ip") ? true : false : false
  access_host_or_ip        = local.access_host_or_ip_exists ? module.landing_zone.fip_vsi[0].floating_ip : ""
  vsi_list_exists          = contains(keys(module.landing_zone), "vsi_list") ? true : false
  private_svs_vsi_exists   = local.vsi_list_exists ? contains(module.landing_zone.vsi_names, "${var.prefix}-private-svs-1") ? true : false : false
  private_svs_ip           = local.private_svs_vsi_exists ? [for vsi in module.landing_zone.vsi_list : vsi.ipv4_address if vsi.name == "${var.prefix}-private-svs-1"][0] : ""
  inet_svs_vsi_exists      = local.vsi_list_exists ? contains(module.landing_zone.vsi_names, "${var.prefix}-inet-svs-1") ? true : false : false
  inet_svs_ip              = local.inet_svs_vsi_exists ? [for vsi in module.landing_zone.vsi_list : vsi.ipv4_address if vsi.name == "${var.prefix}-inet-svs-1"][0] : ""
  squid_port               = "3128"

  valid_json_used   = local.access_host_or_ip_exists && local.private_svs_vsi_exists && local.inet_svs_vsi_exists ? true : false
  validate_json_msg = "Wrong JSON preset used. Please use one of the JSON preset supported for Power."
  # tflint-ignore: terraform_unused_declarations
  validate_json_chk = regex("^${local.validate_json_msg}$", (local.valid_json_used ? local.validate_json_msg : ""))
}

locals {

  ### Squid Proxy will be installed on "${var.prefix}-inet-svs-1" vsi
  squid_config = {
    squid = {
      "enable"            = true
      "server_host_or_ip" = local.inet_svs_ip
      "squid_port"        = local.squid_port
    }
  }

  ### Proxy client will be configured on "${var.prefix}-private-svs-1" vsi
  perform_proxy_client_setup = {
    squid_client_ips = [local.private_svs_ip]
    squid_server_ip  = local.inet_svs_ip
    squid_port       = local.squid_config.squid["squid_port"]
    no_proxy_hosts   = "161.0.0.0/8"

  }

  ### DNS, NTP Forwarder and NFS server will be configured on "${var.prefix}-private-svs-1" vsi
  network_services_config = {

    dns = merge(var.dns_forwarder_config, {
      "enable"            = var.configure_dns_forwarder
      "server_host_or_ip" = local.private_svs_ip
    })

    ntp = {
      "enable"            = var.configure_ntp_forwarder
      "server_host_or_ip" = local.private_svs_ip
    }

    nfs = {
      "enable"            = local.nfs_disk_size != "" ? var.configure_nfs_server : false
      "server_host_or_ip" = local.private_svs_ip
      "nfs_file_system"   = [{ name = "nfs", mount_path : "/nfs", size : local.nfs_disk_size }]
    }
  }
}
