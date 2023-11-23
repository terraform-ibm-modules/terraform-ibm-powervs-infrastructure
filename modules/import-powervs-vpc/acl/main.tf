data "ibm_is_network_acl_rules" "existing_acl_ds" {
  network_acl = var.ibm_is_network_acl_id
}

locals {
  all_rules       = data.ibm_is_network_acl_rules.existing_acl_ds.rules
  inbound_rules   = [for rule in local.all_rules : rule if rule.direction == "inbound"]
  outbound_rules  = [for rule in local.all_rules : rule if rule.direction == "outbound"]
  inbound_before  = length(local.inbound_rules) > 0 ? local.inbound_rules[0].rule_id : null
  outbound_before = length(local.outbound_rules) > 0 ? local.outbound_rules[0].rule_id : null
}

resource "ibm_is_network_acl_rule" "all_network_acl_rules" {
  for_each    = { for rule in var.acl_rules : rule.name => rule if rule.action != "deny" }
  network_acl = var.ibm_is_network_acl_id
  name        = each.value.name
  action      = each.value.action
  before      = each.value.direction == "inbound" ? local.inbound_before : local.outbound_before
  source      = each.value.source
  destination = each.value.destination
  direction   = each.value.direction

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
      port_min        = lookup(each.value.tcp, "port_min", null)
      port_max        = lookup(each.value.tcp, "port_max", null)
      source_port_min = lookup(each.value.tcp, "source_port_min", null)
      source_port_max = lookup(each.value.tcp, "source_port_max", null)
    }
  }

  dynamic "udp" {
    for_each = contains(keys(each.value), "udp") && each.value.udp != null ? [1] : []
    content {
      port_min        = lookup(each.value.udp, "port_min", null)
      port_max        = lookup(each.value.udp, "port_max", null)
      source_port_min = lookup(each.value.udp, "source_port_min", null)
      source_port_max = lookup(each.value.udp, "source_port_max", null)
    }
  }
}

resource "ibm_is_network_acl_rule" "deny_all_outbound" {
  depends_on = [resource.ibm_is_network_acl_rule.all_network_acl_rules]

  network_acl = var.ibm_is_network_acl_id
  name        = "default-deny-outbound"
  action      = "deny"
  source      = "0.0.0.0/0"
  destination = "0.0.0.0/0"
  direction   = "outbound"
}
resource "ibm_is_network_acl_rule" "deny_all_inbound" {
  depends_on = [resource.ibm_is_network_acl_rule.all_network_acl_rules]

  network_acl = var.ibm_is_network_acl_id
  name        = "default-deny-inbound"
  action      = "deny"
  source      = "0.0.0.0/0"
  destination = "0.0.0.0/0"
  direction   = "inbound"
}
