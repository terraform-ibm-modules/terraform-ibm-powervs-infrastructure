#####################################################
# PowerVS Instance module
#####################################################

locals {
  sap_boot_images             = ["RHEL8-SP6-SAP", "SLES15-SP4-SAP", "RHEL8-SP6-SAP-NETWEAVER", "SLES15-SP4-SAP-NETWEAVER"]
  powervs_instance_name       = "demo"
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
