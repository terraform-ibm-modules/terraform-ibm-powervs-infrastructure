variable "vsi_name" {
  description = "Name of the existing VSI"
  type        = string
}

variable "fip" {
  description = "The object contains a boolean value which indicates whether a floating IP is attched to the VSI and if true, the concerned floating IP attached to the VSI must be provided."
  type = object({
    is_attached  = bool
    attached_fip = string
  })
  default = {
    is_attached  = false
    attached_fip = ""
  }
  validation {
    condition     = var.fip.is_attached ? var.fip.attached_fip != "" ? true : false : true
    error_message = "For object fip, if 'is_attached' is true then 'attached_fip' value must not be empty."
  }
}
