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

  ibm_powervs_quickstart_tshirt_sizes = {
    "aix_xs"   = { "sap_profile_id" = null, "cores" = "1", "memory" = "32", "storage" = "100", "tier" = "tier3", "image" = "7300-01-01" }
    "aix_s"    = { "sap_profile_id" = null, "cores" = "4", "memory" = "128", "storage" = "500", "tier" = "tier3", "image" = "7300-01-01" }
    "aix_m"    = { "sap_profile_id" = null, "cores" = "8", "memory" = "256", "storage" = "1000", "tier" = "tier3", "image" = "7300-01-01" }
    "aix_l"    = { "sap_profile_id" = null, "cores" = "15", "memory" = "512", "storage" = "2000", "tier" = "tier3", "image" = "7300-01-01" }
    "ibm_i_xs" = { "sap_profile_id" = null, "cores" = "0.25", "memory" = "8", "storage" = "100", "tier" = "tier3", "image" = "IBMi-75-01-2984-2" }
    "ibm_i_s"  = { "sap_profile_id" = null, "cores" = "1", "memory" = "32", "storage" = "500", "tier" = "tier3", "image" = "IBMi-75-01-2984-2" }
    "ibm_i_m"  = { "sap_profile_id" = null, "cores" = "2", "memory" = "64", "storage" = "1000", "tier" = "tier3", "image" = "IBMi-75-01-2984-2" }
    "ibm_i_l"  = { "sap_profile_id" = null, "cores" = "4", "memory" = "132", "storage" = "2000", "tier" = "tier3", "image" = "IBMi-75-01-2984-2" }
    "sap_dev"  = { "sap_profile_id" = "ush1-4x128", "storage" = "500", "tier" = "tier3", "image" = "RHEL8-SP6-SAP" }
    "sap_olap" = { "sap_profile_id" = "bh1-16x1600", "storage" = "3170", "tier" = "tier3", "image" = "RHEL8-SP6-SAP" }
    "sap_oltp" = { "sap_profile_id" = "umh-4x960", "storage" = "2490", "tier" = "tier3", "image" = "RHEL8-SP6-SAP" }
  }

  sap_boot_images = ["RHEL8-SP6-SAP", "SLES15-SP4-SAP", "RHEL8-SP6-SAP-NETWEAVER", "SLES15-SP4-SAP-NETWEAVER"]
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

#####################################################
# VPC landing zone module
#####################################################

locals {
  path_rhel_preset   = "${path.module}/../../presets/slz-for-powervs/rhel-vpc-pvs-quickstart.preset.json.tfpl"
  external_access_ip = var.external_access_ip != null && var.external_access_ip != "" ? length(regexall("/", var.external_access_ip)) > 0 ? var.external_access_ip : "${var.external_access_ip}/32" : ""
  preset             = templatefile(local.path_rhel_preset, { external_access_ip = local.external_access_ip })

}

module "landing_zone" {
  source    = "terraform-ibm-modules/landing-zone/ibm//patterns//vsi//module"
  version   = "4.13.0"
  providers = { ibm = ibm.ibm-is }

  ibmcloud_api_key     = var.ibmcloud_api_key
  ssh_public_key       = var.ssh_public_key
  region               = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
  prefix               = var.prefix
  override_json_string = local.preset
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
  inet_svs_vsi_exists      = local.vsi_list_exists ? contains(module.landing_zone.vsi_names, "${var.prefix}-inet-svs-1") ? true : false : false
  inet_svs_ip              = local.inet_svs_vsi_exists ? [for vsi in module.landing_zone.vsi_list : vsi.ipv4_address if vsi.name == "${var.prefix}-inet-svs-1"][0] : ""
  squid_port               = "3128"

  valid_json_used   = local.access_host_or_ip_exists ? true : false
  validate_json_msg = "Wrong JSON preset used. Please use one of the JSON preset supported for Power."
  # tflint-ignore: terraform_unused_declarations
  validate_json_chk = regex("^${local.validate_json_msg}$", (local.valid_json_used ? local.validate_json_msg : ""))
}

#####################################################
# PowerVS Infrastructure module
#####################################################

locals {

  ### Squid Proxy will be installed on "${var.prefix}-inet-svs-1" vsi
  squid_config = {
    "squid_enable"      = true
    "server_host_or_ip" = local.inet_svs_ip
    "squid_port"        = local.squid_port
  }

  ### Proxy client will be configured on "${var.prefix}-inet-svs-1" vsi
  perform_proxy_client_setup = {
    squid_client_ips = []
    squid_server_ip  = ""
    squid_port       = ""
    no_proxy_hosts   = ""
  }

  ### DNS Forwarder will be configured on "${var.prefix}-inet-svs-1" vsi
  dns_config = merge(var.dns_forwarder_config, {
    "dns_enable"        = var.configure_dns_forwarder
    "server_host_or_ip" = local.inet_svs_ip
  })

  ### NTP Forwarder will be configured on "${var.prefix}-inet-svs-1" vsi
  ntp_config = {
    "ntp_enable"        = var.configure_ntp_forwarder
    "server_host_or_ip" = local.inet_svs_ip
  }

  ### NFS server will be configured on "${var.prefix}-inet-svs-1" vsi
  nfs_config = {
    "nfs_enable"        = local.nfs_disk_size != "" ? var.configure_nfs_server : false
    "server_host_or_ip" = local.inet_svs_ip
    "nfs_file_system"   = [{ name = "nfs", mount_path : "/nfs", size : local.nfs_disk_size }]
  }

  powervs_image_names = [local.custom_profile_enabled ? var.custom_profile_instance_boot_image : local.qs_tshirt_choice.image]
}

