locals {
  ibm_powervs_zone_region_map = {
    "syd04"    = "syd"
    "syd05"    = "syd"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "lon04"    = "lon"
    "lon06"    = "lon"
    "wdc04"    = "us-east"
    "us-east"  = "us-east"
    "us-south" = "us-south"
    "dal12"    = "us-south"
    "dal13"    = "us-south"
    "tor01"    = "tor"
    "tok04"    = "tok"
    "osa21"    = "osa"
    "sao01"    = "sao"
    "mon01"    = "mon"

  }
}

provider "ibm" {
  region           = lookup(local.ibm_powervs_zone_region_map, var.powervs_zone, null)
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

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
  slz_output     = jsondecode(data.ibm_schematics_output.schematics_output.output_json)
  prefix         = local.slz_output[0].prefix.value
  ssh_public_key = local.slz_output[0].ssh_public_key.value

  landing_zone_config = jsondecode(local.slz_output[0].config.value)
  nfs_disk_exists     = [for vsi in local.landing_zone_config.vsi : vsi.block_storage_volumes[0].capacity if contains(keys(vsi), "block_storage_volumes")]
  nfs_disk_size       = length(local.nfs_disk_exists) >= 1 ? local.nfs_disk_exists[0] : ""

  transit_gateway_name = local.slz_output[0].transit_gateway_name.value

  access_host_or_ip_exists = contains(keys(local.slz_output[0].fip_vsi.value[0]), "floating_ip") ? true : false
  access_host_or_ip        = local.access_host_or_ip_exists ? local.slz_output[0].fip_vsi.value[0].floating_ip : ""
  private_svs_vsi_exists   = contains(local.slz_output[0].vsi_names.value, "${local.slz_output[0].prefix.value}-private-svs-1") ? true : false
  private_svs_ip           = local.private_svs_vsi_exists ? [for vsi in local.slz_output[0].vsi_list.value : vsi.ipv4_address if vsi.name == "${local.slz_output[0].prefix.value}-private-svs-1"][0] : ""
  inet_svs_vsi_exists      = contains(local.slz_output[0].vsi_names.value, "${local.slz_output[0].prefix.value}-inet-svs-1") ? true : false
  inet_svs_ip              = local.inet_svs_vsi_exists ? [for vsi in local.slz_output[0].vsi_list.value : vsi.ipv4_address if vsi.name == "${local.slz_output[0].prefix.value}-inet-svs-1"][0] : ""

  correct_json_used = local.access_host_or_ip != "" && local.inet_svs_ip != "" && local.private_svs_ip != "" ? true : false
  squid_enable      = local.correct_json_used && var.configure_proxy ? true : false
  dns_enable        = local.correct_json_used && var.configure_dns_forwarder ? true : false
  ntp_enable        = local.correct_json_used && var.configure_ntp_forwarder ? true : false
  nfs_enable        = local.correct_json_used && var.configure_nfs_server && local.nfs_disk_size != "" ? true : false
  squid_port        = "3128"
}

locals {

  ### Squid Proxy will be installed on "${local.prefix}-inet-svs-1" vsi
  squid_config = {
    "squid_enable"      = local.squid_enable
    "server_host_or_ip" = local.inet_svs_ip
    "squid_port"        = local.squid_port
  }

  ### Proxy client will be configured on "${local.prefix}-private-svs-1" vsi
  perform_proxy_client_setup = {
    squid_client_ips = [local.private_svs_ip]
    squid_server_ip  = local.squid_config["server_host_or_ip"]
    squid_port       = local.squid_config["squid_port"]
    no_proxy_hosts   = "161.0.0.0/8"
  }

  ### DNS Forwarder will be configured on "${local.prefix}-private-svs-1" vsi
  dns_config = merge(var.dns_forwarder_config, {
    "dns_enable"        = local.dns_enable
    "server_host_or_ip" = local.private_svs_ip
  })

  ### NTP Forwarder will be configured on "${local.prefix}-private-svs-1" vsi
  ntp_config = {
    "ntp_enable"        = local.ntp_enable
    "server_host_or_ip" = local.private_svs_ip
  }

  ### NFS server will be configured on "${local.prefix}-private-svs-1" vsi
  nfs_config = {
    "nfs_enable"        = local.nfs_enable
    "server_host_or_ip" = local.private_svs_ip
    "nfs_file_system"   = [{ name = "nfs", mount_path : "/nfs", size : local.nfs_disk_size }]
  }

}

module "powervs_infra" {
  source = "../../../../"

  powervs_zone                = var.powervs_zone
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_workspace_name      = "${local.prefix}-${var.powervs_zone}-power-workspace"
  tags                        = var.tags
  powervs_image_names         = var.powervs_image_names
  powervs_sshkey_name         = "${local.prefix}-${var.powervs_zone}-ssh-pvs-key"
  ssh_public_key              = local.ssh_public_key
  ssh_private_key             = var.ssh_private_key
  powervs_management_network  = var.powervs_management_network
  powervs_backup_network      = var.powervs_backup_network
  transit_gateway_name        = local.transit_gateway_name
  reuse_cloud_connections     = false
  cloud_connection_count      = var.cloud_connection["count"]
  cloud_connection_speed      = var.cloud_connection["speed"]
  cloud_connection_gr         = var.cloud_connection["global_routing"]
  cloud_connection_metered    = var.cloud_connection["metered"]
  access_host_or_ip           = local.access_host_or_ip
  squid_config                = local.squid_config
  dns_forwarder_config        = local.dns_config
  ntp_forwarder_config        = local.ntp_config
  nfs_config                  = local.nfs_config
  perform_proxy_client_setup  = local.perform_proxy_client_setup
}
