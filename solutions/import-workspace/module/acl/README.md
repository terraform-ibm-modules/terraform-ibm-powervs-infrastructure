# Module acl

## IBM Access Control List

This module creates the access rules in the Access Control List for the subnets of the respective VPCs and VSIs. It takes a list of ACL rules and a network ACL id as inputs.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 1.6 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.58.1 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_is_network_acl_rule.all_network_acl_rules](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_network_acl_rule) | resource |
| [ibm_is_network_acl_rule.deny_all_inbound](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_network_acl_rule) | resource |
| [ibm_is_network_acl_rule.deny_all_outbound](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_network_acl_rule) | resource |
| [ibm_is_network_acl_rules.existing_acl](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/is_network_acl_rules) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acl_rules"></a> [acl\_rules](#input\_acl\_rules) | List of ACL rules | <pre>list(object({<br>    name        = string<br>    action      = string<br>    direction   = string<br>    source      = string<br>    destination = string<br>    tcp = optional(object({<br>      port_max        = optional(string)<br>      port_min        = optional(string)<br>      source_port_max = optional(string)<br>      source_port_min = optional(string)<br>    }))<br>    udp = optional(object({<br>      port_max        = optional(string)<br>      port_min        = optional(string)<br>      source_port_max = optional(string)<br>      source_port_min = optional(string)<br>    }))<br>    icmp = optional(object({<br>      type = optional(string)<br>      code = optional(string)<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_ibm_is_network_acl_id"></a> [ibm\_is\_network\_acl\_id](#input\_ibm\_is\_network\_acl\_id) | VPC's network ACL id | `string` | n/a | yes |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
