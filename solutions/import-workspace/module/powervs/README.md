# Module powervs

## IBM Power Virtual Servers

This module fetches the data of pre-existing Power Virtual Server(PowerVS) workspace. This modules take the PowerVS region and PowerVS workspace name as main inputs.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.49.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_pi_catalog_images.catalog_images_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/pi_catalog_images) | data source |
| [ibm_pi_network.pvs_backup_network](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/pi_network) | data source |
| [ibm_pi_network.pvs_management_network](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/pi_network) | data source |
| [ibm_resource_instance.power_workspace](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | api-key | `string` | n/a | yes |
| <a name="input_powervs_backup_network_name"></a> [powervs\_backup\_network\_name](#input\_powervs\_backup\_network\_name) | Name of backup network in created PowerVS infrastructure. | `string` | n/a | yes |
| <a name="input_powervs_management_network_name"></a> [powervs\_management\_network\_name](#input\_powervs\_management\_network\_name) | Name of management network in created PowerVS infrastructure. | `string` | n/a | yes |
| <a name="input_powervs_region"></a> [powervs\_region](#input\_powervs\_region) | IBM Cloud region location where IBM PowerVS infrastructure will be created. | `string` | n/a | yes |
| <a name="input_powervs_workspace_name"></a> [powervs\_workspace\_name](#input\_powervs\_workspace\_name) | PowerVS infrastructure workspace name. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_powervs_backup_network_subnet"></a> [powervs\_backup\_network\_subnet](#output\_powervs\_backup\_network\_subnet) | Subnet CIDR of backup network in created PowerVS infrastructure. |
| <a name="output_powervs_images"></a> [powervs\_images](#output\_powervs\_images) | Object containing imported PowerVS image names and image ids. |
| <a name="output_powervs_management_network_subnet"></a> [powervs\_management\_network\_subnet](#output\_powervs\_management\_network\_subnet) | Subnet CIDR  of management network in created PowerVS infrastructure. |
| <a name="output_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#output\_powervs\_resource\_group\_name) | IBM Cloud resource group where PowerVS infrastructure is created. |
| <a name="output_powervs_workspace_crn"></a> [powervs\_workspace\_crn](#output\_powervs\_workspace\_crn) | PowerVS infrastructure workspace CRN. |
| <a name="output_powervs_workspace_guid"></a> [powervs\_workspace\_guid](#output\_powervs\_workspace\_guid) | The GUID of PowerVS workspace |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
