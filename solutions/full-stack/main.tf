locals {
  ibm_powervs_zone_region_map = {
    "lon04"    = "lon"
    "lon06"    = "lon"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "tor01"    = "tor"
    "mon01"    = "mon"
    "osa21"    = "osa"
    "tok04"    = "tok"
    "syd04"    = "syd"
    "syd05"    = "syd"
    "sao01"    = "sao"
    "us-south" = "us-south"
    "dal10"    = "us-south"
    "dal12"    = "us-south"
    "us-east"  = "us-east"
  }

  ibm_powervs_zone_cloud_region_map = {
    "syd04"    = "au-syd"
    "syd05"    = "au-syd"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "lon04"    = "eu-gb"
    "lon06"    = "eu-gb"
    "tok04"    = "jp-tok"
    "tor01"    = "ca-tor"
    "osa21"    = "jp-osa"
    "sao01"    = "br-sao"
    "mon01"    = "ca-tor"
    "us-south" = "us-south"
    "dal10"    = "us-south"
    "dal12"    = "us-south"
    "us-east"  = "us-east"
  }
}

# There are discrepancies between the region inputs on the powervs terraform resource, and the vpc ("is") resources
provider "ibm" {
  region           = lookup(local.ibm_powervs_zone_region_map, var.powervs_zone, null)
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

provider "ibm" {
  alias            = "ibm-is"
  region           = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

locals {
  path_rhel_preset   = "${path.module}/../../presets/slz-for-powervs/rhel-vpc-pvs.preset.json.tftpl"
  path_sles_preset   = "${path.module}/../../presets/slz-for-powervs/sles-vpc-pvs.preset.json.tftpl"
  external_access_ip = var.external_access_ip != null && var.external_access_ip != "" ? length(regexall("/", var.external_access_ip)) > 0 ? var.external_access_ip : "${var.external_access_ip}/32" : ""
  new_preset         = upper(var.landing_zone_configuration) == "RHEL" ? templatefile(local.path_rhel_preset, { external_access_ip = local.external_access_ip }) : templatefile(local.path_sles_preset, { external_access_ip = local.external_access_ip })

}

#####################################################
# VPC landing zone module
#####################################################

module "landing_zone" {
  source    = "terraform-ibm-modules/landing-zone/ibm//patterns//vsi//module"
  version   = "4.10.0"
  providers = { ibm = ibm.ibm-is }

  #  ibmcloud_api_key     = var.ibmcloud_api_key
  ssh_public_key       = var.ssh_public_key
  region               = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
  prefix               = var.prefix
  override_json_string = local.new_preset
}

locals {
  landing_zone_config = jsondecode(module.landing_zone.config)
  nfs_disk_exists     = [for vsi in local.landing_zone_config.vsi : vsi.block_storage_volumes[0].capacity if contains(keys(vsi), "block_storage_volumes")]
  nfs_disk_size       = length(local.nfs_disk_exists) >= 1 ? local.nfs_disk_exists[0] : ""

  transit_gateway_name = module.landing_zone.transit_gateway_name

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
    "squid_enable"      = true
    "server_host_or_ip" = local.inet_svs_ip
    "squid_port"        = local.squid_port
  }

  ### Proxy client will be configured on "${var.prefix}-private-svs-1" vsi
  perform_proxy_client_setup = {
    squid_client_ips = [local.private_svs_ip]
    squid_server_ip  = local.squid_config["server_host_or_ip"]
    squid_port       = local.squid_config["squid_port"]
    no_proxy_hosts   = "161.0.0.0/8"
  }

  ### DNS Forwarder will be configured on "${var.prefix}-private-svs-1" vsi
  dns_config = merge(var.dns_forwarder_config, {
    "dns_enable"        = var.configure_dns_forwarder
    "server_host_or_ip" = local.private_svs_ip
  })

  ### NTP Forwarder will be configured on "${var.prefix}-private-svs-1" vsi
  ntp_config = {
    "ntp_enable"        = var.configure_ntp_forwarder
    "server_host_or_ip" = local.private_svs_ip
  }

  ### NFS server will be configured on "${var.prefix}-private-svs-1" vsi
  nfs_config = {
    "nfs_enable"        = local.nfs_disk_size != "" ? var.configure_nfs_server : false
    "server_host_or_ip" = local.private_svs_ip
    "nfs_file_system"   = [{ name = "nfs", mount_path : "/nfs", size : local.nfs_disk_size }]
  }

}

#####################################################
# PowerVS Infrastructure module
#####################################################


module "powervs_infra" {
  source     = "../../"
  depends_on = [module.landing_zone]

  powervs_zone                = var.powervs_zone
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_workspace_name      = "${var.prefix}-${var.powervs_zone}-power-workspace"
  tags                        = var.tags
  powervs_image_names         = var.powervs_image_names
  powervs_sshkey_name         = "${var.prefix}-${var.powervs_zone}-ssh-pvs-key"
  ssh_public_key              = var.ssh_public_key
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
