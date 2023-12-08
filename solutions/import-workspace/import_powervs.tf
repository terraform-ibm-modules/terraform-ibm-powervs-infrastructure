module "powervs_workspace_ds" {
  source    = "../../modules/import-powervs-vpc/powervs"
  providers = { ibm = ibm.ibm-pi }

  pi_workspace_name          = var.powervs_workspace_name
  pi_management_network_name = var.powervs_management_network_name
  pi_backup_network_name     = var.powervs_backup_network_name
}
