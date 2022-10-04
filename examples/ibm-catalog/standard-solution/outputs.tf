output "powervs_service_name" {
  description = "PowerVS infrastructure name."
  value       = module.powervs_infra.powervs_service_name
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

output "powervs_backup_network_name" {
  description = "Name of backup network in created PowerVS infrastructure."
  value       = module.powervs_infra.powervs_backup_network_name
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
  value       = module.powervs_infra.dns_host_or_ip
}

output "ntp_host_or_ip" {
  description = "NTP host for created PowerVS infrastructure."
  value       = module.powervs_infra.ntp_host_or_ip
}

output "nfs_path" {
  description = "NFS host for created PowerVS infrastructure."
  value       = module.powervs_infra.nfs_path
}
