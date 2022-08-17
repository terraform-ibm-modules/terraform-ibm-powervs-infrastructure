locals {
  ibm_pvs_zone_region_map = {
    "syd04"    = "syd"
    "syd05"    = "syd"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "lon04"    = "lon"
    "lon06"    = "lon"
    "tok04"    = "tok"
    "us-east"  = "us-east"
    "us-south" = "us-south"
    "dal12"    = "us-south"
    "tor01"    = "tor"
    "osa21"    = "osa"
    "sao01"    = "sao"
  }
}

provider "ibm" {
  region           = lookup(local.ibm_pvs_zone_region_map, var.pvs_zone, null)
  zone             = var.pvs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

data "ibm_schematics_workspace" "schematics_workspace" {
  workspace_id = var.slz_workspace_id
}

data "ibm_schematics_output" "schematics_output" {
  workspace_id = var.slz_workspace_id
  template_id  = data.ibm_schematics_workspace.schematics_workspace.runtime_data[0].id
}

#locals {
#outputMap = jsondecode(data.ibm_schematics_output.schematics_output.output_json)
#}

locals {
  squid_config = {
    "squid_enable"      = var.configure_proxy
    "server_host_or_ip" = "10.30.10.4"
    #data.ibm_schematics_output.schematics_output.output_values.inet-svs.ip
  }
  dns_forwarder_config = merge({
    "dns_enable"        = var.configure_dns_forwarder
    "server_host_or_ip" = "10.20.10.4"
    #data.ibm_schematics_output.schematics_output.output_values.inet-svs.ip
  }, var.dns_config)
  ntp_forwarder_config = {
    "ntp_enable"        = var.configure_ntp_forwarder
    "server_host_or_ip" = "10.20.10.4"
    #data.ibm_schematics_output.schematics_output.output_values.private_svs.ip
  }
  nfs_config = merge({
    "nfs_enable"        = var.configure_nfs_server
    "server_host_or_ip" = "10.20.10.4"
    #data.ibm_schematics_output.schematics_output.output_values.private_svs.ip
  }, var.nfs_config)

  perform_proxy_client_setup = {
    squid_client_ips = ["10.20.10.4"]
    squid_server_ip  = "10.30.10.4"
    no_proxy_env     = "161.0.0.0/8"
  }
}

module "powervs_infra" {
  source = "../.."

  pvs_zone                 = var.pvs_zone
  pvs_resource_group_name  = var.pvs_resource_group_name
  pvs_service_name         = "${data.ibm_schematics_output.schematics_output.output_values.prefix}-power-service"
  tags                     = var.tags
  pvs_sshkey_name          = "${data.ibm_schematics_output.schematics_output.output_values.prefix}-ssh-pvs-key"
  ssh_public_key           = data.ibm_schematics_output.schematics_output.output_values.ssh_public_key
  ssh_private_key          = var.ssh_private_key
  pvs_management_network   = var.pvs_management_network
  pvs_backup_network       = var.pvs_backup_network
  transit_gateway_name     = data.ibm_schematics_output.schematics_output.output_values.transit_gateway_name
  reuse_cloud_connections  = var.reuse_cloud_connections
  cloud_connection_count   = var.cloud_connection_count
  cloud_connection_speed   = var.cloud_connection_speed
  cloud_connection_gr      = var.cloud_connection_gr
  cloud_connection_metered = var.cloud_connection_metered
  access_host_or_ip        = "159.23.100.160"
  #data.ibm_schematics_output.schematics_output.output_values.jump-box.ip
  squid_config               = local.squid_config
  dns_forwarder_config       = local.dns_forwarder_config
  ntp_forwarder_config       = local.ntp_forwarder_config
  nfs_config                 = local.nfs_config
  perform_proxy_client_setup = local.perform_proxy_client_setup
}
