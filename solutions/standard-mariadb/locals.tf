#####################################################
# PowerVS Instance module
#####################################################

locals {
  p10_unsupported_regions = ["che01", "us-east"]
  server_type             = contains(local.p10_unsupported_regions, var.powervs_zone) ? "s922" : "s1022"

  ibm_powervs_mariadb_tshirt_sizes = {
    "mariadb_dev" = { "server_type" = local.server_type, "proc_type" = "shared", "cores" = "0.25", "memory" = "4", "storage" = "50", "tier" = "tier3", "image" = var.tshirt_size.image }
    "mariadb_s"   = { "server_type" = local.server_type, "proc_type" = "shared", "cores" = "1", "memory" = "8", "storage" = "100", "tier" = "tier3", "image" = var.tshirt_size.image }
    "mariadb_m"   = { "server_type" = local.server_type, "proc_type" = "shared", "cores" = "2", "memory" = "16", "storage" = "250", "tier" = "tier3", "image" = var.tshirt_size.image }
    "mariadb_l"   = { "server_type" = local.server_type, "proc_type" = "shared", "cores" = "4", "memory" = "32", "storage" = "500", "tier" = "tier3", "image" = var.tshirt_size.image }
    "custom"      = { "server_type" = var.custom_profile.server_type, "proc_type" = var.custom_profile.proc_type, "cores" = var.custom_profile.cores, "memory" = var.custom_profile.memory, "storage" = var.custom_profile.storage.size, "tier" = var.custom_profile.storage.tier, "image" = var.tshirt_size.image }
  }

  qs_tshirt_choice = lookup(local.ibm_powervs_mariadb_tshirt_sizes, var.tshirt_size.tshirt_size, local.ibm_powervs_mariadb_tshirt_sizes["mariadb_s"])

  # Calculate 80% and 50% RAM for InnoDB buffer pool
  mem_total_mb                = tonumber(local.qs_tshirt_choice.memory) * 1024
  innodb_buffer_pool_size     = "${floor(local.mem_total_mb * 0.80)}M"
  innodb_buffer_pool_size_min = "${floor(local.mem_total_mb * 0.50)}M"

  pi_instance_os_type = can(regex("RHEL|SLES", local.qs_tshirt_choice.image)) ? "linux" : can(regex("^7\\d{3}-\\d{2}-\\d{2}$", local.qs_tshirt_choice.image)) ? "aix" : "ibm_i"

  pi_instance = {
    pi_image_id             = local.qs_tshirt_choice.image
    pi_networks             = concat([module.standard.powervs_management_subnet], module.standard.powervs_backup_subnet != null ? [module.standard.powervs_backup_subnet] : [])
    pi_instance_name        = "${var.prefix}-mariadb-pvs"
    pi_sap_profile_id       = null
    pi_server_type          = local.qs_tshirt_choice.server_type
    pi_number_of_processors = local.qs_tshirt_choice.cores
    pi_memory_size          = local.qs_tshirt_choice.memory
    pi_cpu_proc_type        = local.qs_tshirt_choice.proc_type
    pi_storage_config = [
      {
        name   = "mariadbdata"
        size   = local.qs_tshirt_choice.storage
        count  = "1"
        tier   = local.qs_tshirt_choice.tier
        mount  = "/var/lib/mysql"
        fstype = "xfs"
      }
    ]
  }

  network_services_config = {
    squid = { enable = true, squid_server_ip_port = module.standard.proxy_host_or_ip_port, no_proxy_hosts = "161.0.0.0/8,${var.vpc_subnet_cidrs.vpn},${var.vpc_subnet_cidrs.mgmt},${var.vpc_subnet_cidrs.vpe},${var.vpc_subnet_cidrs.edge},${var.powervs_management_network != null ? "${var.powervs_management_network.cidr}," : ""}${var.powervs_backup_network != null ? "${var.powervs_backup_network.cidr}," : ""}${var.client_to_site_vpn.client_ip_pool}" }
    nfs   = { enable = var.configure_nfs_server, nfs_server_path = module.standard.nfs_host_or_ip_path, nfs_client_path = lookup(var.nfs_server_config, "mount_path", ""), opts = "sec=sys,nfsvers=4.1,nofail", fstype = "nfs4" }
    dns   = { enable = var.configure_dns_forwarder, dns_server_ip = module.standard.dns_host_or_ip }
    ntp   = { enable = var.configure_ntp_forwarder, ntp_server_ip = module.standard.ntp_host_or_ip }
  }
}
