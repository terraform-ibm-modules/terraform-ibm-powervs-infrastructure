output "powervs_workspace_name" {
  description = "PowerVS infrastructure workspace name."
  value       = var.powervs_workspace_name
}

output "powervs_workspace_crn" {
  description = "PowerVS infrastructure workspace CRN."
  value       = module.powervs_workspace.powervs_workspace_crn
}

output "powervs_sshkey_name" {
  description = "SSH public key name in created PowerVS infrastructure."
  value       = var.powervs_sshkey_name
}

output "powervs_zone" {
  description = "Zone where PowerVS infrastructure is created."
  value       = var.powervs_zone
}

output "powervs_resource_group_name" {
  description = "IBM Cloud resource group where PowerVS infrastructure is created."
  value       = var.powervs_resource_group_name
}

output "cloud_connection_count" {
  description = "Number of cloud connections configured in created PowerVS infrastructure."
  value       = var.cloud_connection_count
}

output "powervs_management_network_name" {
  description = "Name of management network in created PowerVS infrastructure."
  value       = var.powervs_management_network.name
}

output "powervs_backup_network_name" {
  description = "Name of backup network in created PowerVS infrastructure."
  value       = var.powervs_backup_network.name
}

output "access_host_or_ip" {
  description = "Access host for created PowerVS infrastructure."
  value       = var.access_host_or_ip
}

output "proxy_host_or_ip_port" {
  description = "Proxy host for created PowerVS infrastructure."
  value       = var.squid_config != null ? (var.squid_config.squid_enable || var.squid_config.server_host_or_ip != "") ? "${var.squid_config.server_host_or_ip}:${var.squid_config.squid_port}" : "" : ""
}

output "dns_host_or_ip" {
  description = "DNS forwarder host for created PowerVS infrastructure."
  value       = var.dns_forwarder_config.dns_enable ? var.dns_forwarder_config["server_host_or_ip"] : ""
}

output "ntp_host_or_ip" {
  description = "NTP host for created PowerVS infrastructure."
  value       = var.ntp_forwarder_config.ntp_enable ? var.ntp_forwarder_config["server_host_or_ip"] : ""
}

output "nfs_host_or_ip_path" {
  description = "NFS host for created PowerVS infrastructure."
  value       = var.nfs_config.nfs_enable ? "${var.nfs_config["server_host_or_ip"]}:${var.nfs_config["nfs_file_system"][0]["mount_path"]}" : ""
}
