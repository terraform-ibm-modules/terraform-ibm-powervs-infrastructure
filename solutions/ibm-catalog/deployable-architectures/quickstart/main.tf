locals {
  ibm_powervs_zone_region_map = {
    "lon04"    = "lon"
    "lon06"    = "lon"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "tor01"    = "tor"
    "mon01"    = "mon"
    "dal12"    = "us-south"
    "dal13"    = "us-south"
    "osa21"    = "osa"
    "tok04"    = "tok"
    "syd04"    = "syd"
    "syd05"    = "syd"
    "us-east"  = "us-east"
    "us-south" = "us-south"
    "sao01"    = "sao"
    "sao04"    = "sao"
    "wdc04"    = "us-east"
    "wdc06"    = "us-east"
    "wdc07"    = "us-east"
  }

  ibm_powervs_zone_cloud_region_map = {
    "syd04"    = "au-syd"
    "syd05"    = "au-syd"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "lon04"    = "eu-gb"
    "lon06"    = "eu-gb"
    "tok04"    = "jp-tok"
    "us-east"  = "us-east"
    "us-south" = "us-south"
    "dal12"    = "us-south"
    "dal13"    = "us-south"
    "tor01"    = "ca-tor"
    "osa21"    = "jp-osa"
    "sao01"    = "br-sao"
    "sao04"    = "br-sao"
    "mon01"    = "ca-tor"
    "wdc04"    = "us-east"
    "wdc06"    = "us-east"
    "wdc07"    = "us-east"
  }

  ibm_powervs_quickstart_tshirt_sizes = {
    "aix_xs"   = { "cores" = "1", "memory" = "32", "storage" = "100", "tier" = "tier3", "image" = "7300-01-01" }
    "aix_s"    = { "cores" = "4", "memory" = "128", "storage" = "500", "tier" = "tier3", "image" = "7300-01-01" }
    "aix_m"    = { "cores" = "8", "memory" = "256", "storage" = "1000", "tier" = "tier3", "image" = "7300-01-01" }
    "aix_l"    = { "cores" = "15", "memory" = "512", "storage" = "2000", "tier" = "tier3", "image" = "7300-01-01" }
    "ibm_i_xs" = { "cores" = "0.25", "memory" = "8", "storage" = "100", "tier" = "tier3", "image" = "IBMi-73-13-2924-1" }
    "ibm_i_s"  = { "cores" = "1", "memory" = "32", "storage" = "500", "tier" = "tier3", "image" = "IBMi-73-13-2924-1" }
    "ibm_i_m"  = { "cores" = "2", "memory" = "64", "storage" = "1000", "tier" = "tier3", "image" = "IBMi-73-13-2924-1" }
    "ibm_i_l"  = { "cores" = "4", "memory" = "132", "storage" = "2000", "tier" = "tier3", "image" = "IBMi-73-13-2924-1" }
    "sap_dev"  = { "sap_profile_id" = "ush1-4x128", "storage" = "500", "tier" = "tier3", "image" = "RHEL8-SP4-SAP" }
    "sap_olap" = { "sap_profile_id" = "bh1-16x1600", "storage" = "3170", "tier" = "tier3", "image" = "RHEL8-SP4-SAP" }
    "sap_oltp" = { "sap_profile_id" = "umh-4x960", "storage" = "2490", "tier" = "tier3", "image" = "RHEL8-SP4-SAP" }
  }

  sap_qs_infras = ["sap_dev", "sap_olap", "sap_oltp"]
}

