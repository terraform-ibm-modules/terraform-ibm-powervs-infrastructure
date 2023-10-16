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

  powervs_workspace_name = "${var.prefix}-${var.powervs_zone}-power-workspace"
  powervs_sshkey_name    = "${var.prefix}-${var.powervs_zone}-ssh-pvs-key"
  powervs_image_names    = [local.custom_profile_enabled ? var.custom_profile_instance_boot_image : local.qs_tshirt_choice.image]
}
