####################################################
# PowerVS with VPC landing zone module
####################################################

module "standard" {
  source = "../../modules/powervs-vpc-landing-zone"

  providers = { ibm.ibm-is = ibm.ibm-is, ibm.ibm-pi = ibm.ibm-pi, ibm.ibm-sm = ibm.ibm-sm }

  powervs_zone                = var.powervs_zone
  prefix                      = var.prefix
  external_access_ip          = var.external_access_ip
  ssh_public_key              = var.ssh_public_key
  ssh_private_key             = var.ssh_private_key
  client_to_site_vpn          = var.client_to_site_vpn
  transit_gateway_global      = var.transit_gateway_global
  configure_dns_forwarder     = var.configure_dns_forwarder
  configure_ntp_forwarder     = var.configure_ntp_forwarder
  configure_nfs_server        = var.configure_nfs_server
  dns_forwarder_config        = var.dns_forwarder_config
  nfs_server_config           = var.nfs_server_config
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_management_network  = var.powervs_management_network
  powervs_backup_network      = var.powervs_backup_network
  powervs_image_names         = var.powervs_image_names
  tags                        = var.tags
  sm_service_plan             = var.sm_service_plan
  existing_sm_instance_guid   = var.existing_sm_instance_guid
  existing_sm_instance_region = var.existing_sm_instance_region
  certificate_template_name   = var.certificate_template_name
}

moved {
  from = module.fullstack
  to   = module.standard
}
