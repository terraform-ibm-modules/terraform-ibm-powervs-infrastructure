output "prefix" {
  description = "The prefix that is associated with all resources."
  value       = local.prefix
}

########################################################################
# Landing Zone VPC outputs
########################################################################

output "vpc_names" {
  description = "A list of the names of the VPC."
  value       = local.standard_output[0].vpc_names.value
}

output "vsi_names" {
  description = "A list of the vsis names provisioned within the VPCs."
  value       = local.standard_output[0].vsi_names.value
}

output "vpc_data" {
  description = "List of VPC data."
  value       = local.standard_output[0].vpc_data.value
}

output "application_load_balancer" {
  description = "Details of application load balancer."
  value       = local.standard_output[0].application_load_balancer.value
}

output "ssh_public_key" {
  description = "The string value of the ssh public key used when deploying VPC"
  value       = local.ssh_public_key
}

output "transit_gateway_name" {
  description = "The name of the transit gateway."
  value       = local.transit_gateway_name
}

output "transit_gateway_id" {
  description = "The ID of transit gateway."
  value       = local.transit_gateway_id
}

output "vsi_list" {
  description = "A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP."
  value       = local.standard_output[0].vsi_list.value
}

output "access_host_or_ip" {
  description = "Access host for created PowerVS infrastructure."
  value       = local.access_host_or_ip
}

output "proxy_host_or_ip_port" {
  description = "Proxy host:port for created PowerVS infrastructure."
  value       = local.proxy_host_or_ip_port
}

output "dns_host_or_ip" {
  description = "DNS forwarder host for created PowerVS infrastructure."
  value       = local.dns_host_or_ip
}

output "ntp_host_or_ip" {
  description = "NTP host for created PowerVS infrastructure."
  value       = local.ntp_host_or_ip
}

output "nfs_host_or_ip_path" {
  description = "NFS host for created PowerVS infrastructure."
  value       = local.nfs_host_or_ip_path
}

output "ansible_host_or_ip" {
  description = "Central Ansible node private IP address."
  value       = local.ansible_host_or_ip
}

output "network_services_config" {
  description = "Complete configuration of network management services."
  value       = local.network_services_config
}

########################################################################
# Monitoring Instance outputs
########################################################################

output "monitoring_instance" {
  description = "Details of the IBM Cloud Monitoring Instance: CRN, location, guid."
  value       = local.standard_output[0].monitoring_instance.value
}

########################################################################
# SCC Workload Protection outputs
########################################################################

output "scc_wp_instance" {
  description = "Details of the Security and Compliance Center Workload Protection Instance: guid, access key, api_endpoint, ingestion_endpoint."
  value       = local.standard_output[0].scc_wp_instance.value
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
  value       = local.powervs_workspace_name
}

output "powervs_workspace_id" {
  description = "PowerVS infrastructure workspace id. The unique identifier of the new resource instance."
  value       = module.powervs_workspace.pi_workspace_id
}

output "powervs_workspace_guid" {
  description = "PowerVS infrastructure workspace guid. The GUID of the resource instance."
  value       = module.powervs_workspace.pi_workspace_guid
}

output "powervs_ssh_public_key" {
  description = "SSH public key name and value in created PowerVS infrastructure."
  value       = module.powervs_workspace.pi_ssh_public_key
}

output "powervs_management_subnet" {
  description = "Name, ID and CIDR of management private network in created PowerVS infrastructure."
  value       = module.powervs_workspace.pi_private_subnet_1
}

output "powervs_backup_subnet" {
  description = "Name, ID and CIDR of backup private network in created PowerVS infrastructure."
  value       = module.powervs_workspace.pi_private_subnet_2
}

output "powervs_images" {
  description = "Object containing imported PowerVS image names and image ids."
  value       = module.powervs_workspace.pi_images
}

output "schematics_workspace_id" {
  description = "ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics"
  value       = var.IC_SCHEMATICS_WORKSPACE_ID
}
