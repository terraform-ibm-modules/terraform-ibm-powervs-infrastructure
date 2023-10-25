#####################################################
# PowerVS Instance module
#####################################################

locals {
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

  sap_boot_images        = ["RHEL8-SP6-SAP", "SLES15-SP4-SAP", "RHEL8-SP6-SAP-NETWEAVER", "SLES15-SP4-SAP-NETWEAVER"]
  qs_tshirt_choice       = lookup(local.ibm_powervs_quickstart_tshirt_sizes, var.tshirt_size, null)
  custom_profile_enabled = ((var.custom_profile.cores != "" && var.custom_profile.memory != "") || (var.custom_profile.sap_profile_id != null && var.custom_profile.sap_profile_id != ""))
  powervs_image_names    = [local.custom_profile_enabled ? var.custom_profile_instance_boot_image : local.qs_tshirt_choice.image]

  powervs_instance_boot_image   = local.custom_profile_enabled ? var.custom_profile_instance_boot_image : local.qs_tshirt_choice.image
  valid_boot_image_provided     = local.powervs_instance_boot_image != "" ? true : false
  valid_boot_image_provided_msg = "'custom_profile' is enabled, but variable 'custom_profile_instance_boot_image' is not set."
  # tflint-ignore: terraform_unused_declarations
  validate_provided_custom_boot_image_chk = regex("^${local.valid_boot_image_provided_msg}$", (local.valid_boot_image_provided ? local.valid_boot_image_provided_msg : ""))

  sap_system_creation_enabled = (local.custom_profile_enabled && var.custom_profile.sap_profile_id != null && var.custom_profile.sap_profile_id != "") || (!local.custom_profile_enabled && (local.qs_tshirt_choice.sap_profile_id != null))
  valid_sap_boot_image_used   = local.sap_system_creation_enabled ? contains(local.sap_boot_images, local.powervs_instance_boot_image) : true
  validate_sap_boot_image_msg = "The provided boot image for powervs instance is not a SAP image."
  # tflint-ignore: terraform_unused_declarations
  validate_sap_boot_image_chk = regex("^${local.validate_sap_boot_image_msg}$", (local.valid_sap_boot_image_used ? local.validate_sap_boot_image_msg : ""))


  ##################################
  # PowerVS Instance Locals
  ##################################
  powervs_instance_boot_image_id = lookup(module.quickstart.powervs_images, local.powervs_instance_boot_image, null)
  powervs_networks               = [module.quickstart.powervs_management_subnet, module.quickstart.powervs_backup_subnet]

  powervs_instance_sap_profile_id = local.sap_system_creation_enabled ? local.custom_profile_enabled ? var.custom_profile.sap_profile_id : local.qs_tshirt_choice.sap_profile_id : null
  powervs_instance_cores          = local.sap_system_creation_enabled ? null : local.custom_profile_enabled ? var.custom_profile.cores : local.qs_tshirt_choice.cores
  powervs_instance_memory         = local.sap_system_creation_enabled ? null : local.custom_profile_enabled ? var.custom_profile.memory : local.qs_tshirt_choice.memory

  powervs_instance_storage_size   = local.custom_profile_enabled ? var.custom_profile.storage.size : local.qs_tshirt_choice.storage
  powervs_instance_storage_tier   = local.custom_profile_enabled ? var.custom_profile.storage.tier : local.qs_tshirt_choice.tier
  powervs_instance_storage_config = local.powervs_instance_storage_size != "" && local.powervs_instance_storage_tier != "" ? [{ name = "data", size = local.powervs_instance_storage_size, count = "1", tier = local.powervs_instance_storage_tier, mount = "/data" }] : null


}
