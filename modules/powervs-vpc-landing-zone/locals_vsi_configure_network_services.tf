#####################################################
# VPC VSI Management Services OS configuration
#####################################################

locals {

  squid_config = {
    squid = {
      "enable"            = true
      "server_host_or_ip" = local.inet_svs_ip
      "squid_port"        = "3128"
    }
  }

  # Proxy client will be configured on "${var.prefix}-private-svs-1" vsi if exists
  perform_proxy_client_setup = {
    squid_client_ips = local.private_svs_vsi_exists ? [local.private_svs_ip] : []
    squid_server_ip  = local.inet_svs_ip
    squid_port       = local.squid_config.squid.squid_port
    no_proxy_hosts   = "161.0.0.0/8"
  }

  network_services_config = {
    squid = {
      "enable"            = local.private_svs_vsi_exists ? false : true
      "server_host_or_ip" = local.inet_svs_ip
      "squid_port"        = "3128"
    }

    ntp = {
      "enable"            = var.configure_ntp_forwarder
      "server_host_or_ip" = local.private_svs_vsi_exists ? local.private_svs_ip : local.inet_svs_ip
    }

    dns = merge(var.dns_forwarder_config, {
      "enable"            = var.configure_dns_forwarder
      "server_host_or_ip" = local.private_svs_vsi_exists ? local.private_svs_ip : local.inet_svs_ip
    })

    nfs = {
      "enable"            = local.nfs_enable ? true : false
      "server_host_or_ip" = local.private_svs_vsi_exists ? local.private_svs_ip : local.inet_svs_ip
      "nfs_file_system"   = [{ name = "nfsn", mount_path = local.nfs_enable ? var.nfs_server_config.mount_path : "", size = local.nfs_enable ? var.nfs_server_config.size : "" }]
    }
  }

}
