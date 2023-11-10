variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

##############################################################
# Parameters for VPC VSIs and Transit Gateway
##############################################################

variable "access_host" {
  description = "Access host name and floating ip."
  type = object({
    name        = string
    floating_ip = string
  })
  default = {
    "name" : "",
    "floating_ip" : ""
  }
}

variable "proxy_host" {
  description = "Proxy server name and port."
  type = object({
    name = string
    port = string
  })
  default = {
    "name" : "",
    "port" : ""
  }
}

variable "workload_host" {
  description = "Workload host InameP."
  type = object({
    name     = string
    nfs_path = string
  })
  default = {
    "name" : "",
    "nfs_path" : ""
  }
}

variable "transit_gateway_name" {
  description = "The name of the transit gateway."
  type        = string
}

##############################################################
# Parameters for PowerVS Workspace
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

##############################################################
# Schematics Output
##############################################################

# tflint-ignore: all
variable "IC_SCHEMATICS_WORKSPACE_ID" {
  default     = ""
  type        = string
  description = "leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace."
}
