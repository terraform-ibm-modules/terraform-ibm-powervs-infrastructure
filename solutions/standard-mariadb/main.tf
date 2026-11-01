#####################################################
# PowerVS with VPC landing zone module
#####################################################

module "standard" {
  source = "../../modules/powervs-vpc-landing-zone"

  providers = { ibm.ibm-is = ibm.ibm-is, ibm.ibm-pi = ibm.ibm-pi, ibm.ibm-sm = ibm.ibm-sm }

  powervs_zone                 = var.powervs_zone
  prefix                       = var.prefix
  external_access_ip           = var.external_access_ip
  ssh_public_key               = var.ssh_public_key
  ssh_private_key              = var.ssh_private_key
  client_to_site_vpn           = var.client_to_site_vpn
  vpc_subnet_cidrs             = var.vpc_subnet_cidrs
  vpc_intel_images             = merge(var.vpc_intel_images, { sles_image = "" })
  configure_dns_forwarder      = var.configure_dns_forwarder
  configure_ntp_forwarder      = var.configure_ntp_forwarder
  configure_nfs_server         = var.configure_nfs_server
  dns_forwarder_config         = var.dns_forwarder_config
  nfs_server_config            = var.nfs_server_config
  powervs_resource_group_name  = var.powervs_resource_group_name
  powervs_management_network   = var.powervs_management_network
  powervs_backup_network       = var.powervs_backup_network
  tags                         = var.tags
  sm_service_plan              = var.sm_service_plan
  existing_sm_instance_guid    = var.existing_sm_instance_guid
  existing_sm_instance_region  = var.existing_sm_instance_region
  network_services_vsi_profile = var.network_services_vsi_profile
  enable_monitoring            = false
  enable_scc_wp                = var.enable_scc_wp
  ansible_vault_password       = var.ansible_vault_password
  enable_atracker              = var.enable_atracker
  enable_vpc_flow_logs         = var.enable_vpc_flow_logs
}


#####################################################
# PowerVS Instance module
#####################################################

module "powervs_instance" {
  source    = "terraform-ibm-modules/powervs-instance/ibm"
  version   = "2.8.9"
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
  pi_user_data               = base64encode(local.pi_user_data)
  pi_instance_init_linux = {
    enable             = true
    bastion_host_ip    = module.standard.access_host_or_ip
    ansible_host_or_ip = module.standard.ansible_host_or_ip
    # same as: ssh_private_key    = var.ssh_private_key
    # creates implicit dependencies without affecting the value of ssh_private_key
    ssh_private_key = "${var.ssh_private_key}${module.standard.nlb_nfs_network_services_ready ? "" : ""}"
  }
  pi_network_services_config = local.network_services_config
}

#####################################################
# PowerVS Replica Instance(s) module
#####################################################

module "powervs_replica_instance" {
  count     = var.mariadb_replication.replica_count
  source    = "terraform-ibm-modules/powervs-instance/ibm"
  version   = "2.8.9"
  providers = { ibm = ibm.ibm-pi }

  pi_workspace_guid      = module.standard.powervs_workspace_guid
  pi_ssh_public_key_name = module.standard.powervs_ssh_public_key.name

  pi_image_id                = local.pi_replica_instance.pi_image_id
  pi_networks                = local.pi_replica_instance.pi_networks
  pi_instance_name           = "${local.pi_replica_instance.pi_instance_name}-${count.index}"
  pi_sap_profile_id          = local.pi_replica_instance.pi_sap_profile_id
  pi_server_type             = local.pi_replica_instance.pi_server_type
  pi_number_of_processors    = local.pi_replica_instance.pi_number_of_processors
  pi_memory_size             = local.pi_replica_instance.pi_memory_size
  pi_cpu_proc_type           = local.pi_replica_instance.pi_cpu_proc_type
  pi_boot_image_storage_tier = "tier3"
  pi_storage_config          = local.pi_replica_instance.pi_storage_config
  pi_user_tags               = var.tags
  pi_user_data               = base64encode(local.pi_user_data)
  pi_instance_init_linux = {
    enable             = true
    bastion_host_ip    = module.standard.access_host_or_ip
    ansible_host_or_ip = module.standard.ansible_host_or_ip
    # same as: ssh_private_key    = var.ssh_private_key
    # creates implicit dependencies without affecting the value of ssh_private_key
    ssh_private_key = "${var.ssh_private_key}${module.standard.nlb_nfs_network_services_ready ? "" : ""}"
  }
  pi_network_services_config = local.network_services_config
}

resource "terraform_data" "wait_replica_cloudinit" {
  count      = var.mariadb_replication.replica_count
  depends_on = [module.powervs_replica_instance]

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = module.standard.access_host_or_ip
    host         = module.powervs_replica_instance[count.index].pi_instance_primary_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "10m"
  }

  provisioner "remote-exec" {
    inline = ["echo replica ssh ready"]
  }
}

module "mariadb_installation" {
  source     = "../../modules/powervs-vpc-landing-zone/submodules/ansible"
  depends_on = [module.standard, module.powervs_instance]

  bastion_host_ip        = module.standard.access_host_or_ip
  ansible_host_or_ip     = module.standard.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  ansible_vault_password = var.ansible_vault_password
  configure_ansible_host = false

