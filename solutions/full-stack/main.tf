####################################################
# PowerVS with VPC landing zone module
####################################################

module "fullstack" {
  source = "../../modules/powervs-vpc-landing-zone"

  providers = { ibm.ibm-is = ibm.ibm-is, ibm.ibm-pi = ibm.ibm-pi }

  powervs_zone                = var.powervs_zone
  landing_zone_configuration  = var.landing_zone_configuration
  prefix                      = var.prefix
  external_access_ip          = var.external_access_ip
  ssh_public_key              = var.ssh_public_key
  ssh_private_key             = var.ssh_private_key
  client_to_site_vpn          = var.client_to_site_vpn
  configure_dns_forwarder     = var.configure_dns_forwarder
  configure_ntp_forwarder     = var.configure_ntp_forwarder
  configure_nfs_server        = var.configure_nfs_server
  dns_forwarder_config        = var.dns_forwarder_config
  nfs_server_config           = var.nfs_server_config
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_management_network  = var.powervs_management_network
  powervs_backup_network      = var.powervs_backup_network
  cloud_connection            = var.cloud_connection
  powervs_image_names         = var.powervs_image_names
  tags                        = var.tags
}

moved {
  from = module.landing_zone
  to   = module.fullstack.module.landing_zone
}

moved {
  from = module.powervs_infra
  to   = module.fullstack.module.powervs_infra
}
