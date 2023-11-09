##############################################################
# VPC Landing Zone Values
##############################################################

output "vpc_names" {
  description = "A list of the names of the VPC."
  value = [
    for vpc_name in local.vpc_names :
    vpc_name
  ]
}

output "vsi_names" {
  description = "A list of the vsis names provisioned within the VPCs."
  value = [
    for vsi_name in local.vsi_names :
    vsi_name
  ]
}

output "ssh_public_key" {
  description = "The string value of the ssh public key used when deploying VPC"
  value       = module.access_host.vsi_ssh_public_key[0].public_key
  sensitive   = true
}

output "transit_gateway_name" {
  description = "The name of the transit gateway."
  value       = var.transit_gateway_name
}

output "transit_gateway_id" {
  description = "The ID of transit gateway."
  value       = data.ibm_tg_gateway.ds_tggateway.id
}

output "vsi_list" {
  description = "A list of VSI with name, id, floating IP, primary ipv4 address, secondary ipv4 address, VPC name, and zone."
  value = [
    for virtual_server in local.vsi_list :
    {
      floating_ip            = virtual_server.floating_ip
      id                     = virtual_server.id
      ipv4_address           = virtual_server.ipv4_address
      secondary_ipv4_address = virtual_server.secondary_ipv4_address
      name                   = virtual_server.name
      vpc_id                 = virtual_server.vpc_id
      vpc_name               = virtual_server.vpc_name
      zone                   = virtual_server.zone
    }
  ]
}

output "access_host_or_ip" {
  description = "Access host(jump/bastion) for created PowerVS infrastructure."
  value       = var.access_host.floating_ip
}

output "proxy_host_or_ip_port" {
  description = "Proxy host:port for created PowerVS infrastructure."
  value       = local.proxy_host_or_ip_port
}

output "dns_host_or_ip" {
  description = "DNS forwarder host for created PowerVS infrastructure."
  value       = module.workload_vsi.vsi_info.ipv4_address
}

output "ntp_host_or_ip" {
  description = "NTP host for created PowerVS infrastructure."
  value       = module.workload_vsi.vsi_info.ipv4_address
}

output "nfs_host_or_ip_path" {
  description = "NFS host for created PowerVS infrastructure."
  value       = local.nfs_host_or_ip_path
}

##############################################################
# PowerVS Infrastructure outputs
##############################################################

output "powervs_zone" {
  description = "Zone where PowerVS infrastructure is created."
  value       = var.powervs_zone
}

output "powervs_resource_group_name" {
  description = "IBM Cloud resource group where PowerVS infrastructure is created."
  value       = module.power_workspace_data_retrieval.powervs_resource_group_name
}

output "powervs_workspace_name" {
  description = "PowerVS infrastructure workspace name."
  value       = var.powervs_workspace_name
}

output "powervs_workspace_id" {
  description = "PowerVS infrastructure workspace CRN."
  value       = module.power_workspace_data_retrieval.powervs_workspace_crn
}

output "powervs_workspace_guid" {
  description = "PowerVS infrastructure workspace guid. The GUID of the resource instance."
  value       = module.power_workspace_data_retrieval.powervs_workspace_guid
}

output "powervs_ssh_public_key" {
  description = "SSH public key name and value in created PowerVS infrastructure."
  value = {
    "name"  = var.powervs_sshkey_name
    "value" = module.access_host.vsi_ssh_public_key[0].public_key
  }
}

output "powervs_management_subnet" {
  description = "Name, ID and CIDR of management private network in created PowerVS infrastructure."
  value       = module.power_workspace_data_retrieval.powervs_management_network_subnet
}

output "powervs_backup_subnet" {
  description = "Name, ID and CIDR of backup private network in created PowerVS infrastructure."
  value       = module.power_workspace_data_retrieval.powervs_backup_network_subnet
}

output "powervs_images" {
  description = "Object containing imported PowerVS image names and image ids."
  value       = module.power_workspace_data_retrieval.powervs_images
}

output "cloud_connections_count" {
  description = "Number of cloud connections configured in created PowerVS infrastructure."
  value       = length(local.cloud_connections)
}

output "schematics_workspace_id" {
  description = "ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics."
  value       = var.IC_SCHEMATICS_WORKSPACE_ID
}
