variable "sg_rules" {
  description = "List of Security Group rules"
  type = list(object({
    name      = string
    direction = string
    remote    = optional(string)
    tcp = optional(object({
      port_max = optional(string)
      port_min = optional(string)
    }))
    udp = optional(object({
      port_max = optional(string)
      port_min = optional(string)
    }))
    icmp = optional(object({
      type = optional(string)
      code = optional(string)
    }))
  }))
}

variable "sg_id" {
  description = "VPC's network ACL id"
  type        = string
}
