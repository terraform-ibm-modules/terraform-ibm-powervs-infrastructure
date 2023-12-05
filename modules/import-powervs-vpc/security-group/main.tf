resource "ibm_is_security_group_rule" "sg_rules" {
  for_each  = { for rule in var.sg_rules : rule.name => rule }
  group     = var.sg_id
  direction = each.value.direction
  remote    = each.value.source

  dynamic "icmp" {
    for_each = contains(keys(each.value), "icmp") && each.value.icmp != null ? [1] : []
    content {
      type = each.value.icmp.type
      code = each.value.icmp.code
    }
  }

  dynamic "tcp" {
    for_each = contains(keys(each.value), "tcp") && each.value.tcp != null ? [1] : []
    content {
      port_min = lookup(each.value.tcp, "port_min", null)
      port_max = lookup(each.value.tcp, "port_max", null)
    }
  }

  dynamic "udp" {
    for_each = contains(keys(each.value), "udp") && each.value.udp != null ? [1] : []
    content {
      port_min = lookup(each.value.udp, "port_min", null)
      port_max = lookup(each.value.udp, "port_max", null)
    }
  }
}
