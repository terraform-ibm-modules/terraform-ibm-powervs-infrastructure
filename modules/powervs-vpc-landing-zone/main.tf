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
      user_data                    = var.user_data != null ? replace(var.user_data, "\n", "\\n") : null
      transit_gateway_global       = var.transit_gateway_global,
      enable_monitoring_host       = var.enable_monitoring_host,
      sles_image                   = var.vpc_intel_images.sles_image,
      second_rg_name               = local.second_rg_name,
      tgw_rg_name                  = local.tgw_rg_name
      vpc_subnet_cidrs             = var.vpc_subnet_cidrs
      powervs_mgmt_cidr            = var.powervs_management_network != null ? var.powervs_management_network.cidr : null
      powervs_bckp_cidr            = var.powervs_backup_network != null ? var.powervs_backup_network.cidr : null
      vpn_client_cidr              = var.client_to_site_vpn.enable ? var.client_to_site_vpn.client_ip_pool : null
    }
  )
}


module "landing_zone" {
  source    = "terraform-ibm-modules/landing-zone/ibm//patterns//vsi//module"
  version   = "8.7.1"
  providers = { ibm = ibm.ibm-is }

  ssh_public_key       = var.ssh_public_key
  region               = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
  prefix               = var.prefix
  override_json_string = local.override_json_string
}


# ###########################################################
# # Routing table used by NLB for NFS and VPN
# ###########################################################

resource "ibm_is_vpc_routing_table" "routing_table" {
  provider = ibm.ibm-is
  count    = var.configure_nfs_server || var.client_to_site_vpn.enable ? 1 : 0

  name                             = "${var.prefix}-routing"
  vpc                              = [for vpc in module.landing_zone.vpc_data : vpc.vpc_id if vpc.vpc_name == "${var.prefix}-edge"][0]
  route_transit_gateway_ingress    = true
  accept_routes_from_resource_type = var.client_to_site_vpn.enable ? ["vpn_server"] : []
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
      "nfs_server_path" = var.configure_nfs_server ? ibm_is_share_mount_target.mount_target_nfs[0].mount_path : ""
      "nfs_client_path" = var.configure_nfs_server ? var.nfs_server_config.mount_path : ""
      "opts"            = "sec=sys,nfsvers=4.1,nofail"
      "fstype"          = "nfs4"
    }
  }
}


module "configure_network_services" {

  source     = "./submodules/ansible"
  depends_on = [ibm_is_share_mount_target.mount_target_nfs]

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
