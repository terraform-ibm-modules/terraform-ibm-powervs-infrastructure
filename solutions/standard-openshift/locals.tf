locals {
  cluster_dir = "/root/ocp-powervs-deploy"
  powervs_server_routes = [
    {
      route_name  = "cluster-network"
      destination = var.cluster_network_config.cluster_network_cidr
      action      = "deliver"
    },
    {
      route_name  = "cluster-service-network"
      destination = var.cluster_network_config.cluster_service_network_cidr
      action      = "deliver"
    }
  ]
  client_to_site_vpn = merge(var.client_to_site_vpn, { "powervs_server_routes" : local.powervs_server_routes })

  tshirt_sizes = {
    "xs" = {
      "master_node_config" = {
        "processors" = "1",
        "memory"     = "32",
        "proc_type"  = "Shared",
        "replicas"   = "3"
      },
      "worker_node_config" = {
        "processors" = "1",
        "memory"     = "32",
        "proc_type"  = "Shared",
        "replicas"   = "2"
      },
    }
    "s" = {
      "master_node_config" = {
        "processors" = "1",
        "memory"     = "32",
        "proc_type"  = "Shared",
        "replicas"   = "3"
      },
      "worker_node_config" = {
        "processors" = "1",
        "memory"     = "32",
        "proc_type"  = "Shared",
        "replicas"   = "3"
      },
    }
    "m" = {
      "master_node_config" = {
        "processors" = "1",
        "memory"     = "32",
        "proc_type"  = "Shared",
        "replicas"   = "3"
      },
      "worker_node_config" = {
        "processors" = "2",
        "memory"     = "32",
        "proc_type"  = "Shared",
        "replicas"   = "4"
      },
    }
    "l" = {
      "master_node_config" = {
        "processors" = "1",
        "memory"     = "32",
        "proc_type"  = "Shared",
        "replicas"   = "3"
      },
      "worker_node_config" = {
        "processors" = "2",
        "memory"     = "64",
        "proc_type"  = "Shared",
        "replicas"   = "4"
      },
    }
  }

  # set node configs based on whether t shirt was selected or custom config is being used
  use_tshirt             = var.tshirt_size != "custom"
  tmp_master_node_config = local.use_tshirt ? lookup(lookup(local.tshirt_sizes, var.tshirt_size, null), "master_node_config", null) : var.custom_master_node_config
  tmp_worker_node_config = local.use_tshirt ? lookup(lookup(local.tshirt_sizes, var.tshirt_size, null), "worker_node_config", null) : var.custom_worker_node_config

  # automatically pick the supported system type unless it's overwritten by the user
  p10_unsupported_regions    = ["che01", "lon04", "mon01", "syd04", "syd05", "tor01", "us-east"] # datacenters that don't support P10 yet
  system_type                = contains(local.p10_unsupported_regions, var.powervs_zone) ? "s922" : "s1022"
  cluster_master_node_config = lookup(local.tmp_master_node_config, "system_type", null) != null ? local.tmp_master_node_config : merge(local.tmp_master_node_config, { system_type : local.system_type })
  cluster_worker_node_config = lookup(local.tmp_worker_node_config, "system_type", null) != null ? local.tmp_worker_node_config : merge(local.tmp_worker_node_config, { system_type : local.system_type })
}
