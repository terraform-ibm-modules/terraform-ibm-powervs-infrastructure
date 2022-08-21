variable "pvs_zone" {
  description = "IBM Cloud PowerVS Zone. Valid values: sao01,osa21,tor01,us-south,dal12,us-east,tok04,lon04,lon06,eu-de-1,eu-de-2,syd04,syd05"
  type        = string
  default     = "syd04"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example"
  default     = "Default"
}

variable "prefix" {
  description = "Prefix for resources which will be created."
  type        = string
  default     = "pvs"
}

variable "pvs_service_name" {
  description = "Name of IBM Cloud PowerVS service which will be created"
  type        = string
  default     = "power-service"
}

variable "pvs_sshkey_name" {
  description = "Name of IBM Cloud PowerVS SSH Key which will be created"
  type        = string
  default     = "ssh-key-pvs"
}

variable "pvs_management_network" {
  description = "IBM Cloud PowerVS Management Subnet name and cidr which will be created."
  type        = map(any)
  default = {
    "name" = "mgmt_net"
    "cidr" = "10.51.0.0/24"
  }
}

variable "pvs_backup_network" {
  description = "IBM Cloud PowerVS Backup Network name and cidr which will be created."
  type        = map(any)
  default = {
    "name" = "bkp_net"
    "cidr" = "10.52.0.0/24"
  }
}

variable "transit_gateway_name" {
  description = "Name of the existing transit gateway. Existing name must be provided when you want to create new cloud connections."
  type        = string
  default     = null
}

variable "reuse_cloud_connections" {
  description = "When the value is true, cloud connections will be reused (and is already attached to Transit gateway)"
  type        = bool
  default     = true
}

variable "cloud_connection_count" {
  description = "Required number of Cloud connections which will be created/Reused. Maximum is 2 per location"
  type        = string
  default     = 0
}

variable "cloud_connection_speed" {
  description = "Speed in megabits per sec. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when creating new connection"
  type        = string
  default     = "5000"
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud Api Key"
  sensitive   = true
  type        = string
}

variable "access_host_or_ip" {
  description = "Jump/Access server public host name or IP address. This host name/IP is used to reach the landscape."
  type        = string
  default     = "not_used"
}

variable "private_services_host_or_ip" {
  description = "Private IP address where management services should be configured. Not used here."
  type        = string
  default     = "not_used"
}

variable "internet_services_host_or_ip" {
  description = "Private IP address where internet services (like proxy) should be configured. Not used here."
  type        = string
  default     = "not_used"
}

variable "configure_proxy" {
  description = "Proxy is required to establish connectivity from PowerVS VSIs to the public internet. Do not configure proxy in this example by default."
  type        = bool
  default     = false
}

variable "configure_ntp_forwarder" {
  description = "NTP is required to sync time over time server not reachable directly from PowerVS VSIs. Do not configure NTP forwarder in this example by default."
  type        = bool
  default     = false
}

variable "configure_dns_forwarder" {
  description = "DNS is required to configure DNS resolution over server that is not reachable directly from PowerVS VSIs. Do not configure DNS forwarder in this example by default."
  type        = bool
  default     = false
}

variable "configure_nfs_server" {
  description = "NFS server may be used to provide shared FS for PowerVS VSIs. Do not configure NFS server in this example by default."
  type        = bool
  default     = false
}


#####################################################
# Optional Parameters
#####################################################

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
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
  description = "Configure SQUID proxy to use with IBM Cloud PowerVS instances."
  type        = map(any)
  default = {
    squid_proxy_host_or_ip = null
  }
}

variable "dns_forwarder_config" {
  description = "Configure DNS forwarder to existing DNS service that is not reachable directly from PowerVS."
  type        = map(any)
  default = {
    dns_forwarder_host_or_ip = null
    dns_servers              = "161.26.0.7; 161.26.0.8; 9.9.9.9;"
  }
}

variable "ntp_forwarder_config" {
  description = "Configure NTP forwarder to existing NTP service that is not reachable directly from PowerVS."
  type        = map(any)
  default = {
    ntp_forwarder_host_or_ip = null
  }
}

variable "nfs_server_config" {
  description = "Configure shared NFS file system (e.g., for installation media)."
  type        = map(any)
  default = {
    nfs_server_host_or_ip = null
    nfs_directory         = "/nfs"
  }
}
