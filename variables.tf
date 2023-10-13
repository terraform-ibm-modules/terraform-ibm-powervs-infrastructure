variable "powervs_zone" {
  description = "IBM Cloud PowerVS zone."
  type        = string
  validation {
    condition     = contains(["syd04", "syd05", "eu-de-1", "eu-de-2", "lon04", "lon06", "us-east", "us-south", "dal10", "dal12", "tok04", "osa21", "sao01", "mon01", "tor01"], var.powervs_zone)
    error_message = "Only Following DC values are supported : syd04, syd05, eu-de-1, eu-de-2, lon04, lon06, us-east, us-south, dal10, dal12, tok04, osa21, sao01, mon01, tor01"
  }
}

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
}

variable "powervs_workspace_name" {
  description = "Name of the PowerVS workspace to create."
  type        = string
  default     = "power-workspace"
}

variable "powervs_sshkey_name" {
  description = "Name of the PowerVS SSH key to create."
  type        = string
  default     = "ssh-key-pvs"
}

variable "ssh_public_key" {
  description = "Public SSH Key for the PowerVM to create."
  type        = string
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

variable "transit_gateway_id" {
  description = "ID of the existing transit gateway. Required when you create new IBM Cloud connections(Non-PER DC) or to attach the PowerVS workspace to Transit Gateway(PER DC)."
  type        = string
}

variable "cloud_connection_name_prefix" {
  description = "If null or empty string, default cloud connection name will be <zone>-conn-1."
  type        = string
  default     = null
}

variable "cloud_connection_count" {
  description = "Required number of Cloud connections to create or reuse. The maximum number of connections is two per location."
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
  description = "List of tag names for the IBM Cloud PowerVS Workspace."
  type        = list(string)
  default     = null
}

variable "powervs_image_names" {
  description = "List of Images to be imported into cloud account from catalog images."
  type        = list(string)
  default     = ["SLES15-SP4-SAP", "SLES15-SP4-SAP-NETWEAVER", "RHEL8-SP6-SAP", "RHEL8-SP6-SAP-NETWEAVER"]
}

variable "cloud_connection_gr" {
  description = "Whether to enable global routing for this IBM Cloud connection. You can specify this value when you create a connection."
  type        = bool
  default     = null
}

variable "cloud_connection_metered" {
  description = "Whether to enable metering for this IBM Cloud connection. You can specify this value when you create a connection."
  type        = bool
  default     = null
}
