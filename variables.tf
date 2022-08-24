variable "pvs_zone" {
  description = "IBM Cloud PowerVS Zone"
  type        = string
}

variable "pvs_resource_group_name" {
  description = "Existing Resource Group Name"
  type        = string
}

variable "pvs_service_name" {
  description = "Name of PowerVS service which will be created"
  type        = string
  default     = "power-service"
}

variable "pvs_sshkey_name" {
  description = "Name of PowerVS SSH Key which will be created"
  type        = string
  default     = "ssh-key-pvs"
}

variable "ssh_public_key" {
  description = "Public SSH Key for PowerVM creation"
  type        = string
  sensitive   = true
}

variable "ssh_private_key" {
  description = "SSh private key value to login to server. It will not be uploaded / stored anywhere."
  type        = string
  sensitive   = true
}

variable "pvs_management_network" {
  description = "IBM Cloud PowerVS Management Subnet name and cidr which will be created"
  type        = map(any)
  default = {
    name = "mgmt_net"
    cidr = "10.51.0.0/24"
  }
}

variable "pvs_backup_network" {
  description = "IBM Cloud PowerVS Backup Network name and cidr which will be created"
  type        = map(any)
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

variable "reuse_cloud_connections" {
  description = "When the value is true, cloud connections will be reused (and is already attached to Transit gateway)"
  type        = bool
  default     = false
}

variable "cloud_connection_count" {
  description = "Required number of Cloud connections which will be created/Reused. Maximum is 2 per location"
  type        = string
  default     = 2
}

variable "cloud_connection_speed" {
  description = "Speed in megabits per sec. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when creating new connection"
  type        = string
  default     = 5000
}

#####################################################
# Optional Parameters
#####################################################

variable "tags" {
  description = "List of Tag names for IBM Cloud PowerVS service"
  type        = list(string)
  default     = null
}

variable "cloud_connection_gr" {
  description = "Enable global routing for this cloud connection.Can be specified when creating new connection"
  type        = bool
  default     = null
}

variable "cloud_connection_metered" {
  description = "Enable metered for this cloud connection. Can be specified when creating new connection"
  type        = bool
  default     = null
}

variable "access_host_or_ip" {
  description = "Jump/Bastion server Public IP to reach the target/server_host ip to configure the DNS,NTP,NFS,SQUID services"
  type        = string
}

variable "squid_config" {
  description = "Configure DNS forwarder to existing DNS service that is not reachable directly from PowerVS"
  type        = map(any)
  default = {
    "squid_enable"      = "false"
    "server_host_or_ip" = "inet-svs"
  }
}

variable "dns_forwarder_config" {
  description = "Configure DNS forwarder to existing DNS service that is not reachable directly from PowerVS"
  type        = map(any)
  default = {
    "dns_enable"        = "false"
    "server_host_or_ip" = "inet-svs"
    "dns_servers"       = "161.26.0.7; 161.26.0.8; 9.9.9.9;"
  }
}

variable "ntp_forwarder_config" {
  description = "Configure NTP forwarder to existing NTP service that is not reachable directly from PowerVS"
  type        = map(any)
  default = {
    "ntp_enable"        = "false"
    "server_host_or_ip" = "inet-svs"
  }
}

variable "nfs_config" {
  description = "Configure shared NFS file system (e.g., for installation media)"
  type        = map(any)
  default = {
    "nfs_enable"        = "true"
    "server_host_or_ip" = "private-svs"
    "nfs_directory"     = "/nfs"
  }
}

variable "perform_proxy_client_setup" {
  description = "Configures a Vm/Lpar to have internet access by setting proxy on it."
  type = object(
    {
      squid_client_ips = list(string)
      squid_server_ip  = string
      no_proxy_env     = string
    }
  )
  default = null
}