  src_script_template_name    = "configure-mariadb/ansible_exec.sh.tftpl"
  dst_script_file_name        = "${var.prefix}-mariadb-install.sh"
  src_playbook_template_name  = "configure-mariadb/playbook-mariadb.yml.tftpl"
  dst_playbook_file_name      = "${var.prefix}-playbook-mariadb.yml"
  src_inventory_template_name = "inventory-primary.tftpl"
  dst_inventory_file_name     = "${var.prefix}-mariadb-inventory"

  inventory_template_vars = {
    host_or_ip = module.powervs_instance.pi_instance_primary_ip
    server_id  = 1
  }

  playbook_template_vars = {
    MARIADB_VERSION             = var.mariadb_version
    INNODB_BUFFER_POOL_SIZE     = local.innodb_buffer_pool_size
    INNODB_BUFFER_POOL_SIZE_MIN = local.innodb_buffer_pool_size_min
    REPLICATION_ROLE            = var.mariadb_replication.role
    REPLICATION_PRIMARY_IP      = var.mariadb_replication.primary_ip
    REPLICATION_PASSWORD        = var.mariadb_replication.role != "standalone" ? var.mariadb_replication_password : ""
  }
}

#####################################################
# MariaDB Replica configuration (Ansible)
#####################################################

module "mariadb_replica_installation" {
  source     = "../../modules/powervs-vpc-landing-zone/submodules/ansible"
  count      = var.mariadb_replication.replica_count > 0 ? 1 : 0
  depends_on = [module.mariadb_installation, module.powervs_replica_instance, terraform_data.wait_replica_cloudinit]

  bastion_host_ip        = module.standard.access_host_or_ip
  ansible_host_or_ip     = module.standard.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  ansible_vault_password = var.ansible_vault_password
  configure_ansible_host = false

  src_script_template_name    = "configure-mariadb/ansible_exec.sh.tftpl"
  dst_script_file_name        = "${var.prefix}-mariadb-replica-install.sh"
  src_playbook_template_name  = "configure-mariadb/playbook-mariadb.yml.tftpl"
  dst_playbook_file_name      = "${var.prefix}-playbook-mariadb-replica.yml"
  src_inventory_template_name = "inventory-replicas.tftpl"
  dst_inventory_file_name     = "${var.prefix}-mariadb-replica-inventory"

  inventory_template_vars = {
    replicas = [
      for i, inst in module.powervs_replica_instance : {
        ip        = inst.pi_instance_primary_ip
        server_id = i + 2
      }
    ]
  }

  playbook_template_vars = {
    MARIADB_VERSION             = var.mariadb_version
    INNODB_BUFFER_POOL_SIZE     = local.innodb_buffer_pool_size
    INNODB_BUFFER_POOL_SIZE_MIN = local.innodb_buffer_pool_size_min
    REPLICATION_ROLE            = "replica"
    REPLICATION_PRIMARY_IP      = module.powervs_instance.pi_instance_primary_ip
    REPLICATION_PASSWORD        = var.mariadb_replication_password
  }
}

#####################################################
# Sample Data module (optional)
#####################################################

module "mariadb_sample_data" {
  source     = "../../modules/powervs-vpc-landing-zone/submodules/ansible"
  count      = var.mariadb_sample_data != "none" ? 1 : 0
  depends_on = [module.mariadb_installation]

  bastion_host_ip        = module.standard.access_host_or_ip
  ansible_host_or_ip     = module.standard.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = false

  src_script_template_name    = "configure-mariadb/ansible_exec.sh.tftpl"
  dst_script_file_name        = "${var.prefix}-mariadb-sampledata.sh"
  src_playbook_template_name  = "configure-mariadb/playbook-mariadb-sampledata.yml.tftpl"
  dst_playbook_file_name      = "${var.prefix}-playbook-mariadb-sampledata.yml"
  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "${var.prefix}-mariadb-sampledata-inventory"

  inventory_template_vars = {
    host_or_ip = module.powervs_instance.pi_instance_primary_ip
  }

  playbook_template_vars = {
    SAMPLE_DATA = var.mariadb_sample_data
  }
}

module "pi_scc_wp_agent" {

  source     = "../../modules/powervs-vpc-landing-zone/submodules/ansible"
  depends_on = [module.standard, module.powervs_instance]
  count      = var.enable_scc_wp ? 1 : 0

  bastion_host_ip        = module.standard.access_host_or_ip
  ansible_host_or_ip     = module.standard.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  ansible_vault_password = var.ansible_vault_password
  configure_ansible_host = false

  src_script_template_name = "configure-scc-wp-agent/ansible_configure_scc_wp_agent.sh.tftpl"
  dst_script_file_name     = "${var.prefix}-configure_scc_wp_agent_pi_linux.sh"

  src_playbook_template_name = "configure-scc-wp-agent/playbook-configure-scc-wp-agent-linux.yml.tftpl"
  dst_playbook_file_name     = "${var.prefix}-playbook-configure-scc-wp-agent-pi-linux.yml"
  playbook_template_vars = {
    COLLECTOR_ENDPOINT : module.standard.scc_wp_instance.ingestion_endpoint,
    API_ENDPOINT : module.standard.scc_wp_instance.api_endpoint,
    ACCESS_KEY : module.standard.scc_wp_instance.access_key
  }
  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "${var.prefix}-scc-wp-inventory-pi-linux"
  inventory_template_vars     = { "host_or_ip" : module.powervs_instance.pi_instance_primary_ip }
}
