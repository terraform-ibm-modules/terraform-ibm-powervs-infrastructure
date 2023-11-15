variable "vsi_name" {
  description = "The VSI name on VPC side."
  type        = string
}

variable "fip_enabled" {
  description = "This values indicates whether a floating IP is attched to it."
  type        = bool
  default     = false
}

variable "attached_fip" {
  description = "The floating IP attached to the VSI."
  type        = string
  default     = ""
}
