output "prefix" {
  description = "The prefix that is associated with all resources."
  value       = var.prefix
}

########################################################################
# Landing Zone VPC outputs
########################################################################

output "vpc_names" {
  description = "A list of the names of the VPC."
  value       = module.standard.vpc_names
}

output "vsi_names" {
  description = "A list of the vsis names provisioned within the VPCs."
  value       = module.standard.vsi_names
}

output "vpc_data" {
  description = "List of VPC data."
  value       = module.standard.vpc_data
}

output "kms_key_map" {
  description = "Map of ids and keys for KMS keys created"
  value       = module.standard.kms_key_map
}

output "vsi_ssh_key_data" {
  description = "List of VSI SSH key data"
  value       = module.standard.vsi_ssh_key_data
}

output "network_load_balancer" {
  description = "Details of network load balancer."
  value       = module.standard.network_load_balancer
}

output "ssh_public_key" {
  description = "The string value of the ssh public key used when deploying VPC."
  value       = var.ssh_public_key
}

output "transit_gateway_name" {
  description = "The name of the transit gateway."
  value       = module.standard.transit_gateway_name
}

output "transit_gateway_id" {
  description = "The ID of transit gateway."
  value       = module.standard.transit_gateway_id
}

output "vsi_list" {
  description = "A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP."
  value       = module.standard.vsi_list
}

output "resource_group_data" {
  description = "List of resource groups data used within landing zone."
  value       = module.standard.resource_group_data
}

output "access_host_or_ip" {
  description = "Access host(jump/bastion) for created PowerVS infrastructure."
  value       = module.standard.access_host_or_ip
}

output "proxy_host_or_ip_port" {
  description = "Proxy host:port for created PowerVS infrastructure."
  value       = module.standard.proxy_host_or_ip_port
}

output "dns_host_or_ip" {
  description = "DNS forwarder host for created PowerVS infrastructure."
  value       = module.standard.dns_host_or_ip
}

output "ntp_host_or_ip" {
  description = "NTP host for created PowerVS infrastructure."
  value       = module.standard.ntp_host_or_ip
}

output "nfs_host_or_ip_path" {
  description = "NFS host for created PowerVS infrastructure."
  value       = module.standard.nfs_host_or_ip_path
}

output "ansible_host_or_ip" {
  description = "Central Ansible node private IP address."
  value       = module.standard.ansible_host_or_ip
}

output "network_services_config" {
  description = "Complete configuration of network management services."
  value       = module.standard.network_services_config
}

########################################################################
# SCC Workload Protection outputs
########################################################################
output "scc_wp_instance" {
  description = "Details of the Security and Compliance Center Workload Protection Instance: guid, access key, api_endpoint, ingestion_endpoint."
  value       = module.standard.scc_wp_instance
}

########################################################################
# PowerVS Infrastructure outputs
########################################################################

output "powervs_zone" {
  description = "Zone where PowerVS infrastructure is created."
  value       = var.powervs_zone
}

output "powervs_resource_group_name" {
  description = "IBM Cloud resource group where PowerVS infrastructure is created."
  value       = var.powervs_resource_group_name
}

output "powervs_workspace_name" {
  description = "PowerVS infrastructure workspace name."
  value       = module.standard.powervs_workspace_name
}

output "powervs_workspace_id" {
  description = "PowerVS infrastructure workspace id. The unique identifier of the new resource instance."
  value       = module.standard.powervs_workspace_id
}

output "powervs_workspace_guid" {
  description = "PowerVS infrastructure workspace guid. The GUID of the resource instance."
  value       = module.standard.powervs_workspace_guid
}

output "powervs_ssh_public_key" {
  description = "SSH public key name and value in created PowerVS infrastructure."
  value       = module.standard.powervs_ssh_public_key
}

output "powervs_management_subnet" {
  description = "Name, ID and CIDR of management private network in created PowerVS infrastructure."
  value       = module.standard.powervs_management_subnet
}

output "powervs_backup_subnet" {
  description = "Name, ID and CIDR of backup private network in created PowerVS infrastructure."
  value       = module.standard.powervs_backup_subnet
}

output "powervs_images" {
  description = "Object containing imported PowerVS image names and image ids."
  value       = module.standard.powervs_images
}


########################################################################
# PowerVS Instance outputs
########################################################################

output "powervs_instance_management_ip" {
  description = "IP address of the primary network interface of IBM PowerVS instance."
  value       = module.powervs_instance.pi_instance_primary_ip
}

