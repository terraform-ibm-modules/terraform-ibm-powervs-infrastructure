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
  path_sles_preset   = "./../../presets/slz-for-powervs/sles-vpc-pvs.preset.json.tftpl"
  external_access_ip = var.external_access_ip != null && var.external_access_ip != "" ? length(regexall("/", var.external_access_ip)) > 0 ? var.external_access_ip : "${var.external_access_ip}/32" : ""
  new_preset         = upper(var.landing_zone_configuration) == "RHEL" ? templatefile(local.path_rhel_preset, { external_access_ip = local.external_access_ip }) : templatefile(local.path_sles_preset, { external_access_ip = local.external_access_ip })

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
  #private_svs_vsi_exists   = local.vsi_list_exists ? contains(module.landing_zone.vsi_names, "${var.prefix}-private-svs-1") ? true : false : false
  #private_svs_ip           = local.private_svs_vsi_exists ? [for vsi in module.landing_zone.vsi_list : vsi.ipv4_address if vsi.name == "${var.prefix}-private-svs-1"][0] : ""
  inet_svs_vsi_exists = local.vsi_list_exists ? contains(module.landing_zone.vsi_names, "${var.prefix}-inet-svs-1") ? true : false : false
  inet_svs_ip         = local.inet_svs_vsi_exists ? [for vsi in module.landing_zone.vsi_list : vsi.ipv4_address if vsi.name == "${var.prefix}-inet-svs-1"][0] : ""
  squid_port          = "3128"

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
  powervs_sshkey_name      = module.powervs_infra.powervs_sshkey_name
  powervs_share_image_name = upper(var.powervs_share_vsi_os_config) == "RHEL" ? "RHEL8-SP4-SAP-NETWEAVER" : "SLES15-SP3-SAP-NETWEAVER"
  powervs_share_subnets    = [module.powervs_infra.powervs_management_network_name, module.powervs_infra.powervs_backup_network_name]
}

module "share_fs_instance" {
  source     = "git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap.git//submodules//power_instance?ref=v6.2.0"
  providers  = { ibm = ibm.ibm-pvs }
  depends_on = [module.landing_zone, module.powervs_infra]
  count      = var.powervs_share_number_of_instances

  powervs_zone                 = var.powervs_zone
  powervs_resource_group_name  = var.powervs_resource_group_name
  powervs_workspace_name       = "${var.prefix}-${var.powervs_zone}-power-workspace"
  powervs_instance_name        = var.powervs_share_instance_name
  powervs_sshkey_name          = local.powervs_sshkey_name
  powervs_os_image_name        = local.powervs_share_image_name
  powervs_server_type          = var.powervs_share_server_type
  powervs_cpu_proc_type        = var.powervs_share_cpu_proc_type
  powervs_number_of_processors = var.powervs_share_number_of_processors
  powervs_memory_size          = var.powervs_share_memory_size
  powervs_networks             = local.powervs_share_subnets
  powervs_storage_config       = var.powervs_share_storage_config
}


locals {

  #access_host_or_ip = module.powervs_infra.access_host_or_ip
  #target_server_ips = module.powervs_infra.proxy_host_or_ip_port

  perform_proxy_client_setup_vsi = {
    enable         = false
    server_ip_port = ""
    no_proxy_hosts = "161.0.0.0/8,10.0.0.0/8"
  }

  perform_ntp_client_setup = {
    enable    = var.configure_ntp_forwarder
    server_ip = module.powervs_infra.ntp_host_or_ip
  }

  perform_dns_client_setup = {
    enable    = var.configure_dns_forwarder
    server_ip = module.powervs_infra.dns_host_or_ip
  }

  perform_nfs_client_setup = {
    enable          = var.configure_ntp_forwarder
    nfs_server_path = module.powervs_infra.nfs_host_or_ip_path
    nfs_client_path = var.nfs_client_directory
  }

  target_server_ips       = module.share_fs_instance[*].instance_mgmt_ip
  sharefs_storage_configs = [for instance_wwns in module.share_fs_instance[*].instance_wwns : merge(var.powervs_share_storage_config, { "wwns" = join(",", instance_wwns) })]
  all_storage_configs     = local.sharefs_storage_configs
}

module "instance_init" {

  #source     = "./submodules/power_sap_instance_init"
  source     = "git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap.git//submodules//power_sap_instance_init?ref=v6.2.0"
  depends_on = [module.landing_zone, module.powervs_infra, module.share_fs_instance]

  count                            = var.configure_os == true ? 1 : 0
  access_host_or_ip                = local.access_host_or_ip
  os_image_distro                  = var.powervs_share_vsi_os_config
  target_server_ips                = local.target_server_ips
  powervs_instance_storage_configs = local.all_storage_configs
  sap_solutions                    = ["NONE"]
  ssh_private_key                  = var.ssh_private_key
  perform_proxy_client_setup       = local.perform_proxy_client_setup_vsi
  perform_nfs_client_setup         = local.perform_nfs_client_setup
  perform_ntp_client_setup         = local.perform_ntp_client_setup
  perform_dns_client_setup         = local.perform_dns_client_setup
  sap_domain                       = var.sap_domain
}
