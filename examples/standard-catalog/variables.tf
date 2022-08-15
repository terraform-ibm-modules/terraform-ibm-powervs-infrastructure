variable "slz_workspace_id" {
  description = "IBM cloud schematics workspace ID to reuse values from SLZ workspace"
  type        = string
  default     = null
}

variable "pvs_zone" {
  description = "IBM Cloud PVS Zone. Valid values: sao01,osa21,tor01,us-south,dal12,us-east,tok04,lon04,lon06,eu-de-1,eu-de-2,syd04,syd05"
  type        = string
}

variable "pvs_resource_group_name" {
  description = "Existing Resource Group Name"
  type        = string
}

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
  default     = "5000"
}

#####################################################
# Optional Parameters
#####################################################

variable "tags" {
  description = "List of Tag names for PowerVS service"
  type        = list(string)
  default     = null
}

variable "cloud_connection_gr" {
  description = "Enable global routing for this cloud connection.Can be specified when creating new connection"
  type        = bool
  default     = true
}

variable "cloud_connection_metered" {
  description = "Enable metered for this cloud connection. Can be specified when creating new connection"
  type        = bool
  default     = false
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud Api Key"
  type        = string
  default     = null
}
