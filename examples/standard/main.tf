locals {
  ibm_powervs_zone_region_map = {
    "syd04"    = "syd"
    "syd05"    = "syd"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "lon04"    = "lon"
    "lon06"    = "lon"
    "wdc04"    = "us-east"
    "us-east"  = "us-east"
    "us-south" = "us-south"
    "dal12"    = "us-south"
    "dal13"    = "us-south"
    "tor01"    = "tor"
    "tok04"    = "tok"
    "osa21"    = "osa"
    "sao01"    = "sao"
    "mon01"    = "mon"

  }
}

provider "ibm" {
  region           = lookup(local.ibm_powervs_zone_region_map, var.powervs_zone, null)
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

locals {
  squid_port = "3128"
}

locals {
  squid_config = {
    "squid_enable"      = var.configure_proxy
    "server_host_or_ip" = var.squid_config["server_host_or_ip"] != null && var.squid_config["server_host_or_ip"] != "" ? var.squid_config["server_host_or_ip"] : var.internet_services_host_or_ip
    "squid_port"        = var.squid_config["squid_port"] != null && var.squid_config["squid_port"] != "" ? var.squid_config["squid_port"] : local.squid_port
  }

  dns_config = merge(var.dns_forwarder_config, {
    "dns_enable"        = var.configure_dns_forwarder
    "server_host_or_ip" = var.dns_forwarder_config["server_host_or_ip"] != null && var.dns_forwarder_config["server_host_or_ip"] != "" ? var.dns_forwarder_config["server_host_or_ip"] : var.private_services_host_or_ip
  })

  ntp_config = {
    "ntp_enable"        = var.configure_ntp_forwarder
    "server_host_or_ip" = var.ntp_forwarder_config["server_host_or_ip"] != null && var.ntp_forwarder_config["server_host_or_ip"] != "" ? var.ntp_forwarder_config["server_host_or_ip"] : var.private_services_host_or_ip
  }

  nfs_config = merge(var.nfs_config, {
    "nfs_enable"        = var.configure_nfs_server
    "server_host_or_ip" = var.nfs_config["server_host_or_ip"] != null && var.nfs_config["server_host_or_ip"] != "" ? var.nfs_config["server_host_or_ip"] : var.private_services_host_or_ip
  })

  host_ips         = [local.dns_config["server_host_or_ip"], local.ntp_config["server_host_or_ip"], local.nfs_config["server_host_or_ip"]]
  squid_client_ips = distinct([for host_ip in local.host_ips : host_ip if host_ip != local.squid_config["server_host_or_ip"]])

  perform_proxy_client_setup = {
    squid_client_ips = local.squid_client_ips
    squid_server_ip  = local.squid_config["server_host_or_ip"]
    squid_port       = local.squid_config["squid_port"]
    no_proxy_hosts   = "161.0.0.0/8"
  }
}

module "powervs_infra" {
  source = "../../"

  powervs_zone                = var.powervs_zone
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_workspace_name      = "${var.prefix}-${var.powervs_zone}-power-workspace"
  tags                        = var.tags
  powervs_image_names         = var.powervs_image_names
  powervs_sshkey_name         = "${var.prefix}-${var.powervs_zone}-ssh-pvs-key"
  ssh_public_key              = var.ssh_public_key
  ssh_private_key             = var.ssh_private_key
  powervs_management_network  = var.powervs_management_network
  powervs_backup_network      = var.powervs_backup_network
  transit_gateway_name        = var.transit_gateway_name
  reuse_cloud_connections     = var.reuse_cloud_connections
  cloud_connection_count      = var.cloud_connection_count
  cloud_connection_speed      = var.cloud_connection_speed
  cloud_connection_gr         = var.cloud_connection_gr
  cloud_connection_metered    = var.cloud_connection_metered
  access_host_or_ip           = var.access_host_or_ip
  squid_config                = local.squid_config
  dns_forwarder_config        = local.dns_config
  ntp_forwarder_config        = local.ntp_config
  nfs_config                  = local.nfs_config
  perform_proxy_client_setup  = local.perform_proxy_client_setup
}
