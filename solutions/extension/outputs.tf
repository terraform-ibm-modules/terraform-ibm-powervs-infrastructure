output "prefix" {
  description = "The prefix that is associated with all resources"
  value       = local.prefix
}

output "vpc_names" {
  description = "A list of the names of the VPC."
  value       = local.fullstack_output[0].vpc_names.value
}

output "vsi_names" {
  description = "A list of the vsis names provisioned within the VPCs."
  value       = local.fullstack_output[0].vsi_names.value
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
  value       = local.fullstack_output[0].vsi_list.value
}
output "powervs_workspace_name" {
  description = "PowerVS infrastructure workspace name."
  value       = module.powervs_infra.powervs_workspace_name
}

output "powervs_workspace_crn" {
  description = "PowerVS infrastructure workspace CRN."
  value       = module.powervs_infra.powervs_workspace_crn
}

output "powervs_sshkey_name" {
  description = "SSH public key name in created PowerVS infrastructure."
  value       = module.powervs_infra.powervs_sshkey_name
}

output "powervs_zone" {
  description = "Zone where PowerVS infrastructure is created."
  value       = module.powervs_infra.powervs_zone
}

output "powervs_resource_group_name" {
  description = "IBM Cloud resource group where PowerVS infrastructure is created."
  value       = module.powervs_infra.powervs_resource_group_name
}

output "cloud_connection_count" {
  description = "Number of cloud connections configured in created PowerVS infrastructure."
  value       = module.powervs_infra.cloud_connection_count
}

output "powervs_management_network_name" {
  description = "Name of management network in created PowerVS infrastructure."
  value       = module.powervs_infra.powervs_management_network_name
}

output "powervs_management_network_subnet" {
  description = "Subnet CIDR  of management network in created PowerVS infrastructure."
  value       = var.powervs_management_network["cidr"]
}

output "powervs_backup_network_name" {
  description = "Name of backup network in created PowerVS infrastructure."
  value       = module.powervs_infra.powervs_backup_network_name
}

output "powervs_backup_network_subnet" {
  description = "Subnet CIDR of backup network in created PowerVS infrastructure."
  value       = var.powervs_backup_network["cidr"]
}

output "access_host_or_ip" {
  description = "Access host for created PowerVS infrastructure."
  value       = module.powervs_infra.access_host_or_ip
}

output "proxy_host_or_ip_port" {
  description = "Proxy host:port for created PowerVS infrastructure."
  value       = module.powervs_infra.proxy_host_or_ip_port
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
  value       = local.nfs_host_or_ip != "" ? "${local.nfs_host_or_ip}:${local.nfs_path}" : ""
}

output "schematics_workspace_id" {
  description = "ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics"
  value       = var.IC_SCHEMATICS_WORKSPACE_ID
}
