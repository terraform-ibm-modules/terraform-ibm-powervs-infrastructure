variable "pvs_zone" {
  description = "IBM Cloud PowerVS Zone"
  type        = string
}

variable "pvs_resource_group_name" {
  description = "Existing Resource Group Name"
  type        = string
}

variable "pvs_service_name" {
  description = "Existing IBM Cloud PowerVS Service Name"
  type        = string
}

variable "transit_gw_name" {
  description = "Name of the existing transit gateway. If empty / null, cloud connections will be reused."
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
