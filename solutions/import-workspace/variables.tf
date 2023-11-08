variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

##############################################################
################## VPC LANDING ZONE VALUES ###################
##############################################################

variable "access_host" {
  description = "Access host name and floating ip."
  type = object({
    name        = string
    floating_ip = string
  })
}

variable "proxy_host" {
  description = "Proxy server name and port."
  type = object({
    name = string
    port = string
  })
}

# QUESTION: what if their services of ntp, nfs & dns are running on different servers?
variable "workload_host" {
  description = "Workload host InameP."
  type = object({
    name     = string
    nfs_path = string
  })
}

variable "transit_gateway_name" {
  description = "The name of the transit gateway."
  type        = string
}

##############################################################
########### POWER VIRTUAL SERVER WORKSPACE VALUES ############
##############################################################

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created."
  type        = string
}

variable "powervs_workspace_name" {
  description = "PowerVS infrastructure workspace name."
  type        = string
}

variable "powervs_sshkey_name" {
  description = "SSH public key name in created PowerVS infrastructure."
  type        = string
}

variable "powervs_management_network_name" {
  description = "Name of management network in created PowerVS infrastructure."
  type        = string
}

variable "powervs_backup_network_name" {
  description = "Name of backup network in created PowerVS infrastructure."
  type        = string
}

# how should we fetch the ssh key, floating?
# Can this be retrieved automatically?
/*variable "transit_gateway_name" {
  description = "Jump host IP."
  type        = string
}*/
