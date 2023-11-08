variable "acl_rules" {
  description = "List of ACL rules"
  type = list(object({
    name        = string
    action      = string
    direction   = string
    source      = string
    destination = string
    tcp = optional(object({
      port_max        = optional(string)
      port_min        = optional(string)
      source_port_max = optional(string)
      source_port_min = optional(string)
    }))
    udp = optional(object({
      port_max        = optional(string)
      port_min        = optional(string)
      source_port_max = optional(string)
      source_port_min = optional(string)
    }))
    icmp = optional(object({
      type = optional(string)
      code = optional(string)
    }))
  }))
}

variable "ibm_is_network_acl_id" {
  description = "VPC's network ACL id"
  type        = string
}
