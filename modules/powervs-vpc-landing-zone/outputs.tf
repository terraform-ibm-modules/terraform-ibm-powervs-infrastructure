output "prefix" {
  description = "The prefix that is associated with all resources"
  value       = var.prefix
}

########################################################################
# Landing Zone VPC outputs
########################################################################

output "vpc_names" {
  description = "A list of the names of the VPC."
  value       = module.landing_zone.vpc_names
}

output "vsi_names" {
  description = "A list of the vsis names provisioned within the VPCs."
  value       = module.landing_zone.vsi_names
}

output "ssh_public_key" {
  description = "The string value of the ssh public key used when deploying VPC"
  value       = var.ssh_public_key
}

output "transit_gateway_name" {
  description = "The name of the transit gateway."
  value       = module.landing_zone.transit_gateway_name
}

output "transit_gateway_id" {
  description = "The ID of transit gateway."
  value       = module.landing_zone.transit_gateway_data.id
}

output "transit_gateway_global" {
  description = "Connect to the networks outside the associated region."
  value       = var.transit_gateway_global
}

output "vsi_list" {
  description = "A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP."
  value       = module.landing_zone.vsi_list
}

output "vpc_data" {
  description = "List of VPC data."
  value       = module.landing_zone.vpc_data
}

output "resource_group_data" {
  description = "List of resource groups data used within landing zone."
  value       = module.landing_zone.resource_group_data
}

output "access_host_or_ip" {
  description = "Access host(jump/bastion) for created PowerVS infrastructure."
  value       = local.access_host_or_ip
}

output "proxy_host_or_ip_port" {
  description = "Proxy host:port for created PowerVS infrastructure."
  value       = "${local.network_services_vsi_ip}:${local.network_services_config.squid.squid_port}"
}

output "dns_host_or_ip" {
  description = "DNS forwarder host for created PowerVS infrastructure."
  value       = var.configure_dns_forwarder ? local.network_services_vsi_ip : ""
}

output "ntp_host_or_ip" {
  description = "NTP host for created PowerVS infrastructure."
  value       = var.configure_ntp_forwarder ? local.network_services_vsi_ip : ""
}

output "nfs_host_or_ip_path" {
  description = "NFS host for created PowerVS infrastructure."
  value       = var.configure_nfs_server ? module.vpc_file_share_alb[0].nfs_host_or_ip_path : ""
}

output "ansible_host_or_ip" {
  description = "Central Ansible node private IP address."
  value       = local.network_services_vsi_ip
}

output "network_services_config" {
  description = "Complete configuration of network management services."
  value       = local.network_services_config
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
  value       = module.powervs_workspace.pi_workspace_name
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

########################################################################
# Monitoring output
########################################################################

output "monitoring_instance" {
  description = "Details of the IBM Cloud Monitoring Instance: CRN, location, guid"
  value = {
    crn      = var.enable_monitoring && var.existing_monitoring_instance_crn == null ? resource.ibm_resource_instance.monitoring_instance[0].crn : var.existing_monitoring_instance_crn != null ? var.existing_monitoring_instance_crn : ""
    location = var.enable_monitoring && var.existing_monitoring_instance_crn == null ? resource.ibm_resource_instance.monitoring_instance[0].location : var.existing_monitoring_instance_crn != null ? split(":", var.existing_monitoring_instance_crn)[5] : ""
    guid     = var.enable_monitoring && var.existing_monitoring_instance_crn == null ? resource.ibm_resource_instance.monitoring_instance[0].guid : var.existing_monitoring_instance_crn != null ? split(":", var.existing_monitoring_instance_crn)[7] : ""
  }
}
