variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

##############################################################
# Parameters for VPC VSIs and Transit Gateway
##############################################################

variable "access_host" {
  description = "Name of the existing access host VSI and its floating ip."
  type = object({
    vsi_name    = string
    floating_ip = string
  })
  default = {
    "vsi_name" : "",
    "floating_ip" : ""
  }
}

variable "proxy_host" {
  description = "Name of the existing VSI on which proxy server is configured and proxy server port."
  type = object({
    vsi_name = string
    port     = string
  })
  default = {
    "vsi_name" : "",
    "port" : ""
  }
}

variable "workload_host" {
  description = "Name of the existing workload host VSI name and NFS path."
  type = object({
    vsi_name = string
    nfs_path = string
  })
  default = {
    "vsi_name" : "",
    "nfs_path" : ""
  }
}

variable "transit_gateway_name" {
  description = "The name of the transit gateway that connects the existing VPCs and PowerVS Workspace."
  type        = string
}

##############################################################
# Parameters for PowerVS Workspace
##############################################################

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS Workspace is created."
  type        = string
}

variable "powervs_workspace_name" {
  description = "Name of the existing PowerVS Workspace."
  type        = string
}

variable "powervs_sshkey_name" {
  description = "SSH public key name used for the existing PowerVS Workspace."
  type        = string
}

variable "powervs_management_network_name" {
  description = "Name of management network in existing PowerVS Workspace."
  type        = string
}

variable "powervs_backup_network_name" {
  description = "Name of backup network in existing PowerVS Workspace."
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
