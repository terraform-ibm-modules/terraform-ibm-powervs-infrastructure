variable "ibmcloud_api_key" {
  description = "IBM Cloud Api Key"
  type        = string
  default     = null
  sensitive   = true
}

variable "pvs_zone" {
  description = "IBM Cloud zone for PowerVS service. Valid values: IBM Cloud PVS Zone. Valid values: syd04,syd05,eu-de-1,eu-de-2,lon04,lon06,wdc04,us-east,us-south,dal12,dal13,tor01,tok04,osa21,sao01,mon01"
  type        = string
}

variable "pvs_resource_group_name" {
  description = "Existing resource group name"
  type        = string
}

variable "prefix" {
  description = "Unique prefix for resources to be created."
  type        = string
}

variable "ssh_private_key" {
  description = "SSH private key value to login to servers. It will not be uploaded / stored anywhere."
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Public SSH Key for the PowerVM to create"
  type        = string
}

variable "reuse_cloud_connections" {
  description = "When true, IBM Cloud connections are reused (if attached to the transit gateway)."
  type        = bool
  default     = false
}

variable "access_host_or_ip" {
  description = "The public IP address for the jump or Bastion server. The address is used to reach the target or server_host IP address and to configure the DNS, NTP, NFS, and Squid proxy services."
  type        = string
}

variable "internet_services_host_or_ip" {
  description = "Host name or IP address of the virtual server instance where proxy server to public internet and to IBM Cloud services will be configured."
  type        = string
  default     = null
}

variable "private_services_host_or_ip" {
  description = "Default private host name or IP address of the virtual server instance where private services should be configured (DNS forwarder, NTP forwarder, NFS server). Might be empty when no services will be installed. Might be overwritten in the optional service specific configurations (in order to install services on different hosts)."
  type        = string
  default     = null
}

variable "configure_proxy" {
  description = "Specify if SQUID proxy will be configured. Proxy is mandatory for the landscape, so set this to 'false' only if proxy already exists."
  type        = bool
  default     = true
}

variable "configure_dns_forwarder" {
  description = "Specify if DNS forwarder will be configured. If yes, ensure 'dns_forwarder_config' optional variable is set properly."
  type        = bool
  default     = true
}

variable "configure_ntp_forwarder" {
  description = "Specify if NTP forwarder will be configured. If yes, ensure 'ntp_forwarder_config' optional variable is set properly."
  type        = bool
  default     = true
}

variable "configure_nfs_server" {
  description = "Specify if NFS will be configured. If yes, ensure 'nfs_config' optional variable is set properly."
  type        = bool
  default     = true
}

#####################################################
# Optional Parameters
#####################################################

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
  description = "Name of the existing transit gateway. Required when creating new cloud connections"
  type        = string
  default     = null
}

variable "tags" {
  description = "List of Tag names for PowerVS service"
  type        = list(string)
  default     = null
}

variable "cloud_connection_speed" {
  description = "Speed in megabits per second. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when you create a connection."
  type        = number
  default     = 5000
}

variable "cloud_connection_count" {
  description = "Required number of Cloud connections to create or reuse. The maximum number of connections is two per location."
  type        = number
  default     = 2
}

variable "cloud_connection_gr" {
  description = "Whether to enable global routing for this IBM Cloud connection. You can specify thia value when you create a connection."
  type        = bool
  default     = true
}

variable "cloud_connection_metered" {
  description = "Whether to enable metering for this IBM Cloud connection. You can specify thia value when you create a connection."
  type        = bool
  default     = false
}

variable "squid_config" {
  description = "Configuration for the Squid proxy setup"
  type = object({
    server_host_or_ip = string
  })
  default = {
    "server_host_or_ip" = ""
  }
}

variable "dns_forwarder_config" {
  description = "Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS"
  type = object({
    server_host_or_ip = string
    dns_servers       = string
  })
  default = {
    "server_host_or_ip" = ""
    "dns_servers"       = "161.26.0.7; 161.26.0.8; 9.9.9.9;"
  }
}

variable "ntp_forwarder_config" {
  description = "Configuration for the NTP forwarder to an NTP service that is not reachable directly from PowerVS"
  type = object({
    server_host_or_ip = string
  })
  default = {
    "server_host_or_ip" = ""
  }
}

variable "nfs_config" {
  description = "Configuration for the shared NFS file system (for example, for the installation media)."
  type = object({
    server_host_or_ip = string
    nfs_directory     = string
  })
  default = {
    "server_host_or_ip" = ""
    "nfs_directory"     = "/nfs"
  }
}

variable "pvs_image_names" {
  description = "List of Images to be imported into cloud account from catalog images"
  type        = list(string)
  default     = ["SLES15-SP3-SAP", "SLES15-SP3-SAP-NETWEAVER", "RHEL8-SP4-SAP", "RHEL8-SP4-SAP-NETWEAVER"]
}
