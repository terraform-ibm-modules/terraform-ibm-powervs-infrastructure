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
    "mon01"    = "mon"
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

locals {
  slz_output = jsondecode(data.ibm_schematics_output.schematics_output.output_json)

  inet_svs_ip    = [for vsi in local.slz_output[0].vsi_list.value : vsi.ipv4_address if vsi.name == "${local.slz_output[0].prefix.value}-inet-svs-1"][0]
  private_svs_ip = [for vsi in local.slz_output[0].vsi_list.value : vsi.ipv4_address if vsi.name == "${local.slz_output[0].prefix.value}-private-svs-1"][0]
}

locals {
  squid_config = {
    "squid_enable"      = var.configure_proxy
    "server_host_or_ip" = var.squid_config["server_host_or_ip"] != null && var.squid_config["server_host_or_ip"] != "" ? var.squid_config["server_host_or_ip"] : local.inet_svs_ip
  }

  dns_config = merge(var.dns_config, {
    "dns_enable"        = var.configure_dns_forwarder
    "server_host_or_ip" = var.dns_config["server_host_or_ip"] != null && var.dns_config["server_host_or_ip"] != "" ? var.dns_config["server_host_or_ip"] : local.private_svs_ip
  })

  ntp_config = {
    "ntp_enable"        = var.configure_ntp_forwarder
    "server_host_or_ip" = var.ntp_config["server_host_or_ip"] != null && var.ntp_config["server_host_or_ip"] != "" ? var.ntp_config["server_host_or_ip"] : local.private_svs_ip
  }

  nfs_config = merge(var.nfs_config, {
    "nfs_enable"        = var.configure_nfs_server
    "server_host_or_ip" = var.nfs_config["server_host_or_ip"] != null && var.nfs_config["server_host_or_ip"] != "" ? var.nfs_config["server_host_or_ip"] : local.private_svs_ip
  })

  perform_proxy_client_setup = {
    squid_client_ips = [local.private_svs_ip]
    squid_server_ip  = local.inet_svs_ip
    no_proxy_env     = "161.0.0.0/8"
  }
}

module "powervs_infra" {
  source = "../.."

  pvs_zone                   = var.pvs_zone
  pvs_resource_group_name    = var.pvs_resource_group_name
  pvs_service_name           = "${local.slz_output[0].prefix.value}-power-service"
  tags                       = var.tags
  pvs_sshkey_name            = "${local.slz_output[0].prefix.value}-ssh-pvs-key"
  ssh_public_key             = local.slz_output[0].ssh_public_key.value
  ssh_private_key            = var.ssh_private_key
  pvs_management_network     = var.pvs_management_network
  pvs_backup_network         = var.pvs_backup_network
  transit_gateway_name       = local.slz_output[0].transit_gateway_name.value
  reuse_cloud_connections    = var.reuse_cloud_connections
  cloud_connection_count     = var.cloud_connection_count
  cloud_connection_speed     = var.cloud_connection_speed
  cloud_connection_gr        = var.cloud_connection_gr
  cloud_connection_metered   = var.cloud_connection_metered
  access_host_or_ip          = local.slz_output[0].fip_vsi.value[0].floating_ip
  squid_config               = local.squid_config
  dns_forwarder_config       = local.dns_config
  ntp_forwarder_config       = local.ntp_config
  nfs_config                 = local.nfs_config
  perform_proxy_client_setup = local.perform_proxy_client_setup
}
