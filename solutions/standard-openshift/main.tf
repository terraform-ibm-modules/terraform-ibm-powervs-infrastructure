#####################################################
# PowerVS with VPC landing zone module
#####################################################

locals {
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

  # automatically pick the supported system type unless it's overwritten by the user
  p10_unsupported_regions = ["che01", "lon04", "lon06", "mon01", "syd04", "syd05", "tor01", "us-east"] # datacenters that don't support P10 yet
  system_type             = contains(local.p10_unsupported_regions, var.powervs_zone) ? "s922" : "s1022"

  cluster_master_node_config = var.cluster_master_node_config.system_type != null ? var.cluster_master_node_config : merge(var.cluster_master_node_config, { system_type : local.system_type })
  cluster_worker_node_config = var.cluster_worker_node_config.system_type != null ? var.cluster_worker_node_config : merge(var.cluster_worker_node_config, { system_type : local.system_type })
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
  configure_dns_forwarder          = false
  configure_ntp_forwarder          = var.configure_ntp_forwarder
  configure_nfs_server             = var.configure_nfs_server
  dns_forwarder_config             = null
  nfs_server_config                = var.nfs_server_config
  powervs_resource_group_name      = null
  powervs_management_network       = null
  powervs_backup_network           = null
  tags                             = var.tags
  sm_service_plan                  = var.sm_service_plan
  existing_sm_instance_guid        = var.existing_sm_instance_guid
  existing_sm_instance_region      = var.existing_sm_instance_region
  network_services_vsi_profile     = var.network_services_vsi_profile
  enable_monitoring                = var.enable_monitoring
  existing_monitoring_instance_crn = var.existing_monitoring_instance_crn
  enable_scc_wp                    = var.enable_scc_wp
  ansible_vault_password           = var.ansible_vault_password
  ibm_dns_service                  = { enable = true, name = "${var.cluster_name}-dns", base_domain = var.cluster_base_domain, label = var.cluster_name }
}

#####################################################
# Openshift Cluster Deployment modules
#####################################################

locals {
  powervs_region = lookup(local.openshift_region_map, var.powervs_zone, null)
  vpc_region     = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
}

module "ocp_cluster_install_configuration" {
  source     = "../../modules/ansible"
  depends_on = [module.standard]

  bastion_host_ip        = module.standard.access_host_or_ip
  ansible_host_or_ip     = module.standard.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = false

  src_script_template_name = "deploy-openshift-cluster/ansible_exec.sh.tftpl"
  dst_script_file_name     = "ocp-cluster-install-configuration.sh"

  src_playbook_template_name = "deploy-openshift-cluster/playbook-configure-ocp-cluster.yml.tftpl"
  dst_playbook_file_name     = "ocp-cluster-install-configuration-playbook.yml"
  playbook_template_vars = {
    OPENSHIFT_RELEASE : var.openshift_release,
    BASE_DOMAIN : var.cluster_base_domain,
    CLUSTER_DIR : var.cluster_dir,
    CLUSTER_NAME : var.cluster_name,
    CLUSTER_NETWORK : var.cluster_network_config.cluster_network_cidr,
    CLUSTER_SERVICE_NETWORK : var.cluster_network_config.cluster_service_network_cidr,
    WORKER_PROCESSORS : local.cluster_worker_node_config.processors,
    WORKER_SYSTEM_TYPE : local.cluster_worker_node_config.system_type,
    WORKER_PROC_TYPE : local.cluster_worker_node_config.proc_type,
    WORKER_REPLICAS : local.cluster_worker_node_config.replicas,
    MASTER_PROCESSORS : local.cluster_master_node_config.processors,
    MASTER_SYSTEM_TYPE : local.cluster_master_node_config.system_type,
    MASTER_PROC_TYPE : local.cluster_master_node_config.proc_type,
    MASTER_REPLICAS : local.cluster_master_node_config.replicas,
    USER_ID : var.user_id,
    TRANSIT_GATEWAY_NAME : module.standard.transit_gateway_name,
    POWERVS_WORKSPACE_GUID : module.standard.powervs_workspace_guid,
    RESOURCE_GROUP : module.standard.powervs_resource_group_name,
    POWERVS_REGION : local.powervs_region,
    POWERVS_ZONE : var.powervs_zone,
    VPC_NAME : module.standard.vpc_names[0],
    VPC_REGION : local.vpc_region
    PULL_SECRET_FILE : jsonencode(var.openshift_pull_secret),
    SSH_KEY : var.ssh_public_key,
  }

  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "${var.cluster_name}-playbook-ocp-install-config-inventory"
  inventory_template_vars     = { "host_or_ip" : module.standard.ansible_host_or_ip }
}

module "ocp_cluster_manifest_creation" {
  source     = "../../modules/ansible"
  depends_on = [module.ocp_cluster_install_configuration]

  bastion_host_ip        = module.standard.access_host_or_ip
  ansible_host_or_ip     = module.standard.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = false
  ibmcloud_api_key       = var.ibmcloud_api_key

  src_script_template_name = "deploy-openshift-cluster/ansible_exec.sh.tftpl"
  dst_script_file_name     = "create-ocp-cluster-manifests.sh"

  src_playbook_template_name = "deploy-openshift-cluster/playbook-create-ocp-cluster-manifests.yml.tftpl"
  dst_playbook_file_name     = "ocp-cluster-manifest-creation-playbook.yml"
  playbook_template_vars = {
    RELEASE_IMAGE : "quay.io/openshift-release-dev/ocp-release:${var.openshift_release}-multi",
    CLUSTER_NAME : var.cluster_name,
    CLUSTER_DIR : "/root/${var.cluster_dir}",
    REQUESTS_DIR : "./credreqs"
    ACCOUNT_NAME : var.cluster_name,
    RESOURCE_GROUP : module.standard.powervs_resource_group_name,
  }

  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "${var.cluster_name}-playbook-ocp-install-config-inventory"
  inventory_template_vars     = { "host_or_ip" : module.standard.ansible_host_or_ip }
}

module "ocp_cluster_deployment" {
  source     = "../../modules/ansible"
  depends_on = [module.ocp_cluster_manifest_creation]

  bastion_host_ip        = module.standard.access_host_or_ip
  ansible_host_or_ip     = module.standard.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = false
  ibmcloud_api_key       = var.ibmcloud_api_key

  src_script_template_name = "deploy-openshift-cluster/ansible_exec.sh.tftpl"
  dst_script_file_name     = "deploy-ocp-cluster.sh"

  src_playbook_template_name = "deploy-openshift-cluster/playbook-deploy-ocp-cluster.yml.tftpl"
  dst_playbook_file_name     = "ocp-cluster-deployment-playbook.yml"
  playbook_template_vars = {
    IBM_ID : var.user_id
    POWERVS_REGION : local.powervs_region,
    POWERVS_ZONE : var.powervs_zone,
    RESOURCE_GROUP : module.standard.powervs_resource_group_name,
    CLUSTER_DIR : var.cluster_dir,
    OPENSHIFT_INSTALL_BOOTSTRAP_TIMEOUT : "120m",
    OPENSHIFT_INSTALL_MACHINE_WAIT_TIMEOUT : "35m",
    OPENSHIFT_INSTALL_CLUSTER_TIMEOUT : "180m",
    OPENSHIFT_INSTALL_DESTROY_TIMEOUT : "60m",
  }

  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "${var.cluster_name}-playbook-ocp-install-config-inventory"
  inventory_template_vars     = { "host_or_ip" : module.standard.ansible_host_or_ip }
}
