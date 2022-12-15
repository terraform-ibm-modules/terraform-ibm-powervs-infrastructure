variable "ibmcloud_api_key" {
  description = "IBM Cloud api key."
  type        = string
  sensitive   = true
}

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created. Following locations are currently supported: syd04, syd05, eu-de-1, eu-de-2, tok04, osa21, sao01, lon04, lon06"
  type        = string
}

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
}

variable "prefix" {
  description = "Unique prefix for resources to be created."
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH Key that should be used in IBM PowerVS infrastructure."
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh_public_key'. Entered data must be in [heredoc strings format] (https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. Read [here] more about SSH keys in IBM Cloud (https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)."
  type        = string
  sensitive   = true
}

variable "reuse_cloud_connections" {
  description = "When true, IBM Cloud connections are reused (if attached to the transit gateway)."
  type        = bool
  default     = false
}

variable "transit_gateway_name" {
  description = "Name of the existing transit gateway. Required when you create new IBM Cloud connections. Set it to null if reusing cloud connections"
  type        = string
}

variable "access_host_or_ip" {
  description = "The public IP address or hostname for the access host. The address is used to reach the target or server_host IP address and to configure the DNS, NTP, NFS, and Squid proxy services. Set it to null if you do not want to configure any services."
  type        = string
}

variable "internet_services_host_or_ip" {
  description = "Host name or IP address of the virtual server instance where proxy server to public internet and to IBM Cloud services will be configured. Set it to null if you do not want to configure any services."
  type        = string
}

variable "private_services_host_or_ip" {
  description = "Default private host name or IP address of the virtual server instance where private services should be configured (DNS forwarder, NTP forwarder, NFS server). Might be empty when no services will be installed. Might be overwritten in the optional service specific configurations (in order to install services on different hosts). Set it to null if you do not want to configure any services."
  type        = string
}

variable "configure_proxy" {
  description = "Specify if proxy will be configured. Proxy is mandatory for the landscape, so set this to 'false' only if proxy already exists. Proxy will allow to communcate from IBM PowerVS instances with IBM Cloud network and with public internet."
  type        = bool
}

variable "configure_dns_forwarder" {
  description = "Specify if DNS forwarder will be configured. This will allow you to use central DNS servers (e.g. IBM Cloud DNS servers) sitting outside of the created IBM PowerVS infrastructure. If yes, ensure 'dns_forwarder_config' optional variable is set properly."
  type        = bool
}

variable "configure_ntp_forwarder" {
  description = "Specify if NTP forwarder will be configured. This will allow you to synchronize time between IBM PowerVS instances. If yes, ensure 'ntp_forwarder_config' optional variable is set properly."
  type        = bool
}

variable "configure_nfs_server" {
  description = "Specify if NFS server will be configured. This will allow you easily to share files between PowerVS instances (e.g., SAP installation files). If yes, ensure 'nfs_config' optional variable is set properly."
  type        = bool
}

#####################################################
# Optional Parameters
#####################################################

variable "powervs_management_network" {
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

variable "powervs_backup_network" {
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

variable "tags" {
  description = "List of Tag names for PowerVS workspace"
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
    squid_port        = string
  })
  default = {
    "server_host_or_ip" = ""
    "squid_port"        = "3128"
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
  description = "Configuration for the shared NFS file system (for example, for the installation media). Creates a filesystem of disk size specified, mounts and NFS exports it."
  type = object({
    server_host_or_ip = string
    nfs_file_system = list(object({
      name       = string
      mount_path = string
      size       = number
    }))
  })
  default = {
    "server_host_or_ip" = ""
    "nfs_file_system"   = [{ name = "nfs", mount_path : "/nfs", size : 1000 }]
  }
}

variable "powervs_image_names" {
  description = "List of Images to be imported into cloud account from catalog images"
  type        = list(string)
  default     = ["SLES15-SP3-SAP", "SLES15-SP3-SAP-NETWEAVER", "RHEL8-SP4-SAP", "RHEL8-SP4-SAP-NETWEAVER"]
}
