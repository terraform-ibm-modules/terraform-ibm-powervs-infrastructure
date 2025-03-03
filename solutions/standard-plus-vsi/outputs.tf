output "prefix" {
  description = "The prefix that is associated with all resources"
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

output "ssh_public_key" {
  description = "The string value of the ssh public key used when deploying VPC"
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
# Monitoring Instance outputs
########################################################################

output "monitoring_instance" {
  description = "Details of the IBM Cloud Monitoring Instance: CRN, location, guid"
  value       = module.standard.monitoring_instance
}

########################################################################
# SCC Workload Protection outputs
########################################################################

output "scc_wp_instance" {
  description = "Details of the IBM Cloud Workload Protection instance: api_endpoint, crn, guid, ingestion_endpoint"
  value       = module.standard.scc_wp_instance
}

output "scc_wp_access_key" {
  description = "Access key for the Security and Compliance Center Workload Protection Instance."
  value       = module.standard.scc_wp_access_key
  sensitive   = true
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