output "powervs_instance_private_ips" {
  description = "All private IP addresses (as a list) of IBM PowerVS instance."
  value       = module.powervs_instance.pi_instance_private_ips
}

output "powervs_storage_configuration" {
  description = "Storage configuration of PowerVS instance."
  value       = module.powervs_instance.pi_storage_configuration
}

output "schematics_workspace_id" {
  description = "ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics."
  value       = var.IC_SCHEMATICS_WORKSPACE_ID
}

output "mariadb_version" {
  description = "MariaDB version installed from the official repo."
  value       = var.mariadb_version
}

output "mariadb_instance_name" {
  description = "Name of the PowerVS instance running MariaDB."
  value       = local.pi_instance.pi_instance_name
}

output "mariadb_tshirt_size" {
  description = "Selected MariaDB t-shirt size profile."
  value       = var.tshirt_size.tshirt_size
}

output "mariadb_cpu_cores" {
  description = "Number of CPU cores allocated to the MariaDB instance."
  value       = local.qs_tshirt_choice.cores
}

output "mariadb_memory_gb" {
  description = "Memory (in GB) allocated to the MariaDB instance."
  value       = local.qs_tshirt_choice.memory
}

output "mariadb_proc_type" {
  description = "Processor type (shared/dedicated/capped) of the MariaDB instance."
  value       = local.qs_tshirt_choice.proc_type
}

output "mariadb_server_type" {
  description = "PowerVS server type (e.g. s1022) hosting the MariaDB instance."
  value       = local.qs_tshirt_choice.server_type
}

output "mariadb_storage_size_gb" {
  description = "Size (in GB) of the data volume attached to the MariaDB instance."
  value       = local.qs_tshirt_choice.storage
}

output "mariadb_storage_tier" {
  description = "Storage tier of the MariaDB data volume (e.g. tier3)."
  value       = local.qs_tshirt_choice.tier
}

output "mariadb_storage_mount" {
  description = "Filesystem mount point for the MariaDB data volume."
  value       = "/var/lib/mysql"
}

output "mariadb_innodb_buffer_pool_size" {
  description = "InnoDB buffer pool size configured for MariaDB (80% of instance RAM)."
  value       = local.innodb_buffer_pool_size
}

output "mariadb_innodb_buffer_pool_size_min" {
  description = "InnoDB buffer pool minimum size configured for MariaDB (50% of instance RAM)."
  value       = local.innodb_buffer_pool_size_min
}

output "mariadb_instance_id" {
  description = "Composite ID of the MariaDB PowerVS instance (<workspace_id>/<instance_id>)."
  value       = module.powervs_instance.pi_instance_id
}

output "mariadb_instance_unique_id" {
  description = "Unique identifier of the MariaDB PowerVS instance."
  value       = module.powervs_instance.pi_instance_instance_id
}

output "mariadb_os_image" {
  description = "OS image used for the MariaDB PowerVS instance (e.g. RHEL9-SP4)."
  value       = var.tshirt_size.image
}

output "mariadb_bind_address" {
  description = "Network address MariaDB is configured to listen on ('*' means all interfaces)."
  value       = "*"
}

output "mariadb_installation_output" {
  description = "Output from the Ansible playbook that installed and configured MariaDB."
  value       = module.mariadb_installation.playbook_output
  sensitive   = true
}

########################################################################
# Replication outputs
########################################################################

output "mariadb_replication_role" {
  description = "Replication role of this MariaDB instance: standalone, primary, or replica."
  value       = var.mariadb_replication.role
}

output "mariadb_replication_primary_ip" {
  description = "IP address of the primary MariaDB instance. Empty string when role is standalone or primary."
  value       = var.mariadb_replication.primary_ip
}

output "mariadb_replica_count" {
  description = "Number of MariaDB replica PowerVS instances provisioned."
  value       = var.mariadb_replication.replica_count
}

output "mariadb_replica_instance_ips" {
  description = "Management IP addresses of all MariaDB replica PowerVS instances."
  value       = [for r in module.powervs_replica_instance : r.pi_instance_primary_ip]
}

########################################################################
# Sample data outputs
########################################################################

output "mariadb_sample_data_loaded" {
  description = "Sample dataset loaded into MariaDB after installation (none, sakila, world, or vector)."
  value       = var.mariadb_sample_data
}
