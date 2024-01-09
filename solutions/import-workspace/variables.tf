##############################################################
# Parameters for VPC VSIs and Transit Gateway
##############################################################

variable "vpc_region" {
  description = "IBM Cloud data center location where IBM VPCs exists."
  type        = string
}

variable "access_host" {
  description = "Name of the existing access host VSI and its floating ip."
  type = object({
    vsi_name    = string
    floating_ip = string
  })
}

variable "proxy_host" {
  description = "Name of the existing VSI on which proxy server is configured and proxy server port."
  type = object({
    vsi_name = string
    port     = string
  })
}

variable "transit_gateway_name" {
  description = "The name of the existing transit gateway that has VPCs and PowerVS workspace connected to it."
  type        = string
}

##############################################################
# Parameters for PowerVS workspace
##############################################################

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS workspace exists."
  type        = string
}

variable "powervs_workspace_name" {
  description = "Name of the existing PowerVS workspace."
  type        = string
}

variable "powervs_sshkey_name" {
  description = "SSH public key name used for the existing PowerVS workspace."
  type        = string
}

variable "powervs_management_network_name" {
  description = "Name of management network in existing PowerVS workspace."
  type        = string
}

variable "powervs_backup_network_name" {
  description = "Name of backup network in existing PowerVS workspace."
  type        = string
}

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

#####################################################
# Optional Parameters VSI OS Management Services
#####################################################

variable "dns_server" {
  description = "Name of the existing workload host VSI on which the DNS service is configured."
  type        = string
  default     = ""
}

variable "ntp_server" {
  description = "Name of the existing workload host VSI on which the NTP service is configured."
  type        = string
  default     = ""
}

variable "nfs_server" {
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

##############################################################
# Schematics Output
##############################################################

# tflint-ignore: all
variable "IC_SCHEMATICS_WORKSPACE_ID" {
  default     = ""
  type        = string
  description = "leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace."
}
