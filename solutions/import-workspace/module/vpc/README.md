# Module vpc

## IBM Virtual Private Cloud

This module fetches the data of the pre-existing VPCs and the VSIs in it.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.58.1 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_is_instance.vsi](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/is_instance) | data source |
| [ibm_is_ssh_key.jump_host_ssh_key](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/is_ssh_key) | data source |
| [ibm_is_vpc.vpc](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/is_vpc) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attached_fip"></a> [attached\_fip](#input\_attached\_fip) | The floating IP attached to the VSI. | `string` | `""` | no |
| <a name="input_fip_enabled"></a> [fip\_enabled](#input\_fip\_enabled) | This values indicates whether a floating IP is attched to it. | `bool` | `false` | no |
| <a name="input_vsi_name"></a> [vsi\_name](#input\_vsi\_name) | Jump host IP. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc"></a> [vpc](#output\_vpc) | VPC's data |
| <a name="output_vsi_as_is"></a> [vsi\_as\_is](#output\_vsi\_as\_is) | VSI as is |
| <a name="output_vsi_info"></a> [vsi\_info](#output\_vsi\_info) | VSI Information. |
| <a name="output_vsi_ssh_public_key"></a> [vsi\_ssh\_public\_key](#output\_vsi\_ssh\_public\_key) | VSI SSH Public key |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
