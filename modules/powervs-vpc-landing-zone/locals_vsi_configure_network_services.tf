#####################################################
# VPC VSI Management Services OS configuration
#####################################################

locals {

  network_services_config = {

    squid = {
      "enable"            = true
      "server_host_or_ip" = local.inet_svs_ip
      "squid_port"        = "3128"
    }

    proxy_client = {
      "enable"               = local.private_svs_vsi_exists ? true : false
      "server_host_or_ip"    = local.private_svs_vsi_exists ? local.private_svs_ip : ""
      "squid_server_ip"      = local.inet_svs_ip
      "squid_port"           = "3128"
      "squid_server_ip_port" = "${local.inet_svs_ip}:3128"
      "no_proxy_hosts"       = "161.0.0.0/8"
    }

    dns = merge(var.dns_forwarder_config, {
      "enable"            = var.configure_dns_forwarder
      "server_host_or_ip" = local.private_svs_vsi_exists ? local.private_svs_ip : local.inet_svs_ip
    })

    ntp = {
      "enable"            = var.configure_ntp_forwarder
      "server_host_or_ip" = local.private_svs_vsi_exists ? local.private_svs_ip : local.inet_svs_ip
    }

    nfs = {
      "enable"            = local.nfs_enable ? true : false
      "server_host_or_ip" = local.private_svs_vsi_exists ? local.private_svs_ip : local.inet_svs_ip
      "nfs_file_system"   = [{ name = "nfsn", mount_path = local.nfs_enable ? var.nfs_server_config.mount_path : "", size = local.nfs_enable ? var.nfs_server_config.size : "" }]
    }
  }

  playbook_template_vars = {
    "squid_config" : jsonencode({ "squid" : local.network_services_config.squid }),
    "proxy_client_config" : jsonencode({ "squid" : local.network_services_config.proxy_client }),
    "dns_config" : jsonencode({ "dns" : local.network_services_config.dns }),
    "ntp_config" : jsonencode({ "ntp" : local.network_services_config.ntp }),
    "nfs_config" : jsonencode({ "nfs" : local.network_services_config.nfs }),
  }

  inventory_template_vars = { "squid_host" : local.network_services_config.squid.server_host_or_ip,
    "proxy_client_host" : local.network_services_config.proxy_client.server_host_or_ip,
    "dns_host" : local.network_services_config.dns.server_host_or_ip,
    "ntp_host" : local.network_services_config.ntp.server_host_or_ip,
    "nfs_host" : local.network_services_config.nfs.server_host_or_ip,
  }
}
