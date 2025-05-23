#####################################################
# PowerVS with VPC landing zone module
#####################################################

module "standard" {
  source = "../../modules/powervs-vpc-landing-zone"

  providers = { ibm.ibm-is = ibm.ibm-is, ibm.ibm-pi = ibm.ibm-pi, ibm.ibm-sm = ibm.ibm-sm }

  powervs_zone                     = var.powervs_zone
  prefix                           = var.prefix
  external_access_ip               = var.external_access_ip
  ssh_public_key                   = var.ssh_public_key
  ssh_private_key                  = var.ssh_private_key
  client_to_site_vpn               = var.client_to_site_vpn
  vpc_intel_images                 = var.vpc_intel_images
  configure_dns_forwarder          = var.configure_dns_forwarder
  configure_ntp_forwarder          = var.configure_ntp_forwarder
  configure_nfs_server             = var.configure_nfs_server
  dns_forwarder_config             = var.dns_forwarder_config
  nfs_server_config                = var.nfs_server_config
  powervs_resource_group_name      = var.powervs_resource_group_name
  powervs_management_network       = var.powervs_management_network
  powervs_backup_network           = var.powervs_backup_network
  tags                             = var.tags
  sm_service_plan                  = var.sm_service_plan
  existing_sm_instance_guid        = var.existing_sm_instance_guid
  existing_sm_instance_region      = var.existing_sm_instance_region
  network_services_vsi_profile     = var.network_services_vsi_profile
  enable_monitoring                = var.enable_monitoring
  existing_monitoring_instance_crn = var.existing_monitoring_instance_crn
  enable_scc_wp                    = var.enable_scc_wp
  ansible_vault_password           = var.ansible_vault_password
}


#####################################################
# PowerVS Instance module
#####################################################

module "powervs_instance" {
  source    = "terraform-ibm-modules/powervs-instance/ibm"
  version   = "2.6.2"
  providers = { ibm = ibm.ibm-pi }

  pi_workspace_guid      = module.standard.powervs_workspace_guid
  pi_ssh_public_key_name = module.standard.powervs_ssh_public_key.name

  pi_image_id                = local.pi_instance.pi_image_id
  pi_networks                = local.pi_instance.pi_networks
  pi_instance_name           = local.pi_instance.pi_instance_name
  pi_sap_profile_id          = local.pi_instance.pi_sap_profile_id
  pi_server_type             = local.pi_instance.pi_server_type
  pi_number_of_processors    = local.pi_instance.pi_number_of_processors
  pi_memory_size             = local.pi_instance.pi_memory_size
  pi_cpu_proc_type           = local.pi_instance.pi_cpu_proc_type
  pi_boot_image_storage_tier = "tier3"
  pi_storage_config          = local.pi_instance.pi_storage_config
  pi_user_tags               = var.tags
}
