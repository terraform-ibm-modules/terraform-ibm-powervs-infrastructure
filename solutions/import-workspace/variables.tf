##############################################################
# Parameters for VPC VSIs and Transit Gateway
##############################################################

variable "access_host" {
  description = "Name of the existing access host VSI and its floating ip. Acls will be added to allow schematics IPs to the corresponding VPC."
  type = object({
    vsi_name    = string
    floating_ip = string
  })
}

variable "proxy_server_ip_port" {
  description = "Existing Proxy Server IP and port. This will be required to configure internet access for PowerVS instances."
  type = object({
    vsi_ip = string
    port   = number
  })
  validation {
    condition     = 0 < var.proxy_server_ip_port.port && var.proxy_server_ip_port.port <= 65535
    error_message = "The entered proxy server port is invalid. Enter a port number between 1-65535."
  }
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

variable "powervs_workspace_guid" {
  description = "Name of the existing PowerVS workspace."
  type        = string
}

variable "powervs_sshkey_name" {
  description = "SSH public key name used for the existing PowerVS workspace."
  type        = string
}

variable "powervs_management_network_name" {
  description = "Name of the existing subnet used for management network in existing PowerVS workspace."
  type        = string
}

variable "powervs_backup_network_name" {
  description = "Name of the existing subnet used for backup network in existing PowerVS workspace."
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

variable "dns_server_ip" {
  description = "DNS server IP address."
  type        = string
  default     = ""
}

variable "ntp_server_ip" {
  description = "NTP server IP address."
  type        = string
  default     = ""
}

variable "nfs_server_ip_path" {
  description = "NFS server IP address and Path. If the NFS server VSI name is provided, the nfs path should not be empty and must begin with '/' character. For example: nfs_server_ip_path = {\"vsi_ip\"   = \"10.20.10.4\", \"nfs_path\" = \"/nfs\"}"
  type = object({
    vsi_ip   = string
    nfs_path = string
  })
  default = {
    "vsi_ip" : "",
    "nfs_path" : ""
  }
  validation {
    condition     = (var.nfs_server_ip_path.vsi_ip == "") || (var.nfs_server_ip_path.vsi_ip != "" && var.nfs_server_ip_path.nfs_path != "" && startswith(var.nfs_server_ip_path.nfs_path, "/"))
    error_message = "Provided nfs path is invalid. When the NFS server VSI name is provided, the nfs path should not be empty and it must begin with '/' character."
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
