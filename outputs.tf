output "pvs_service_name" {
  description = "PowerVS infrastructure name."
  value       = var.powervs_service_name
}

output "pvs_sshkey_name" {
  description = "SSH public key name in created PowerVS infrastructure."
  value       = var.powervs_sshkey_name
}

output "pvs_zone" {
  description = "Zone where PowerVS infrastructure is created."
  value       = var.powervs_zone
}

output "pvs_resource_group_name" {
  description = "IBM Cloud resource group where PowerVS infrastructure is created."
  value       = var.powervs_resource_group_name
}

output "cloud_connection_count" {
  description = "Number of cloud connections configured in created PowerVS infrastructure."
  value       = var.cloud_connection_count
}

output "pvs_management_network_name" {
  description = "Name of management network in created PowerVS infrastructure."
  value       = var.powervs_management_network["name"]
}

output "pvs_backup_network_name" {
  description = "Name of backup network in created PowerVS infrastructure."
  value       = var.powervs_backup_network["name"]
}

output "access_host_or_ip" {
  description = "Access host for created PowerVS infrastructure."
  value       = var.access_host_or_ip
}

output "squid_host_or_ip" {
  description = "Proxy host for created PowerVS infrastructure."
  value       = var.squid_config["server_host_or_ip"]
}

output "dns_host_or_ip" {
  description = "DNS forwarder host for created PowerVS infrastructure."
  value       = var.dns_forwarder_config["server_host_or_ip"]
}

output "ntp_host_or_ip" {
  description = "NTP host for created PowerVS infrastructure."
  value       = var.ntp_forwarder_config["server_host_or_ip"]
}

output "nfs_path" {
  description = "NFS host for created PowerVS infrastructure."
  value       = "${var.nfs_config["server_host_or_ip"]}:${var.nfs_config["nfs_directory"]}"
}
