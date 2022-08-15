variable "pvs_zone" {
  description = "IBM Cloud PowerVS Zone"
  type        = string
}

variable "pvs_resource_group_name" {
  description = "Existing Resource Group Name"
  type        = string
}

variable "pvs_service_name" {
  description = "Name of IBM Cloud PowerVS service which will be created"
  type        = string
}

variable "pvs_sshkey_name" {
  description = "Name of IBM Cloud PowerVS SSH Key which will be created"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH Key for PowerVM creation"
  type        = string
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

variable "transit_gw_name" {
  description = "Name of the existing transit gateway. If empty / null, cloud connections will be reused"
  type        = string
  default     = null
}

variable "cloud_connection_count" {
  description = "Required number of Cloud connections which will be created. Ignore when Transit gateway is empty. Maximum is 2 per location"
  type        = string
  default     = 2
}

variable "cloud_connection_speed" {
  description = "Speed in megabits per sec. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when creating new connection"
  type        = string
  default     = null
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
