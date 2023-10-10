variable "powervs_workspace_guid" {
  description = "Existing IBM Cloud PowerVS Workspace GUID."
  type        = string
}

variable "powervs_subnet_ids" {
  description = "List of IBM Cloud PowerVS subnet ids to be attached to Cloud connection. Maximum of 2 subnets in a list are supported."
  type        = list(any)
  validation {
    condition     = length(var.powervs_subnet_ids) > 2 ? false : true
    error_message = "Maximum length of list can be 2 only. Supports only 2 subnet ids."
  }
}

variable "cloud_connection_count" {
  description = "Number of cloud connections where private networks should be attached to. Default is to use redundant cloud connection pair."
  type        = number
}