module "powervs_infra" {
  source     = "../../"
  depends_on = [module.landing_zone]

  powervs_zone                = var.powervs_zone
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_workspace_name      = "${var.prefix}-${var.powervs_zone}-power-workspace"
  tags                        = var.tags
  powervs_image_names         = local.powervs_image_names
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

#####################################################
# PowerVS Instance module
#####################################################

locals {
  powervs_instance_name       = "demo"
  powervs_sshkey_name         = module.powervs_infra.powervs_sshkey_name
  powervs_subnets             = [module.powervs_infra.powervs_management_network_name, module.powervs_infra.powervs_backup_network_name]
  qs_tshirt_choice            = lookup(local.ibm_powervs_quickstart_tshirt_sizes, var.tshirt_size, null)
  custom_profile_enabled      = ((var.custom_profile.cores != "" && var.custom_profile.memory != "") || (var.custom_profile.sap_profile_id != null && var.custom_profile.sap_profile_id != ""))
  sap_system_creation_enabled = (local.custom_profile_enabled && var.custom_profile.sap_profile_id != null && var.custom_profile.sap_profile_id != "") || (!local.custom_profile_enabled && (local.qs_tshirt_choice.sap_profile_id != null))

  powervs_instance_boot_image   = local.custom_profile_enabled ? var.custom_profile_instance_boot_image : local.qs_tshirt_choice.image
  valid_boot_image_provided     = local.powervs_instance_boot_image != "" ? true : false
  valid_boot_image_provided_msg = "'custom_profile' is enabled, but variable 'custom_profile_instance_boot_image' is not set."
  # tflint-ignore: terraform_unused_declarations
  validate_provided_custom_boot_image_chk = regex("^${local.valid_boot_image_provided_msg}$", (local.valid_boot_image_provided ? local.valid_boot_image_provided_msg : ""))

  valid_sap_boot_image_used   = local.sap_system_creation_enabled ? contains(local.sap_boot_images, local.powervs_instance_boot_image) : true
  validate_sap_boot_image_msg = "The provided boot image for powervs instance is not an SAP image."
  # tflint-ignore: terraform_unused_declarations
  validate_sap_boot_image_chk = regex("^${local.validate_sap_boot_image_msg}$", (local.valid_sap_boot_image_used ? local.validate_sap_boot_image_msg : ""))

  powervs_instance_sap_profile_id = local.sap_system_creation_enabled ? local.custom_profile_enabled ? var.custom_profile.sap_profile_id : local.qs_tshirt_choice.sap_profile_id : null
  powervs_instance_cores          = local.sap_system_creation_enabled ? null : local.custom_profile_enabled ? var.custom_profile.cores : local.qs_tshirt_choice.cores
  powervs_instance_memory         = local.sap_system_creation_enabled ? null : local.custom_profile_enabled ? var.custom_profile.memory : local.qs_tshirt_choice.memory
  powervs_instance_storage_size   = local.custom_profile_enabled ? var.custom_profile.storage.size : local.qs_tshirt_choice.storage
  powervs_instance_storage_tier   = local.custom_profile_enabled ? var.custom_profile.storage.tier : local.qs_tshirt_choice.tier
  powervs_instance_storage_config = local.powervs_instance_storage_size != "" && local.powervs_instance_storage_tier != "" ? [{ name = "data", size = local.powervs_instance_storage_size, count = "1", tier = local.powervs_instance_storage_tier, mount = "/data" }] : null
}

module "demo_pi_instance" {
  source     = "git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-instance.git?ref=v0.3.2"
  depends_on = [module.landing_zone, module.powervs_infra]

  pi_zone                 = var.powervs_zone
  pi_resource_group_name  = var.powervs_resource_group_name
  pi_workspace_name       = "${var.prefix}-${var.powervs_zone}-power-workspace"
  pi_sshkey_name          = local.powervs_sshkey_name
  pi_instance_name        = local.powervs_instance_name
  pi_os_image_name        = local.powervs_instance_boot_image
  pi_networks             = local.powervs_subnets
  pi_sap_profile_id       = local.powervs_instance_sap_profile_id
  pi_number_of_processors = local.powervs_instance_cores
  pi_memory_size          = local.powervs_instance_memory
  pi_server_type          = local.sap_system_creation_enabled ? null : "s922"
  pi_cpu_proc_type        = local.sap_system_creation_enabled ? null : "shared"
  pi_storage_config       = local.powervs_instance_storage_config
}
