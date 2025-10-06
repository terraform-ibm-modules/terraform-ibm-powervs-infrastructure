#####################################################
# PowerVS with VPC landing zone module
#####################################################

locals {
  powervs_server_routes = [
    {
      route_name  = var.powervs_management_network.name
      destination = var.powervs_management_network.cidr
      action      = "deliver"
    },
    {
      route_name  = var.powervs_backup_network.name
      destination = var.powervs_backup_network.cidr
      action      = "deliver"
    }
  ]
  client_to_site_vpn = merge(var.client_to_site_vpn, { "powervs_server_routes" : local.powervs_server_routes })
}

module "standard" {
  source = "../../modules/powervs-vpc-landing-zone"

  providers = { ibm.ibm-is = ibm.ibm-is, ibm.ibm-pi = ibm.ibm-pi, ibm.ibm-sm = ibm.ibm-sm }

  powervs_zone                     = var.powervs_zone
  prefix                           = var.prefix
  external_access_ip               = var.external_access_ip
  ssh_public_key                   = var.ssh_public_key
  ssh_private_key                  = var.ssh_private_key
  client_to_site_vpn               = local.client_to_site_vpn
  vpc_intel_images                 = var.vpc_intel_images
  configure_dns_forwarder          = var.configure_dns_forwarder
  configure_ntp_forwarder          = var.configure_ntp_forwarder
  configure_nfs_server             = var.configure_nfs_server
  dns_forwarder_config             = var.dns_forwarder_config
  nfs_server_config                = var.nfs_server_config
  powervs_resource_group_name      = var.powervs_resource_group_name
  powervs_management_network       = var.powervs_management_network
  powervs_backup_network           = var.powervs_backup_network
  tags                             = var.tags
  sm_service_plan                  = var.sm_service_plan
  existing_sm_instance_guid        = var.existing_sm_instance_guid
  existing_sm_instance_region      = var.existing_sm_instance_region
  network_services_vsi_profile     = var.network_services_vsi_profile
  enable_monitoring                = var.enable_monitoring
  existing_monitoring_instance_crn = var.existing_monitoring_instance_crn
  enable_scc_wp                    = var.enable_scc_wp
  ansible_vault_password           = var.ansible_vault_password
}

#####################################################
# PowerVS Instance module
#####################################################

module "powervs_instance" {
  source    = "terraform-ibm-modules/powervs-instance/ibm"
  version   = "2.8.2"
  providers = { ibm = ibm.ibm-pi }

  pi_workspace_guid      = module.standard.powervs_workspace_guid
  pi_ssh_public_key_name = module.standard.powervs_ssh_public_key.name

  pi_image_id                = local.pi_instance.pi_image_id
  pi_networks                = local.pi_instance.pi_networks
  pi_instance_name           = local.pi_instance.pi_instance_name
  pi_sap_profile_id          = local.pi_instance.pi_sap_profile_id
  pi_server_type             = local.pi_instance.pi_server_type
  pi_number_of_processors    = local.pi_instance.pi_number_of_processors
  pi_memory_size             = local.pi_instance.pi_memory_size
  pi_cpu_proc_type           = local.pi_instance.pi_cpu_proc_type
  pi_boot_image_storage_tier = "tier3"
  pi_storage_config          = local.pi_instance.pi_storage_config
  pi_user_tags               = var.tags
  pi_instance_init_linux = local.pi_instance_os_type == "linux" ? {
    enable             = true
    bastion_host_ip    = module.standard.access_host_or_ip
    ansible_host_or_ip = module.standard.ansible_host_or_ip
    # same as: ssh_private_key    = var.ssh_private_key
    # creates implicit dependencies without affecting the value of ssh_private_key
    ssh_private_key = "${var.ssh_private_key}${module.standard.nlb_nfs_network_services_ready ? "" : ""}"
    } : {
    enable             = false
    bastion_host_ip    = ""
    ansible_host_or_ip = ""
    ssh_private_key    = ""
  }
  pi_network_services_config = local.pi_instance_os_type == "linux" ? local.network_services_config : null
}

