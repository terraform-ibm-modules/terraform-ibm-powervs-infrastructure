#####################################################
# IBM Cloud Monitoring Instance module
#####################################################

resource "ibm_resource_instance" "monitoring_instance" {
  count             = var.enable_monitoring && var.existing_monitoring_instance_crn == null ? 1 : 0
  provider          = ibm.ibm-is
  name              = "${var.prefix}-monitoring-instance"
  location          = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
  service           = "sysdig-monitor"
  plan              = "graduated-tier"
  resource_group_id = module.landing_zone.resource_group_data["${var.prefix}-slz-service-rg"]
  tags              = var.tags
}

locals {
  monitoring_instance = {
    enable             = var.enable_monitoring
    crn                = var.enable_monitoring && var.existing_monitoring_instance_crn == null ? resource.ibm_resource_instance.monitoring_instance[0].crn : var.existing_monitoring_instance_crn != null ? var.existing_monitoring_instance_crn : ""
    location           = var.enable_monitoring && var.existing_monitoring_instance_crn == null ? resource.ibm_resource_instance.monitoring_instance[0].location : var.existing_monitoring_instance_crn != null ? split(":", var.existing_monitoring_instance_crn)[5] : ""
    guid               = var.enable_monitoring && var.existing_monitoring_instance_crn == null ? resource.ibm_resource_instance.monitoring_instance[0].guid : var.existing_monitoring_instance_crn != null ? split(":", var.existing_monitoring_instance_crn)[7] : ""
    monitoring_host_ip = var.enable_monitoring_host ? local.monitoring_vsi_ip : ""
  }
}

#####################################################
# Configure monitoring VSI
# VSI is created in landing zone preset
#####################################################

module "configure_monitoring_host" {

  source     = "./submodules/ansible"
  depends_on = [module.configure_network_services]
  count      = var.enable_monitoring_host ? 1 : 0

  bastion_host_ip        = local.access_host_or_ip
  ansible_host_or_ip     = local.network_services_vsi_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = false

  src_script_template_name = "configure-monitoring-instance/ansible_exec.sh.tftpl"
  dst_script_file_name     = "monitoring-instance.sh"

  src_playbook_template_name = "configure-monitoring-instance/playbook-configure-monitoring-instance.yml.tftpl"
  dst_playbook_file_name     = "monitoring-instance-playbook.yml"
  playbook_template_vars = {
    "client_config" : jsonencode(
      {
        "nfs" : local.network_services_config.nfs
        "dns" : { enable = var.configure_dns_forwarder, dns_server_ip = local.network_services_vsi_ip }
        "ntp" : { enable = var.configure_ntp_forwarder, ntp_server_ip = local.network_services_vsi_ip }
    })
  }

  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "monitoring-instance-inventory"
  inventory_template_vars     = { "host_or_ip" : local.monitoring_vsi_ip }
}
