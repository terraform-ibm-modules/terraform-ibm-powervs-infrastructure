#####################################################
# PowerVS Instance module
#####################################################

locals {
  ibm_powervs_quickstart_tshirt_sizes = {
    "aix_xs"   = { "sap_profile_id" = null, "server_type" = "s922", "proc_type" = "shared", "cores" = "1", "memory" = "32", "storage" = "100", "tier" = "tier3", "image" = "7300-01-02" }
    "aix_s"    = { "sap_profile_id" = null, "server_type" = "s922", "proc_type" = "shared", "cores" = "4", "memory" = "128", "storage" = "500", "tier" = "tier3", "image" = "7300-01-02" }
    "aix_m"    = { "sap_profile_id" = null, "server_type" = "s922", "proc_type" = "shared", "cores" = "8", "memory" = "256", "storage" = "1000", "tier" = "tier3", "image" = "7300-01-02" }
    "aix_l"    = { "sap_profile_id" = null, "server_type" = "s922", "proc_type" = "shared", "cores" = "14", "memory" = "512", "storage" = "2000", "tier" = "tier3", "image" = "7300-01-02" }
    "ibm_i_xs" = { "sap_profile_id" = null, "server_type" = "s922", "proc_type" = "shared", "cores" = "0.25", "memory" = "8", "storage" = "100", "tier" = "tier3", "image" = "IBMi-75-02-2924-1" }
    "ibm_i_s"  = { "sap_profile_id" = null, "server_type" = "s922", "proc_type" = "shared", "cores" = "1", "memory" = "32", "storage" = "500", "tier" = "tier3", "image" = "IBMi-75-02-2924-1" }
    "ibm_i_m"  = { "sap_profile_id" = null, "server_type" = "s922", "proc_type" = "shared", "cores" = "2", "memory" = "64", "storage" = "1000", "tier" = "tier3", "image" = "IBMi-75-02-2924-1" }
    "ibm_i_l"  = { "sap_profile_id" = null, "server_type" = "s922", "proc_type" = "shared", "cores" = "4", "memory" = "132", "storage" = "2000", "tier" = "tier3", "image" = "IBMi-75-02-2924-1" }
    "sap_dev"  = { "sap_profile_id" = "ush1-4x128", "server_type" = null, "proc_type" = null, "storage" = "750", "tier" = "tier1", "image" = "RHEL8-SP6-SAP" }
    "custom"   = { "sap_profile_id" = var.custom_profile.sap_profile_id, "server_type" = var.custom_profile.server_type, "proc_type" = var.custom_profile.proc_type, "cores" = var.custom_profile.cores, "memory" = var.custom_profile.memory, "storage" = var.custom_profile.storage.size, "tier" = var.custom_profile.storage.tier, "image" = var.custom_profile_instance_boot_image }
  }

  sap_boot_images  = ["RHEL8-SP6-SAP", "SLES15-SP4-SAP", "RHEL8-SP6-SAP-NETWEAVER", "SLES15-SP4-SAP-NETWEAVER"]
  qs_tshirt_choice = lookup(local.ibm_powervs_quickstart_tshirt_sizes, var.tshirt_size, null)

  valid_boot_image_provided     = local.qs_tshirt_choice.image != "none" ? true : false
  valid_boot_image_provided_msg = "'custom_profile' is enabled, but variable 'custom_profile_instance_boot_image' is set to none."
  # tflint-ignore: terraform_unused_declarations
  validate_provided_custom_boot_image_chk = regex("^${local.valid_boot_image_provided_msg}$", (local.valid_boot_image_provided ? local.valid_boot_image_provided_msg : ""))

  sap_system_creation_enabled = local.qs_tshirt_choice.sap_profile_id != "" && local.qs_tshirt_choice.sap_profile_id != null
  valid_sap_boot_image_used   = local.sap_system_creation_enabled ? contains(local.sap_boot_images, local.qs_tshirt_choice.image) : true
  validate_sap_boot_image_msg = "The provided boot image for powervs instance is not a SAP image."
  # tflint-ignore: terraform_unused_declarations
  validate_sap_boot_image_chk = regex("^${local.validate_sap_boot_image_msg}$", (local.valid_sap_boot_image_used ? local.validate_sap_boot_image_msg : ""))

  custom_profile_enabled        = var.tshirt_size == "custom" ? true : false
  valid_custom_profile_provided = ((var.custom_profile.cores != "" && var.custom_profile.memory != "" && var.custom_profile.server_type != "" && var.custom_profile.proc_type != "") || (var.custom_profile.sap_profile_id != null && var.custom_profile.sap_profile_id != "")) && var.tshirt_size == "custom" && var.custom_profile_instance_boot_image != "none"
  valid_custom_profile_msg      = "'tshirt_size' must be set to 'custom', 'custom_profile_instance_boot_image' and 'custom_profile' values must be correctly set to use custom profile"
  # tflint-ignore: terraform_unused_declarations
  valid_custom_profile_msg_chk = regex("^${local.valid_custom_profile_msg}$", (local.custom_profile_enabled ? local.valid_custom_profile_provided ? local.valid_custom_profile_msg : "" : local.valid_custom_profile_msg))

  ##################################
  # PowerVS Instance Locals
  ##################################

  pi_instance = {
    pi_image_id             = lookup(module.quickstart.powervs_images, local.qs_tshirt_choice.image, null)
    pi_networks             = [module.quickstart.powervs_management_subnet, module.quickstart.powervs_backup_subnet]
    pi_instance_name        = "pi-qs"
    pi_sap_profile_id       = local.sap_system_creation_enabled ? local.qs_tshirt_choice.sap_profile_id : null
    pi_server_type          = local.sap_system_creation_enabled ? null : local.qs_tshirt_choice.server_type
    pi_number_of_processors = local.sap_system_creation_enabled ? null : local.qs_tshirt_choice.cores
    pi_memory_size          = local.sap_system_creation_enabled ? null : local.qs_tshirt_choice.memory
    pi_cpu_proc_type        = local.sap_system_creation_enabled ? null : local.qs_tshirt_choice.proc_type
    pi_storage_config       = local.qs_tshirt_choice.storage != "" && local.qs_tshirt_choice.tier != "" ? [{ name = "data", size = local.qs_tshirt_choice.storage, count = "1", tier = local.qs_tshirt_choice.tier, mount = "/data" }] : null
  }

}
