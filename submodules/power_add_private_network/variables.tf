variable "pvs_zone" {
  description = "IBM Cloud PowerVS Zone."
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

variable "pvs_additional_network" {
  description = "IBM Cloud PowerVS Management Subnet name and cidr which will be created."
  type        = map(any)
}
