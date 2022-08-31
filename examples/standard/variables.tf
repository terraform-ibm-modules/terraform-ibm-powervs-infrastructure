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
  description = "SSH public key value to store in IBM PowerVS service. This key will be used to configure SSH login to IBM Cloud PowerVS instances."
  type        = string
  sensitive   = true
}


variable "reuse_cloud_connections" {
  description = "When the value is true, cloud connections will be reused (and is already attached to Transit gateway). Otherwise, transit gateway name  in optional parameters must be specified."
  type        = bool
  default     = false
}

variable "configure_proxy" {
  description = "Specify if SQUID proxy will be configured. If yes, ensure 'proxy_config' optional variable is set properly. Proxy is mandatory for the landscape, so set this to 'false' only if proxy already exists."
  type        = bool
  default     = true
}

variable "configure_ntp_forwarder" {
  description = "Specify if DNS forwarder will be configured. If yes, ensure 'dns_config' optional variable is set properly."
  type        = bool
  default     = true
}

variable "configure_nfs_server" {
  description = "Specify if DNS forwarder will be configured. If yes, ensure 'dns_config' optional variable is set properly."
  type        = bool
  default     = true
}

variable "configure_dns_forwarder" {
  description = "Specify if DNS forwarder will be configured. If yes, ensure 'dns_config' optional variable is set properly."
  type        = bool
  default     = false
}

variable "access_host_or_ip" {
  description = "Jump/Access server public host name or IP address. This host name/IP is used to reach the landscape."
  type        = string
}

variable "internet_services_host_or_ip" {
  description = "Host name or IP address of the virtual server instance where proxy server to public internet and to IBM Cloud services will be configured."
  type        = string
}

variable "private_services_host_or_ip" {
  description = "Default private host name or IP address of the virtual server instance where private services should be configured (DNS forwarder, NTP forwarder, NFS server). Might be empty when no services will be installed. Might be overwritten in the optional service specific configurations (in order to install services on different hosts)."
  type        = string
  default     = null
}

#####################################################
# Optional Parameters
#####################################################

variable "pvs_management_network" {
  description = "PowerVS Management Subnet name and cidr which will be created."
  type        = map(any)
  default = {
    "name" = "mgmt_net"
    "cidr" = "10.51.0.0/24"
  }
}

variable "pvs_backup_network" {
  description = "PowerVS Backup Network name and cidr which will be created."
  type        = map(any)
  default = {
    "name" = "bkp_net"
    "cidr" = "10.52.0.0/24"
  }
}

variable "tags" {
  description = "List of Tag names for PowerVS service"
  type        = list(string)
  default     = null
}

variable "transit_gateway_name" {
  description = "Name of the existing transit gateway. Required when creating new cloud connections"
  type        = string
  default     = null
}

variable "cloud_connection_speed" {
  description = "Speed in megabits per sec. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when creating new connection"
  type        = number
  default     = 5000
}

variable "cloud_connection_count" {
  description = "Required number of Cloud connections which will be created. Ignore when Transit gateway is empty. Maximum is 2 per location"
  type        = number
  default     = 2
}

variable "cloud_connection_gr" {
  description = "Enable global routing for this cloud connection. Can be specified when creating new connection"
  type        = bool
  default     = true
}

variable "cloud_connection_metered" {
  description = "Enable metered for this cloud connection. Can be specified when creating new connection"
  type        = bool
  default     = false
}

variable "squid_proxy_config" {
  description = "Configuration for the Squid proxy to a DNS service that is not reachable directly from PowerVS"
  type = object({
    squid_enable           = bool
    squid_proxy_host_or_ip = string
  })
  default = {
    "squid_enable"           = "false"
    "squid_proxy_host_or_ip" = ""
  }
}

variable "dns_forwarder_config" {
  description = "Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS"
  type = object({
    dns_enable               = bool
    dns_forwarder_host_or_ip = string
    dns_servers              = string
  })
  default = {
    "dns_enable"               = "false"
    "dns_forwarder_host_or_ip" = ""
    "dns_servers"              = "161.26.0.7; 161.26.0.8; 9.9.9.9;"
  }
}

variable "ntp_forwarder_config" {
  description = "Configuration for the NTP forwarder to an NTP service that is not reachable directly from PowerVS"
  type = object({
    ntp_enable               = bool
    ntp_forwarder_host_or_ip = string
  })
  default = {
    "ntp_enable"               = "false"
    "ntp_forwarder_host_or_ip" = ""
  }
}

variable "nfs_server_config" {
  description = "Configuration for the shared NFS file system (for example, for the installation media)."
  type = object({
    nfs_enable            = bool
    nfs_server_host_or_ip = string
    nfs_directory         = string
  })
  default = {
    "nfs_enable"            = "true"
    "nfs_server_host_or_ip" = ""
    "nfs_directory"         = "/nfs"
  }
}

variable "pvs_image_names" {
  description = "List of Images to be imported into cloud account from catalog images"
  type        = list(string)
  default     = ["SLES15-SP3-SAP", "SLES15-SP3-SAP-NETWEAVER", "RHEL8-SP4-SAP", "RHEL8-SP4-SAP-NETWEAVER"]
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud Api Key"
  type        = string
  default     = null
  sensitive   = true
}
