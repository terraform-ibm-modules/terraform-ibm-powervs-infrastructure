variable "pvs_zone" {
  description = "IBM PowerVS Cloud Zone"
  type        = string
}

variable "pvs_resource_group_name" {
  description = "Existing Resource Group Name"
  type        = string
}

variable "pvs_service_name" {
  description = "Existing PowerVS Service Name"
  type        = string
}

variable "pvs_subnet_names" {
  description = "List of PowerVs subnet names to be attached to Cloud connection"
  type        = list(any)
}

variable "cloud_connection_count" {
  description = "Required number of Cloud connections which will be created. Ignore when Transit gateway is empty. Maximum is 2 per location"
  type        = string
  default     = 2
}
