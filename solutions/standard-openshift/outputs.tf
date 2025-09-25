########################################################################
# Cluster outputs
########################################################################

output "cluster_name" {
  description = "The name of the cluster and the prefix that is associated with all resources."
  value       = var.cluster_name
}

output "cluster_base_domain" {
  description = "The base domain the cluster is using."
  value       = var.cluster_base_domain
}

output "cluster_dir" {
  description = "The directory on the network services VSI that holds the artifacts of the OpenShift cluster creation."
  value       = local.cluster_dir
}

output "cluster_resource_group" {
  description = "The resource group where all cluster resources, Transit Gateway, VPC, and PowerVS resources reside."
  value       = module.standard.powervs_resource_group_name
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
  description = "Details of the IBM Cloud Monitoring Instance: CRN, location, guid."
  value       = module.standard.monitoring_instance
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

########################################################################
# Schematics
########################################################################

output "schematics_workspace_id" {
  description = "ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics."
  value       = var.IC_SCHEMATICS_WORKSPACE_ID
}
