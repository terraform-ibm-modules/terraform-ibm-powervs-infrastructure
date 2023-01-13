variable "powervs_zone" {
  description = "IBM Cloud PowerVS Zone"
  type        = string
}

variable "powervs_resource_group_name" {
  description = "Existing Resource Group Name"
  type        = string
}

variable "powervs_workspace_name" {
  description = "Existing IBM Cloud PowerVS Workspace Name"
  type        = string
}

variable "transit_gateway_name" {
  description = "Name of the existing transit gateway. Required when creating new cloud connections"
  type        = string
}


variable "cloud_connection_name_prefix" {
  description = "If null or empty string, default cloud connection name will be <zone>-conn-1."
  type        = string
  default     = null
}

variable "cloud_connection_count" {
  description = "Required number of Cloud connections which will be created/Reused. Maximum is 2 per location"
  type        = number
}

variable "cloud_connection_speed" {
  description = "Speed in megabits per sec. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when creating new connection"
  type        = number
}

variable "cloud_connection_gr" {
  description = "Enable global routing for this cloud connection.Can be specified when creating new connection"
  type        = bool
}

variable "cloud_connection_metered" {
  description = "Enable metered for this cloud connection. Can be specified when creating new connection"
  type        = bool
}
