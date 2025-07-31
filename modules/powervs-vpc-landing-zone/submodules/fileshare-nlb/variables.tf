variable "resource_group_id" {
  description = "The ID of the resource group to use."
  type        = string
}

variable "vpc_zone" {
  description = "The globally unique name for this zone."
  type        = string
}

variable "file_share_name" {
  description = "The user-defined name for this share target. Names must be unique within the share the share target resides in."
  type        = string
}

variable "file_share_size" {
  description = "The size of the file share rounded up to the next gigabyte."
  type        = number
}

variable "file_share_iops" {
  description = "The maximum input/output operation performance bandwidth per second for the file share."
  type        = number
}

variable "file_share_mount_target_name" {
  description = "The user-defined name for this share target. Names must be unique within the share the share target resides in."
  type        = string
}

variable "file_share_subnet_id" {
  description = "The subnet id of the virtual network interface for the share mount target."
  type        = string
}

variable "file_share_security_group_ids" {
  description = "List of security group ids to be attached."
  type        = list(string)
}

variable "nlb_name" {
  description = "The user-defined name for this load balancer pool."
  type        = string
}

variable "nlb_subnet_ids" {
  description = "The ID of the subnets to provision this load balancer."
  type        = list(string)
}

variable "nlb_security_group_ids" {
  description = "A list of security groups that are used with this load balancer."
  type        = list(string)
}

variable "routing_table_name" {
  description = "Name of the routing table that contains the routes for NFS over Network Load Balancer."
  type        = string
}
