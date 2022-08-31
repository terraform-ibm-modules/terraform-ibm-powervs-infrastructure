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

variable "pvs_subnet_names" {
  description = "List of IBM Cloud PowerVS subnet names to be attached to Cloud connection"
  type        = list(any)
}

variable "cloud_connection_count" {
  description = "Number of cloud connections where private networks should be attached to. Default is to use redundant cloud connection pair."
  type        = number
  default     = 2
}
