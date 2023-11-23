variable "sg_rules" {
  description = "List of Security Group rules which will be created."
  type = list(object({
    name      = string
    direction = string
    source    = optional(string)
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
  description = "An existing VPC's existing security group id to which rules will be added."
  type        = string
}
