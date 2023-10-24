output "prefix" {
  description = "The prefix that is associated with all resources"
  value       = var.prefix
}

########################################################################
# Landing Zone VPC outputs
########################################################################

output "vpc_names" {
  description = "A list of the names of the VPC."
  value       = module.powervs_infra.vpc_names
}

output "vsi_names" {
  description = "A list of the vsis names provisioned within the VPCs."
  value       = module.powervs_infra.vsi_names
}

output "ssh_public_key" {
  description = "The string value of the ssh public key used when deploying VPC"
  value       = var.ssh_public_key
}

output "transit_gateway_name" {
  description = "The name of the transit gateway."
  value       = module.powervs_infra.transit_gateway_name
}

output "transit_gateway_id" {
  description = "The ID of transit gateway."
  value       = module.powervs_infra.transit_gateway_id
}

output "vsi_list" {
  description = "A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP."
  value       = module.powervs_infra.vsi_list
}

output "access_host_or_ip" {
  description = "Access host(jump/bastion) for created PowerVS infrastructure."
  value       = module.powervs_infra.access_host_or_ip
}

output "proxy_host_or_ip_port" {
  description = "Proxy host:port for created PowerVS infrastructure."
  value       = module.powervs_infra.proxy_host_or_ip_port
}

output "dns_host_or_ip" {
  description = "DNS forwarder host for created PowerVS infrastructure."
  value       = module.powervs_infra.dns_host_or_ip
}

output "ntp_host_or_ip" {
  description = "NTP host for created PowerVS infrastructure."
  value       = module.powervs_infra.ntp_host_or_ip
}

output "nfs_host_or_ip_path" {
  description = "NFS host for created PowerVS infrastructure."
  value       = module.powervs_infra.nfs_host_or_ip_path
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
  value       = module.powervs_infra.powervs_workspace_name
}

output "powervs_workspace_id" {
  description = "PowerVS infrastructure workspace id. The unique identifier of the new resource instance."
  value       = module.powervs_infra.powervs_workspace_id
}

output "powervs_workspace_guid" {
  description = "PowerVS infrastructure workspace guid. The GUID of the resource instance."
  value       = module.powervs_infra.powervs_workspace_guid
}

output "powervs_ssh_public_key" {
  description = "SSH public key name and value in created PowerVS infrastructure."
  value       = module.powervs_infra.powervs_ssh_public_key
}

output "powervs_management_subnet" {
  description = "Name, ID and CIDR of management private network in created PowerVS infrastructure."
  value       = module.powervs_infra.powervs_management_subnet
}

output "powervs_backup_subnet" {
  description = "Name, ID and CIDR of backup private network in created PowerVS infrastructure."
  value       = module.powervs_infra.powervs_backup_subnet
}

output "powervs_images" {
  description = "Object containing imported PowerVS image names and image ids."
  value       = module.powervs_infra.powervs_images
}

output "cloud_connection_count" {
  description = "Number of cloud connections configured in created PowerVS infrastructure."
  value       = module.powervs_infra.cloud_connection_count
}

output "schematics_workspace_id" {
  description = "ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics."
  value       = var.IC_SCHEMATICS_WORKSPACE_ID
}
