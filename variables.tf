variable "pvs_zone" {
  description = "IBM Cloud PowerVS zone"
  type        = string
}

variable "pvs_resource_group_name" {
  description = "Existing resource group name"
  type        = string
}

variable "pvs_service_name" {
  description = "Name of the PowerVS service to create"
  type        = string
  default     = "power-service"
}

variable "pvs_sshkey_name" {
  description = "Name of the PowerVS SSH key to create"
  type        = string
  default     = "ssh-key-pvs"
}

variable "ssh_public_key" {
  description = "Public SSH Key for the PowerVM to create"
  type        = string
  sensitive   = true
}

variable "ssh_private_key" {
  description = "Private SSH key used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh_public_key'. Entered data must be in heredoc strings format (https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored."
  type        = string
  sensitive   = true
}

variable "pvs_management_network" {
  description = "Name of the IBM Cloud PowerVS management subnet and CIDR to create"
  type = object({
    name = string
    cidr = string
  })
  default = {
    name = "mgmt_net"
    cidr = "10.51.0.0/24"
  }
}

variable "pvs_backup_network" {
  description = "Name of the IBM Cloud PowerVS backup network and CIDR to create"
  type = object({
    name = string
    cidr = string
  })
  default = {
    name = "bkp_net"
    cidr = "10.52.0.0/24"
  }
}

variable "transit_gateway_name" {
  description = "Name of the existing transit gateway. Required when you create new IBM Cloud connections."
  type        = string
  default     = null
}

variable "reuse_cloud_connections" {
  description = "When true, IBM Cloud connections are reused (if attached to the transit gateway)."
  type        = bool
  default     = false
}

variable "cloud_connection_count" {
  description = "Required number of Cloud connections to create or reuse. The maximum number of connections is two per location."
  type        = number
  default     = 2
}

variable "cloud_connection_speed" {
  description = "Speed in megabits per second. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when you create a connection."
  type        = number
  default     = 5000
}

#####################################################
# Optional Parameters
#####################################################

variable "tags" {
  description = "List of tag names for the IBM Cloud PowerVS service"
  type        = list(string)
  default     = null
}

variable "pvs_image_names" {
  description = "List of Images to be imported into cloud account from catalog images"
  type        = list(string)
  default     = ["SLES15-SP3-SAP", "SLES15-SP3-SAP-NETWEAVER", "RHEL8-SP4-SAP", "RHEL8-SP4-SAP-NETWEAVER"]
}

variable "cloud_connection_gr" {
  description = "Whether to enable global routing for this IBM Cloud connection. You can specify thia value when you create a connection."
  type        = bool
  default     = null
}

variable "cloud_connection_metered" {
  description = "Whether to enable metering for this IBM Cloud connection. You can specify thia value when you create a connection."
  type        = bool
  default     = null
}

variable "access_host_or_ip" {
  description = "The public IP address for the jump or Bastion server. The address is used to reach the target or server_host IP address and to configure the DNS, NTP, NFS, and Squid proxy services."
  type        = string
  default     = null
}

variable "squid_config" {
  description = "Configuration for the Squid proxy to a DNS service that is not reachable directly from PowerVS"
  type = object({
    squid_enable      = bool
    server_host_or_ip = string
  })
  default = {
    "squid_enable"      = "false"
    "server_host_or_ip" = "inet-svs"
  }
}

variable "dns_forwarder_config" {
  description = "Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS"
  type = object({
    dns_enable        = bool
    server_host_or_ip = string
    dns_servers       = string
  })
  default = {
    "dns_enable"        = "false"
    "server_host_or_ip" = "inet-svs"
    "dns_servers"       = "161.26.0.7; 161.26.0.8; 9.9.9.9;"
  }
}

variable "ntp_forwarder_config" {
  description = "Configuration for the NTP forwarder to an NTP service that is not reachable directly from PowerVS"
  type = object({
    ntp_enable        = bool
    server_host_or_ip = string
  })
  default = {
    "ntp_enable"        = "false"
    "server_host_or_ip" = "inet-svs"
  }
}

variable "nfs_config" {
  description = "Configuration for the shared NFS file system (for example, for the installation media)."
  type = object({
    nfs_enable        = bool
    server_host_or_ip = string
    nfs_directory     = string
  })
  default = {
    "nfs_enable"        = "true"
    "server_host_or_ip" = "private-svs"
    "nfs_directory"     = "/nfs"
  }
}

variable "perform_proxy_client_setup" {
  description = "Proxy configuration to allow internet access for a VM or LPAR."
  type = object(
    {
      squid_client_ips = list(string)
      squid_server_ip  = string
      no_proxy_env     = string
    }
  )
  default = null
}
