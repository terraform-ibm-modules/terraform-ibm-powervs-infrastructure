#####################################################
# PowerVS Instance module
#####################################################

data "ibm_pi_catalog_images" "catalog_images_ds" {
  provider             = ibm.ibm-pi
  pi_cloud_instance_id = module.standard.powervs_workspace_guid
  sap                  = true
  vtl                  = true
}

locals {
  p10_unsupported_regions = ["che01", "lon04", "lon06", "mon01", "syd04", "syd05", "tor01", "us-east", "us-south"] # datacenters that don't support P10 yet
  server_type             = contains(local.p10_unsupported_regions, var.powervs_zone) ? "s922" : "s1022"
  sap_profile_id          = contains(local.p10_unsupported_regions, var.powervs_zone) ? "ush1-4x256" : "sh2-4x256" # sap_profile_id for P9 and P10

  ibm_powervs_quickstart_tshirt_sizes = {
    "aix_xs"       = { "sap_profile_id" = null, "server_type" = local.server_type, "proc_type" = "shared", "cores" = "1", "memory" = "32", "storage" = "100", "tier" = "tier3", "image" = var.tshirt_size.image }
    "aix_s"        = { "sap_profile_id" = null, "server_type" = local.server_type, "proc_type" = "shared", "cores" = "4", "memory" = "128", "storage" = "500", "tier" = "tier3", "image" = var.tshirt_size.image }
    "aix_m"        = { "sap_profile_id" = null, "server_type" = local.server_type, "proc_type" = "shared", "cores" = "8", "memory" = "256", "storage" = "1000", "tier" = "tier3", "image" = var.tshirt_size.image }
    "aix_l"        = { "sap_profile_id" = null, "server_type" = local.server_type, "proc_type" = "shared", "cores" = "14", "memory" = "512", "storage" = "2000", "tier" = "tier3", "image" = var.tshirt_size.image }
    "ibm_i_xs"     = { "sap_profile_id" = null, "server_type" = local.server_type, "proc_type" = "shared", "cores" = "0.25", "memory" = "8", "storage" = "100", "tier" = "tier3", "image" = var.tshirt_size.image }
    "ibm_i_s"      = { "sap_profile_id" = null, "server_type" = local.server_type, "proc_type" = "shared", "cores" = "1", "memory" = "32", "storage" = "500", "tier" = "tier3", "image" = var.tshirt_size.image }
    "ibm_i_m"      = { "sap_profile_id" = null, "server_type" = local.server_type, "proc_type" = "shared", "cores" = "2", "memory" = "64", "storage" = "1000", "tier" = "tier3", "image" = var.tshirt_size.image }
    "ibm_i_l"      = { "sap_profile_id" = null, "server_type" = local.server_type, "proc_type" = "shared", "cores" = "4", "memory" = "132", "storage" = "2000", "tier" = "tier3", "image" = var.tshirt_size.image }
    "sap_dev_rhel" = { "sap_profile_id" = local.sap_profile_id, "server_type" = null, "proc_type" = null, "storage" = "750", "tier" = "tier1", "image" = var.tshirt_size.image }
    "sap_dev_sles" = { "sap_profile_id" = local.sap_profile_id, "server_type" = null, "proc_type" = null, "storage" = "750", "tier" = "tier1", "image" = var.tshirt_size.image }
    "custom"       = { "sap_profile_id" = var.custom_profile.sap_profile_id, "server_type" = var.custom_profile.server_type, "proc_type" = var.custom_profile.proc_type, "cores" = var.custom_profile.cores, "memory" = var.custom_profile.memory, "storage" = var.custom_profile.storage.size, "tier" = var.custom_profile.storage.tier, "image" = var.custom_profile_instance_boot_image }
  }

  sap_boot_images = [
    "RHEL8-SP10-SAP",
    "RHEL8-SP10-SAP-NETWEAVER",
    "RHEL8-SP4-SAP",
    "RHEL8-SP4-SAP-NETWEAVER",
    "RHEL8-SP6-SAP-NETWEAVER",
    "RHEL8-SP8-SAP",
    "RHEL8-SP8-SAP-NETWEAVER",
    "RHEL9-SP2-SAP",
    "RHEL9-SP2-SAP-NETWEAVER",
    "RHEL9-SP4-SAP",
    "RHEL9-SP4-SAP-NETWEAVER",
    "SLES15-SP3-SAP",
    "SLES15-SP3-SAP-NETWEAVER",
    "SLES15-SP4-SAP-NETWEAVER",
    "SLES15-SP5-SAP",
    "SLES15-SP5-SAP-NETWEAVER",
    "SLES15-SP6-SAP",
    "SLES15-SP6-SAP-NETWEAVER",
  ]

  qs_tshirt_choice = lookup(local.ibm_powervs_quickstart_tshirt_sizes, var.tshirt_size.tshirt_size, null)

  valid_boot_image_provided     = local.qs_tshirt_choice.image != "none" ? true : false
  valid_boot_image_provided_msg = "'custom_profile' is enabled, but variable 'custom_profile_instance_boot_image' is set to none."
  # tflint-ignore: terraform_unused_declarations
  validate_provided_custom_boot_image_chk = regex("^${local.valid_boot_image_provided_msg}$", (local.valid_boot_image_provided ? local.valid_boot_image_provided_msg : ""))

  sap_system_creation_enabled = local.qs_tshirt_choice.sap_profile_id != "" && local.qs_tshirt_choice.sap_profile_id != null
  valid_sap_boot_image_used   = local.sap_system_creation_enabled ? contains(local.sap_boot_images, local.qs_tshirt_choice.image) : true
  validate_sap_boot_image_msg = "The provided boot image for powervs instance is not a SAP image."
  # tflint-ignore: terraform_unused_declarations
  validate_sap_boot_image_chk = regex("^${local.validate_sap_boot_image_msg}$", (local.valid_sap_boot_image_used ? local.validate_sap_boot_image_msg : ""))

  custom_profile_enabled        = var.tshirt_size.tshirt_size == "custom" ? true : false
  valid_custom_profile_provided = ((var.custom_profile.cores != "" && var.custom_profile.memory != "" && var.custom_profile.server_type != "" && var.custom_profile.proc_type != "") || (var.custom_profile.sap_profile_id != null && var.custom_profile.sap_profile_id != "")) && var.tshirt_size.tshirt_size == "custom" && var.custom_profile_instance_boot_image != "none"
  valid_custom_profile_msg      = "'tshirt_size' must be set to 'custom', 'custom_profile_instance_boot_image' and 'custom_profile' values must be correctly set to use custom profile"
  # tflint-ignore: terraform_unused_declarations
  valid_custom_profile_msg_chk = regex("^${local.valid_custom_profile_msg}$", (local.custom_profile_enabled ? local.valid_custom_profile_provided ? local.valid_custom_profile_msg : "" : local.valid_custom_profile_msg))

  catalog_images = {
    for stock_image in data.ibm_pi_catalog_images.catalog_images_ds.images :
    stock_image.name => stock_image.image_id
  }

  pi_instance_os_type = can(regex("RHEL|SLES", local.qs_tshirt_choice.image)) ? "linux" : can(regex("^7\\d{3}-\\d{2}-\\d{2}$", local.qs_tshirt_choice.image)) ? "aix" : "ibm_i"
  pi_instance = {
    pi_image_id             = lookup(local.catalog_images, local.qs_tshirt_choice.image, null)
    pi_networks             = [module.standard.powervs_management_subnet, module.standard.powervs_backup_subnet]
    pi_instance_name        = "${var.prefix}-pi-qs"
    pi_sap_profile_id       = local.sap_system_creation_enabled ? local.qs_tshirt_choice.sap_profile_id : null
    pi_server_type          = local.sap_system_creation_enabled ? null : local.qs_tshirt_choice.server_type
    pi_number_of_processors = local.sap_system_creation_enabled ? null : local.qs_tshirt_choice.cores
    pi_memory_size          = local.sap_system_creation_enabled ? null : local.qs_tshirt_choice.memory
    pi_cpu_proc_type        = local.sap_system_creation_enabled ? null : local.qs_tshirt_choice.proc_type
    ## Include additional storage for AIX image as root volume is very small
    pi_storage_config = local.qs_tshirt_choice.storage != "" && local.qs_tshirt_choice.tier != "" ? local.pi_instance_os_type == "aix" ? [
      { name  = "rootextend",
        size  = "30",
        count = "1",
        tier  = "tier3",
        mount = "/"
      },
      {
        name  = "data",
        size  = local.qs_tshirt_choice.storage,
        count = "1",
        tier  = local.qs_tshirt_choice.tier,
        mount = "/data"
      }
      ] : [
      { name  = "data",
        size  = local.qs_tshirt_choice.storage,
        count = "1",
        tier  = local.qs_tshirt_choice.tier,
        mount = "/data"
      }
    ] : null
  }

  network_services_config = {
    squid = { enable = true, squid_server_ip_port = module.standard.proxy_host_or_ip_port, no_proxy_hosts = "161.0.0.0/0,10.0.0.0/8" }
    nfs   = { enable = var.configure_nfs_server, nfs_server_path = module.standard.nfs_host_or_ip_path, nfs_client_path = lookup(var.nfs_server_config, "mount_path", ""), opts = "sec=sys,nfsvers=4.1,nofail", fstype = "nfs4" }
    dns   = { enable = var.configure_dns_forwarder, dns_server_ip = module.standard.dns_host_or_ip }
    ntp   = { enable = var.configure_ntp_forwarder, ntp_server_ip = module.standard.ntp_host_or_ip }
  }

}