# There are discrepancies between the region inputs on the powervs terraform resource, and the vpc ("is") resources
provider "ibm" {
  alias            = "ibm-pvs"
  region           = lookup(local.ibm_powervs_zone_region_map, var.powervs_zone, null)
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

locals {
  path_rhel_preset   = "./../../presets/slz-for-powervs/rhel-pvs-quickstart-vpc.preset.json.tfpl"
  external_access_ip = var.external_access_ip != null && var.external_access_ip != "" ? length(regexall("/", var.external_access_ip)) > 0 ? var.external_access_ip : "${var.external_access_ip}/32" : ""
  new_preset         = templatefile(local.path_rhel_preset, { external_access_ip = local.external_access_ip })

}

#####################################################
# VPC landing zone module
#####################################################

module "landing_zone" {
  source               = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone.git//patterns//vsi?ref=v3.8.3"
  ibmcloud_api_key     = var.ibmcloud_api_key
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
  inet_svs_vsi_exists      = local.vsi_list_exists ? contains(module.landing_zone.vsi_names, "${var.prefix}-inet-svs-1") ? true : false : false
  inet_svs_ip              = local.inet_svs_vsi_exists ? [for vsi in module.landing_zone.vsi_list : vsi.ipv4_address if vsi.name == "${var.prefix}-inet-svs-1"][0] : ""
  squid_port               = "3128"

  valid_json_used   = local.access_host_or_ip_exists ? true : false
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
    squid_client_ips = []
    squid_server_ip  = ""
    squid_port       = ""
    no_proxy_hosts   = ""
  }

  ### DNS Forwarder will be configured on "${var.prefix}-private-svs-1" vsi
  dns_config = merge(var.dns_forwarder_config, {
    "dns_enable"        = var.configure_dns_forwarder
    "server_host_or_ip" = local.inet_svs_ip
  })

  ### NTP Forwarder will be configured on "${var.prefix}-private-svs-1" vsi
  ntp_config = {
    "ntp_enable"        = var.configure_ntp_forwarder
    "server_host_or_ip" = local.inet_svs_ip
  }

  ### NFS server will be configured on "${var.prefix}-private-svs-1" vsi
  nfs_config = {
    "nfs_enable"        = local.nfs_disk_size != "" ? var.configure_nfs_server : false
    "server_host_or_ip" = local.inet_svs_ip
    "nfs_file_system"   = [{ name = "nfs", mount_path : "/nfs", size : local.nfs_disk_size }]
  }

}

#####################################################
# PowerVS Infrastructure module
#####################################################


module "powervs_infra" {
  source     = "../../../../"
  providers  = { ibm = ibm.ibm-pvs }
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

locals {
  powervs_instance_name    = "demo"
  powervs_instance_storage = [{ name = "data", size = local.qs_tshirt_choice.storage, count = "1", tier = local.qs_tshirt_choice.tier, mount = "/data" }]
  powervs_sshkey_name      = module.powervs_infra.powervs_sshkey_name
  powervs_share_subnets    = [module.powervs_infra.powervs_management_network_name, module.powervs_infra.powervs_backup_network_name]
  qs_tshirt_choice         = lookup(local.ibm_powervs_quickstart_tshirt_sizes, var.tshirt_size, null)
}

module "demo_sap_pi_instance" {
  count = contains(local.sap_qs_infras, var.tshirt_size) ? 1 : 0

  source     = "git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-instance.git?ref=v0.1.3"
  providers  = { ibm = ibm.ibm-pvs }
  depends_on = [module.landing_zone, module.powervs_infra]

  pi_zone                = var.powervs_zone
  pi_resource_group_name = var.powervs_resource_group_name
  pi_workspace_name      = "${var.prefix}-${var.powervs_zone}-power-workspace"
  pi_sshkey_name         = local.powervs_sshkey_name
  pi_instance_name       = local.powervs_instance_name
  pi_os_image_name       = local.qs_tshirt_choice.image
  pi_networks            = local.powervs_share_subnets
  pi_sap_profile_id      = local.qs_tshirt_choice.sap_profile_id
  pi_storage_config      = local.powervs_instance_storage
}

module "demo_pi_instance" {
  count = contains(local.sap_qs_infras, var.tshirt_size) ? 0 : 1
  # tflint-ignore: terraform_unused_declarations
  source     = "git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-instance.git?ref=v0.1.3"
  providers  = { ibm = ibm.ibm-pvs }
  depends_on = [module.landing_zone, module.powervs_infra]

  pi_zone                 = var.powervs_zone
  pi_resource_group_name  = var.powervs_resource_group_name
  pi_workspace_name       = "${var.prefix}-${var.powervs_zone}-power-workspace"
  pi_sshkey_name          = local.powervs_sshkey_name
  pi_instance_name        = local.powervs_instance_name
  pi_os_image_name        = local.qs_tshirt_choice.image
  pi_networks             = local.powervs_share_subnets
  pi_sap_profile_id       = null
  pi_server_type          = "s922"
  pi_cpu_proc_type        = "dedicated"
  pi_number_of_processors = local.qs_tshirt_choice.cores
  pi_memory_size          = local.qs_tshirt_choice.memory
  pi_storage_config       = local.powervs_instance_storage
}