module "pi_aix_configure_services" {
  source     = "../../modules/powervs-vpc-landing-zone/submodules/ansible"
  count      = local.pi_instance_os_type == "aix" ? 1 : 0
  depends_on = [module.standard, module.powervs_instance]

  bastion_host_ip        = module.standard.access_host_or_ip
  ansible_host_or_ip     = module.standard.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = false

  src_script_template_name = "configure-aix-services/ansible_exec.sh.tftpl"
  dst_script_file_name     = "${var.prefix}-configure_aix_services_pi.sh"

  src_playbook_template_name = "configure-aix-services/playbook-configure-aix-services.yml.tftpl"
  dst_playbook_file_name     = "${var.prefix}-playbook-configure-aix-services-pi.yml"

  playbook_template_vars = {
    EXTEND_ROOT_VOLUME_WWN = module.powervs_instance.pi_storage_configuration[0].wwns
    DATA_VOLUME_WWN        = module.powervs_instance.pi_storage_configuration[1].wwns
    DATA_VOLUME_MOUNT_PATH = module.powervs_instance.pi_storage_configuration[1].mount
    DATAVG                 = "${module.powervs_instance.pi_storage_configuration[1].name}vg"
    DATALV                 = "${module.powervs_instance.pi_storage_configuration[1].name}lv"

    PROXY_IP_PORT = local.network_services_config.squid.squid_server_ip_port
    NO_PROXY      = local.network_services_config.squid.no_proxy_hosts

    NFS_ENABLE       = local.network_services_config.nfs.enable
    NFS_MOUNT_POINT  = local.network_services_config.nfs.nfs_client_path
    NFS_HOST_OR_PATH = local.network_services_config.nfs.nfs_server_path

    NTP_ENABLE = local.network_services_config.ntp.enable
    NTP_SERVER = local.network_services_config.ntp.ntp_server_ip

    # hardcoded values for NFS configuration (dummy values)
    NFS_DOMAIN   = "test.com"
    NFS_HOSTNAME = "nfs_server"

    DNS_ENABLE   = local.network_services_config.dns.enable
    DNS_SERVER_1 = local.network_services_config.dns.dns_server_ip


  }

  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "${var.prefix}-configure-aix-services-pi-inventory"
  inventory_template_vars = {
    host_or_ip = module.powervs_instance.pi_instance_primary_ip
  }
}


module "pi_scc_wp_agent" {

  source     = "../../modules/powervs-vpc-landing-zone/submodules/ansible"
  depends_on = [module.standard, module.powervs_instance, module.pi_aix_configure_services]
  count      = var.enable_scc_wp && contains(["aix", "linux"], local.pi_instance_os_type) ? 1 : 0

  bastion_host_ip        = module.standard.access_host_or_ip
  ansible_host_or_ip     = module.standard.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  ansible_vault_password = var.ansible_vault_password
  configure_ansible_host = false

  src_script_template_name = "configure-scc-wp-agent/ansible_configure_scc_wp_agent.sh.tftpl"
  dst_script_file_name     = "${var.prefix}-configure_scc_wp_agent_pi_${local.pi_instance_os_type}.sh"

  src_playbook_template_name = "configure-scc-wp-agent/playbook-configure-scc-wp-agent-${local.pi_instance_os_type}.yml.tftpl"
  dst_playbook_file_name     = "${var.prefix}-playbook-configure-scc-wp-agent-pi-${local.pi_instance_os_type}.yml"
  playbook_template_vars = {
    COLLECTOR_ENDPOINT : module.standard.scc_wp_instance.ingestion_endpoint,
    API_ENDPOINT : module.standard.scc_wp_instance.api_endpoint,
    ACCESS_KEY : module.standard.scc_wp_instance.access_key
  }
  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "${var.prefix}-scc-wp-inventory-pi-${local.pi_instance_os_type}"
  inventory_template_vars     = { "host_or_ip" : module.powervs_instance.pi_instance_primary_ip }
}
