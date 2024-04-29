####################################################
# PowerVS with VPC landing zone module
####################################################

module "fullstack" {
  source = "../../modules/powervs-vpc-landing-zone"

  providers = { ibm.ibm-is = ibm.ibm-is, ibm.ibm-pi = ibm.ibm-pi }

  powervs_zone                = var.powervs_zone
  prefix                      = var.prefix
  external_access_ip          = var.external_access_ip
  ssh_public_key              = var.ssh_public_key
  ssh_private_key             = var.ssh_private_key
  configure_dns_forwarder     = var.configure_dns_forwarder
  configure_ntp_forwarder     = var.configure_ntp_forwarder
  client_to_site_vpn          = var.client_to_site_vpn
  dns_forwarder_config        = var.dns_forwarder_config
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_management_network  = var.powervs_management_network
  powervs_backup_network      = var.powervs_backup_network
  cloud_connection            = var.cloud_connection
  powervs_image_names         = var.powervs_image_names
  tags                        = var.tags
}
