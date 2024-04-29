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
      "enable"               = true
      "server_host_or_ip"    = local.private_svs_ip
      "squid_server_ip"      = local.inet_svs_ip
      "squid_port"           = "3128"
      "squid_server_ip_port" = "${local.inet_svs_ip}:3128"
      "no_proxy_hosts"       = "161.0.0.0/8"
    }

    dns = merge(var.dns_forwarder_config, {
      "enable"            = var.configure_dns_forwarder
      "server_host_or_ip" = local.private_svs_ip
    })

    ntp = {
      "enable"            = var.configure_ntp_forwarder
      "server_host_or_ip" = local.private_svs_ip
    }

    nfs = {
      "enable"            = false
      "server_host_or_ip" = ""
      "nfs_file_system"   = []
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

###########################################
# Locals for VPN config
###########################################

locals {
  default_server_routes = {
    "vpc-vsis" = {
      destination = "10.0.0.0/8"
      action      = "deliver"
    }
  }
  powervs_server_routes = [
    {
      route_name  = "mgmt_net"
      destination = var.powervs_management_network.cidr
      action      = "deliver"
    },
    {
      route_name  = "bkp_net"
      destination = var.powervs_backup_network.cidr
      action      = "deliver"
    }
  ]
  vpn_server_routes = merge(local.default_server_routes, tomap({
    for instance in local.powervs_server_routes :
    instance.route_name => {
      destination = instance.destination
      action      = instance.action
    }
    if !startswith(instance.destination, "10.")
  }))
}
