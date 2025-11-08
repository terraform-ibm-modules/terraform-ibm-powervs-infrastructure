#################################################
# SCC Workload Protection Instance module
#################################################

# Create new App Config instance
module "app_config" {
  source    = "terraform-ibm-modules/app-configuration/ibm"
  version   = "1.14.0"
  providers = { ibm = ibm.ibm-is }
  count     = var.enable_scc_wp ? 1 : 0

  region                                 = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
  resource_group_id                      = module.landing_zone.resource_group_data["${var.prefix}-slz-service-rg"]
  app_config_plan                        = "basic"
  app_config_name                        = "${var.prefix}-app-config"
  app_config_tags                        = var.tags
  enable_config_aggregator               = true
  config_aggregator_trusted_profile_name = "${var.prefix}-app-config-tp"
}

module "scc_wp_instance" {
  source    = "terraform-ibm-modules/scc-workload-protection/ibm"
  version   = "1.16.0"
  providers = { ibm = ibm.ibm-is }
  count     = var.enable_scc_wp ? 1 : 0

  name                                         = "${var.prefix}-scc-wp-instance"
  region                                       = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
  resource_group_id                            = module.landing_zone.resource_group_data["${var.prefix}-slz-service-rg"]
  scc_wp_service_plan                          = "graduated-tier"
  scc_workload_protection_trusted_profile_name = "${var.prefix}-workload-protection-trusted-profile"
  resource_tags                                = var.tags
  resource_key_name                            = "${var.prefix}-scc-wp-manager-key"
  resource_key_tags                            = var.tags
  cloud_monitoring_instance_crn                = local.monitoring_instance.crn != "" ? local.monitoring_instance.crn : null
  app_config_crn                               = var.enable_scc_wp ? module.app_config[0].app_config_crn : null
}

locals {
  scc_wp_instance = {
    enable             = var.enable_scc_wp
    guid               = var.enable_scc_wp ? module.scc_wp_instance[0].guid : "",
    access_key         = var.enable_scc_wp ? nonsensitive(module.scc_wp_instance[0].access_key) : "",
    api_endpoint       = var.enable_scc_wp ? nonsensitive(replace(module.scc_wp_instance[0].api_endpoint, "https://", "https://private.")) : "",
    ingestion_endpoint = var.enable_scc_wp ? nonsensitive(replace(module.scc_wp_instance[0].ingestion_endpoint, "ingest.", "ingest.private.")) : ""
  }
}


module "configure_scc_wp_agent" {

  source     = "./submodules/ansible"
  depends_on = [module.configure_network_services, module.configure_monitoring_host]
  count      = var.enable_scc_wp ? 1 : 0

  bastion_host_ip        = local.access_host_or_ip
  ansible_host_or_ip     = local.network_services_vsi_ip
  ssh_private_key        = var.ssh_private_key
  ansible_vault_password = var.ansible_vault_password
  configure_ansible_host = false

  src_script_template_name = "configure-scc-wp-agent/ansible_configure_scc_wp_agent.sh.tftpl"
  dst_script_file_name     = "${var.prefix}-configure_scc_wp_agent.sh"

  src_playbook_template_name = "configure-scc-wp-agent/playbook-configure-scc-wp-agent-linux.yml.tftpl"
  dst_playbook_file_name     = "${var.prefix}-playbook-configure-scc-wp-agent.yml"
  playbook_template_vars = {
    COLLECTOR_ENDPOINT : local.scc_wp_instance.ingestion_endpoint,
    API_ENDPOINT : local.scc_wp_instance.api_endpoint,
    ACCESS_KEY : local.scc_wp_instance.access_key
  }
  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "${var.prefix}-scc-wp-inventory"
  inventory_template_vars     = { "host_or_ip" : join("\n", [for vsi in module.landing_zone.vsi_list : vsi["ipv4_address"]]) }
}
