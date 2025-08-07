#####################################################
# VPC Landing Zone module
#####################################################
locals {

  external_access_ip = var.external_access_ip != null && var.external_access_ip != "" ? length(regexall("/", var.external_access_ip)) > 0 ? var.external_access_ip : "${var.external_access_ip}/32" : ""
  # Openshift IPI requires VPC resources, PowerVS resources, and TGW to be in the same resource group
  second_rg_name = var.powervs_resource_group_name != null ? "slz-edge-rg" : "ocp-rg"
  tgw_rg_name    = var.powervs_resource_group_name != null ? "slz-service-rg" : "ocp-rg"
  override_json_string = templatefile("${path.module}/presets/slz-preset.json.tftpl",
    {
      external_access_ip           = local.external_access_ip,
      rhel_image                   = var.vpc_intel_images.rhel_image,
      network_services_vsi_profile = var.network_services_vsi_profile,
      transit_gateway_global       = var.transit_gateway_global,
      enable_monitoring            = var.enable_monitoring,
      sles_image                   = var.vpc_intel_images.sles_image,
      second_rg_name               = local.second_rg_name,
      tgw_rg_name                  = local.tgw_rg_name
    }
  )
}

module "landing_zone" {
  source    = "terraform-ibm-modules/landing-zone/ibm//patterns//vsi//module"
  version   = "8.4.3"
  providers = { ibm = ibm.ibm-is }

  ssh_public_key       = var.ssh_public_key
  region               = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
  prefix               = var.prefix
  override_json_string = local.override_json_string
}

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
    monitoring_host_ip = local.monitoring_vsi_ip
  }
}

#################################################
# SCC Workload Protection Instance module
#################################################

# Create new App Config instance
module "app_config" {
  source    = "terraform-ibm-modules/app-configuration/ibm"
  version   = "1.8.12"
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
  version   = "1.10.13"
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

###########################################################
# File share for NFS and Application Load Balancer module
###########################################################

module "vpc_file_share_alb" {
  source    = "./submodules/fileshare-alb"
  providers = { ibm = ibm.ibm-is }
  count     = var.configure_nfs_server ? 1 : 0

  vpc_zone                      = "${lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)}-1"
  resource_group_id             = module.landing_zone.resource_group_data["${var.prefix}-${local.second_rg_name}"]
  file_share_name               = "${var.prefix}-file-share-nfs"
  file_share_size               = var.nfs_server_config.size
  file_share_iops               = var.nfs_server_config.iops
  file_share_mount_target_name  = "${var.prefix}-nfs"
  file_share_subnet_id          = [for subnet in module.landing_zone.subnet_data : subnet.id if subnet.name == "${var.prefix}-edge-vsi-edge-zone-1"][0]
  file_share_security_group_ids = [for security_group in module.landing_zone.vpc_data[0].vpc_data.security_group : security_group.group_id if security_group.group_name == "network-services-sg"]
  alb_name                      = "${var.prefix}-file-share-alb"
  alb_subnet_ids                = [for subnet in module.landing_zone.subnet_data : subnet.id if subnet.name == "${var.prefix}-edge-vsi-edge-zone-1"]
  alb_security_group_ids        = [for security_group in module.landing_zone.vpc_data[0].vpc_data.security_group : security_group.group_id if security_group.group_name == "network-services-sg"]

}

###########################################################
# PowerVS Workspace module
###########################################################

locals {
  powervs_custom_image1 = (
    var.powervs_custom_images.powervs_custom_image1.image_name == "" &&
    var.powervs_custom_images.powervs_custom_image1.file_name == "" &&
    var.powervs_custom_images.powervs_custom_image1.storage_tier == ""
  ) ? null : var.powervs_custom_images.powervs_custom_image1
  powervs_custom_image2 = (
    var.powervs_custom_images.powervs_custom_image2.image_name == "" &&
    var.powervs_custom_images.powervs_custom_image2.file_name == "" &&
    var.powervs_custom_images.powervs_custom_image2.storage_tier == ""
  ) ? null : var.powervs_custom_images.powervs_custom_image2
  powervs_custom_image3 = (
    var.powervs_custom_images.powervs_custom_image3.image_name == "" &&
    var.powervs_custom_images.powervs_custom_image3.file_name == "" &&
    var.powervs_custom_images.powervs_custom_image3.storage_tier == ""
  ) ? null : var.powervs_custom_images.powervs_custom_image3
  powervs_custom_image_cos_configuration = (
    var.powervs_custom_image_cos_configuration.bucket_name == "" &&
    var.powervs_custom_image_cos_configuration.bucket_access == "" &&
    var.powervs_custom_image_cos_configuration.bucket_region == ""
  ) ? null : var.powervs_custom_image_cos_configuration
}

module "powervs_workspace" {
  source  = "terraform-ibm-modules/powervs-workspace/ibm"
  version = "3.2.0"

