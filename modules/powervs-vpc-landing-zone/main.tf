#####################################################
# VPC Landing Zone module
#####################################################

module "landing_zone" {
  source    = "terraform-ibm-modules/landing-zone/ibm//patterns//vsi//module"
  version   = "5.21.1"
  providers = { ibm = ibm.ibm-is }

  ssh_public_key       = var.ssh_public_key
  region               = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
  prefix               = var.prefix
  override_json_string = local.override_json_string
}

#####################################################
# File share for NFS and application Load Balancer
#####################################################

module "vpc_file_share_alb" {
  source    = "../fileshare-alb"
  providers = { ibm = ibm.ibm-is }
  count     = var.configure_nfs_server ? 1 : 0

  vpc_zone                      = "${lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)}-1"
  resource_group_id             = module.landing_zone.resource_group_data["slz-edge-rg"]
  file_share_name               = "${var.prefix}-file-share-nfs"
  file_share_size               = var.nfs_server_config.size
  file_share_iops               = var.nfs_server_config.iops
  file_share_mount_target_name  = "nfs"
  file_share_subnet_id          = [for subnet in module.landing_zone.subnet_data : subnet.id if subnet.name == "${var.prefix}-edge-vsi-edge-zone-1"][0]
  file_share_security_group_ids = [for security_group in module.landing_zone.vpc_data[0].vpc_data.security_group : security_group.group_id if security_group.group_name == "network-services-sg"]
  alb_name                      = "${var.prefix}-file-share-alb"
  alb_subnet_ids                = [for subnet in module.landing_zone.subnet_data : subnet.id if subnet.name == "${var.prefix}-edge-vsi-edge-zone-1"]
  alb_security_group_ids        = [for security_group in module.landing_zone.vpc_data[0].vpc_data.security_group : security_group.group_id if security_group.group_name == "network-services-sg"]

}

#####################################################
# PowerVS Workspace Module
#####################################################

module "powervs_infra" {
  source    = "terraform-ibm-modules/powervs-workspace/ibm"
  version   = "1.13.0"
  providers = { ibm = ibm.ibm-pi }

  pi_zone                       = var.powervs_zone
  pi_resource_group_name        = var.powervs_resource_group_name
  pi_workspace_name             = "${var.prefix}-${var.powervs_zone}-power-workspace"
  pi_ssh_public_key             = { "name" = "${var.prefix}-${var.powervs_zone}-pcs-ssh-key", value = var.ssh_public_key }
  pi_cloud_connection           = var.cloud_connection
  pi_private_subnet_1           = var.powervs_management_network
  pi_private_subnet_2           = var.powervs_backup_network
  pi_transit_gateway_connection = { "enable" : true, "transit_gateway_id" : module.landing_zone.transit_gateway_data.id }
  pi_tags                       = var.tags
  pi_image_names                = var.powervs_image_names
}


#####################################################
# Ansible Host module setup and execution
#####################################################

module "configure_network_services" {
  source = "../ansible"

  bastion_host_ip    = local.access_host_or_ip
  ansible_host_or_ip = local.network_services_ip
  ssh_private_key    = var.ssh_private_key

  src_script_template_name   = "ansible_exec.sh.tftpl"
  dst_script_file_name       = "configure_network_services.sh"
  src_playbook_template_name = "configure_network_services_playbook.yml.tftpl"
  dst_playbook_file_name     = "configure_network_services_playbook.yml"
  playbook_template_vars     = local.playbook_template_vars
}
