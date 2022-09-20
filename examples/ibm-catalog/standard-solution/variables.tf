variable "prerequisite_workspace_id" {
  description = "IBM Cloud Schematics workspace ID of an existing deployment of secure infrastructure on VPC for regulated industries with VSIs. If you do not have an existing deployment, click [here](https://cloud.ibm.com/catalog/content/slz-vpc-with-vsis-a87ed9a5-d130-47a3-980b-5ceb1d4f9280-global#create) to create one. Note that a specific  configuration is needed for the deployment. You might find it [here](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/examples/ibm-catalog/standard-solution/slz_json_configs_for_powervs/vpc_landscape_config.json). Copy that configuration into the `override_json_string` deployment value."
  type        = string
}

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created. The following locations are currently supported: syd04, syd05, eu-de-1, eu-de-2, lon04, lon06, wdc04, us-east, us-south, dal12, dal13, tor01, tok04, osa21, sao01, mon01"
  type        = string
  validation {
    condition     = contains(["syd04", "syd05", "eu-de-1", "eu-de-2", "lon04", "lon06", "wdc04", "us-east", "us-south", "dal12", "dal13", "tor01", "tok04", "osa21", "sao01", "mon01"], var.powervs_zone)
    error_message = "Supported values for powervs_zone are: syd04, syd05, eu-de-1, eu-de-2, lon04, lon06, wdc04, us-east, us-south, dal12, dal13, tor01, tok04, osa21, sao01, mon01."
  }
}

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key used to log in to IBM PowerVS instances. Should match the uploaded public SSH key referenced by 'ssh_public_key'. Entered data must be in heredoc string format (https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information, see SSH keys in the IBM Cloud docs at https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys."
  type        = string
  sensitive   = true
}

variable "powervs_management_network" {
  description = "Name of the IBM Cloud PowerVS management subnet and CIDR to create."
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
  description = "Name of the IBM Cloud PowerVS backup network and CIDR to create."
  type = object({
    name = string
    cidr = string
  })
  default = {
    name = "bkp_net"
    cidr = "10.52.0.0/24"
  }
}

variable "reuse_cloud_connections" {
  description = "Whether IBM Cloud connections are reused (if attached to the transit gateway)."
  type        = bool
  default     = false
}

variable "configure_proxy" {
  description = "Whether the proxy will be configured. A proxy is mandatory for the landscape, so set this to 'false' only if a proxy already exists. The Proxy allows communication from IBM PowerVS instances in the IBM Cloud network with the public internet."
  type        = bool
  default     = true
}

variable "configure_dns_forwarder" {
  description = "Whether the DNS forwarder will be configured so that you can use central DNS servers (for example, IBM Cloud DNS servers) outside the created IBM PowerVS infrastructure. If set to true, make sure that  'dns_forwarder_config' optional variable is set properly."
  type        = bool
  default     = true
}

variable "configure_ntp_forwarder" {
  description = "Whether the NTP forwarder will be configured so that you can synchronize time between IBM PowerVS instances. If set to true, make sure that the 'ntp_forwarder_config' optional variable is set properly."
  type        = bool
  default     = true
}

variable "configure_nfs_server" {
  description = "Whether the NFS server will be configured so that you can share files between PowerVS instances (for example, SAP installation files). If set to true, make sure that the 'nfs_config' optional variable is set properly."
  type        = bool
  default     = true
}

variable "cloud_connection_count" {
  description = "Required number of IBM Cloud connections to create or reuse. The maximum number of connections is two per location."
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
  default     = ["sap"]
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
  description = "Configuration for the Squid proxy to a DNS service that is not reachable directly from PowerVS"
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

variable "powervs_image_names" {
  description = "List of images to be imported into cloud account from catalog images"
  type        = list(string)
  default     = ["SLES15-SP3-SAP", "SLES15-SP3-SAP-NETWEAVER", "RHEL8-SP4-SAP", "RHEL8-SP4-SAP-NETWEAVER"]
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key"
  type        = string
  default     = null
  sensitive   = true
}