  providers = { ibm = ibm.ibm-pi }

  pi_zone                                 = var.powervs_zone
  pi_resource_group_name                  = var.powervs_resource_group_name != null ? var.powervs_resource_group_name : null
  pi_resource_group_id                    = var.powervs_resource_group_name != null ? null : module.landing_zone.resource_group_data["${var.prefix}-${local.second_rg_name}"]
  pi_workspace_name                       = "${var.prefix}-${var.powervs_zone}-power-workspace"
  pi_ssh_public_key                       = { "name" = "${var.prefix}-${var.powervs_zone}-pvs-ssh-key", value = var.ssh_public_key }
  pi_private_subnet_1                     = var.powervs_management_network
  pi_private_subnet_2                     = var.powervs_backup_network
  pi_transit_gateway_connection           = { "enable" : true, "transit_gateway_id" : module.landing_zone.transit_gateway_data.id }
  pi_tags                                 = var.tags
  pi_custom_image1                        = local.powervs_custom_image1
  pi_custom_image2                        = local.powervs_custom_image2
  pi_custom_image3                        = local.powervs_custom_image3
  pi_custom_image_cos_configuration       = local.powervs_custom_image_cos_configuration
  pi_custom_image_cos_service_credentials = var.powervs_custom_image_cos_service_credentials
}


###########################################################
# Ansible Host setup and execution module
###########################################################

locals {
  network_services_config = {
    squid = {
      "enable"     = true
      "squid_port" = "3128"
    }
    dns = merge(var.dns_forwarder_config, {
      "enable" = var.configure_dns_forwarder
    })
    ntp = {
      "enable" = var.configure_ntp_forwarder
    }
    nfs = {
      "enable"          = var.configure_nfs_server
      "nfs_server_path" = var.configure_nfs_server ? module.vpc_file_share_alb[0].nfs_host_or_ip_path : ""
      "nfs_client_path" = var.configure_nfs_server ? var.nfs_server_config.mount_path : ""
      "opts"            = "sec=sys,nfsvers=4.1,nofail"
      "fstype"          = "nfs4"
    }
  }

}

module "configure_network_services" {

  source     = "./submodules/ansible"
  depends_on = [module.vpc_file_share_alb]

  bastion_host_ip        = local.access_host_or_ip
  ansible_host_or_ip     = local.network_services_vsi_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = true

  src_script_template_name = "configure-network-services/ansible_exec.sh.tftpl"
  dst_script_file_name     = "network-services-instance.sh"

  src_playbook_template_name = "configure-network-services/playbook-configure-network-services.yml.tftpl"
  dst_playbook_file_name     = "network-services-instance-playbook.yml"
  playbook_template_vars = {
    "server_config" : jsonencode(
      { "squid" : local.network_services_config.squid,
        "dns" : local.network_services_config.dns,
        "ntp" : local.network_services_config.ntp
    }),
    "client_config" : jsonencode(
      { "nfs" : local.network_services_config.nfs
    })
  }

  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "network-services-instance-inventory"
  inventory_template_vars     = { "host_or_ip" : local.network_services_vsi_ip }
}


module "configure_monitoring_host" {

  source     = "./submodules/ansible"
  depends_on = [module.configure_network_services]
  count      = var.enable_monitoring ? 1 : 0

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
