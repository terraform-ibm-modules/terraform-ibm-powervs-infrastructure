# Module security-group

## IBM Security Group

This module creates the Security Group(SG) rules in the for the VSIs in a VPC. It takes a list of SG rules and a SG id for VSIs as inputs.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 1.6 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | =1.54.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_is_security_group_rule.example](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.54.0/docs/resources/is_security_group_rule) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sg_id"></a> [sg\_id](#input\_sg\_id) | VPC's network ACL id | `string` | n/a | yes |
| <a name="input_sg_rules"></a> [sg\_rules](#input\_sg\_rules) | List of Security Group rules | <pre>list(object({<br>    name      = string<br>    direction = string<br>    remote    = optional(string)<br>    tcp = optional(object({<br>      port_max = optional(string)<br>      port_min = optional(string)<br>    }))<br>    udp = optional(object({<br>      port_max = optional(string)<br>      port_min = optional(string)<br>    }))<br>    icmp = optional(object({<br>      type = optional(string)<br>      code = optional(string)<br>    }))<br>  }))</pre> | n/a | yes |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
