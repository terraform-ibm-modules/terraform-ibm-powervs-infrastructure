# Submodule power-cloudconnection-attach

This submodule attaches PowerVS subnets to cloud connections

## Usage
```hcl
provider "ibm" {
region           = "sao"
zone             = "sao01"
ibmcloud_api_key = "your api key" != null ? "your api key" : null
}

module "cloud_connection_attach" {
source                      = "./submodules/power_cloudconnection_attach"
powervs_zone                = var.powervs_zone
powervs_resource_group_name = var.powervs_resource_group_name
powervs_workspace_name      = var.powervs_workspace_name
cloud_connection_count      = var.cloud_connection_count
powervs_subnet_names        = var.powervs_subnet_names
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | =1.50.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_pi_cloud_connection_network_attach.powervs_subnet_bkp_nw_attach](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/resources/pi_cloud_connection_network_attach) | resource |
| [ibm_pi_cloud_connection_network_attach.powervs_subnet_bkp_nw_attach_backup](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/resources/pi_cloud_connection_network_attach) | resource |
| [ibm_pi_cloud_connection_network_attach.powervs_subnet_mgmt_nw_attach](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/resources/pi_cloud_connection_network_attach) | resource |
| [ibm_pi_cloud_connection_network_attach.powervs_subnet_mgmt_nw_attach_backup](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/resources/pi_cloud_connection_network_attach) | resource |
| [ibm_pi_cloud_connections.cloud_connection_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/data-sources/pi_cloud_connections) | data source |
| [ibm_pi_network.powervs_subnets_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/data-sources/pi_network) | data source |
| [ibm_resource_group.resource_group_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/data-sources/resource_group) | data source |
| [ibm_resource_instance.powervs_workspace_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/data-sources/resource_instance) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Number of cloud connections where private networks should be attached to. Default is to use redundant cloud connection pair. | `number` | n/a | yes |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing Resource Group Name | `string` | n/a | yes |
| <a name="input_powervs_subnet_names"></a> [powervs\_subnet\_names](#input\_powervs\_subnet\_names) | List of IBM Cloud PowerVS subnet names to be attached to Cloud connection | `list(any)` | n/a | yes |
| <a name="input_powervs_workspace_name"></a> [powervs\_workspace\_name](#input\_powervs\_workspace\_name) | Existing IBM Cloud PowerVS Workspace Name | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud PowerVS Zone | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
