#####################################################
# Landing Zone module
#####################################################

module "landing_zone" {
  source    = "terraform-ibm-modules/landing-zone/ibm//patterns//vsi//module"
  version   = "5.20.1"
  providers = { ibm = ibm.ibm-is }

  ssh_public_key       = var.ssh_public_key
  region               = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
  prefix               = var.prefix
  override_json_string = local.override_json_string
}

#####################################################
# PowerVS Workspace Module
#####################################################

module "powervs_infra" {
  source    = "terraform-ibm-modules/powervs-workspace/ibm"
  version   = "1.8.0"
  providers = { ibm = ibm.ibm-pi }

  pi_zone                       = var.powervs_zone
  pi_resource_group_name        = var.powervs_resource_group_name
  pi_workspace_name             = "${var.prefix}-${var.powervs_zone}-power-workspace"
  pi_ssh_public_key             = { "name" = "${var.prefix}-${var.powervs_zone}-pvs-ssh-key", value = var.ssh_public_key }
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
  ansible_host_or_ip = local.inet_svs_ip
  ssh_private_key    = var.ssh_private_key

  src_script_template_name    = "ansible_exec.sh.tftpl"
  dst_script_file_name        = "configure_network_services.sh"
  src_playbook_template_name  = "configure_network_services_playbook.yml.tftpl"
  dst_playbook_file_name      = "configure_network_services_playbook.yml"
  playbook_template_vars      = local.playbook_template_vars
  src_inventory_template_name = "configure_network_services_inventory.tftpl"
  dst_inventory_file_name     = "configure_network_services_inventory"
  inventory_template_vars     = local.inventory_template_vars

}
