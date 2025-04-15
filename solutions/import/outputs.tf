output "prefix" {
  description = "The prefix that is associated with all resources."
  value       = ""
}

##############################################################
# VPC Landing Zone Values
##############################################################

output "ssh_public_key" {
  description = "The string value of the ssh public key used when deploying VPC."
  value       = module.access_host.vsi_ssh_public_key[0].public_key
  sensitive   = true
}

output "transit_gateway_name" {
  description = "The name of the transit gateway."
  value       = var.transit_gateway_name
}

output "transit_gateway_id" {
  description = "The ID of transit gateway."
  value       = data.ibm_tg_gateway.tgw_ds.id
}
output "access_host_or_ip" {
  description = "Access host(jump/bastion) for existing PowerVS infrastructure."
  value       = var.access_host.floating_ip
}

output "proxy_host_or_ip_port" {
  description = "Proxy host:port for existing PowerVS infrastructure."
  value       = local.proxy_host_ip_port
}

output "dns_host_or_ip" {
  description = "DNS forwarder host for existing PowerVS infrastructure."
  value       = var.dns_server_ip
}

output "ntp_host_or_ip" {
  description = "NTP host for existing PowerVS infrastructure."
  value       = var.ntp_server_ip != "" ? var.ntp_server_ip : ""
}

output "nfs_host_or_ip_path" {
  description = "NFS host for existing PowerVS infrastructure."
  value       = local.nfs_host_or_ip_path
}

##############################################################
# PowerVS Infrastructure outputs
##############################################################

output "powervs_zone" {
  description = "Zone of existing PowerVS infrastructure."
  value       = var.powervs_zone
}

output "powervs_workspace_name" {
  description = "PowerVS infrastructure workspace name."
  value       = module.powervs_workspace_ds.powervs_workspace_name
}

output "powervs_workspace_id" {
  description = "PowerVS infrastructure workspace CRN."
  value       = module.powervs_workspace_ds.powervs_workspace_crn
}

output "powervs_workspace_guid" {
  description = "PowerVS infrastructure workspace guid. The GUID of the resource instance."
  value       = var.powervs_workspace_guid
}

output "powervs_ssh_public_key" {
  description = "SSH public key name and value used in existing PowerVS infrastructure."
  value = {
    "name"  = var.powervs_sshkey_name
    "value" = module.access_host.vsi_ssh_public_key[0].public_key
  }
}

output "powervs_management_subnet" {
  description = "Name, ID and CIDR of management private network in existing PowerVS infrastructure."
  value       = module.powervs_workspace_ds.powervs_management_network_subnet
}

output "powervs_backup_subnet" {
  description = "Name, ID and CIDR of backup private network in existing PowerVS infrastructure."
  value       = module.powervs_workspace_ds.powervs_backup_network_subnet
}

output "powervs_images" {
  description = "Object containing imported PowerVS image names and image ids."
  value       = module.powervs_workspace_ds.powervs_images
}

output "schematics_workspace_id" {
  description = "ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics."
  value       = var.IC_SCHEMATICS_WORKSPACE_ID
}
