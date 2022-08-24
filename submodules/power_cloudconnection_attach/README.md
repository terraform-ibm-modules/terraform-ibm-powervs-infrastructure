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
source                  = "./submodules/power_cloudconnection_attach"
pvs_zone                = var.pvs_zone
pvs_resource_group_name = var.pvs_resource_group_name
pvs_service_name        = var.pvs_service_name
cloud_connection_count  = var.cloud_connection_count
pvs_subnet_names        = var.pvs_subnet_names
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.43.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_pi_cloud_connection_network_attach.pvs_subnet_bkp_nw_attach](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_cloud_connection_network_attach) | resource |
| [ibm_pi_cloud_connection_network_attach.pvs_subnet_bkp_nw_attach_backup](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_cloud_connection_network_attach) | resource |
| [ibm_pi_cloud_connection_network_attach.pvs_subnet_mgmt_nw_attach](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_cloud_connection_network_attach) | resource |
| [ibm_pi_cloud_connection_network_attach.pvs_subnet_mgmt_nw_attach_backup](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_cloud_connection_network_attach) | resource |
| [ibm_pi_cloud_connections.cloud_connection_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/pi_cloud_connections) | data source |
| [ibm_pi_network.pvs_subnets_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/pi_network) | data source |
| [ibm_resource_group.resource_group_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_group) | data source |
| [ibm_resource_instance.pvs_service_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Number of cloud connections where private networks should be attached to. Default is to use redundant cloud connection pair. | `string` | `2` | no |
| <a name="input_pvs_resource_group_name"></a> [pvs\_resource\_group\_name](#input\_pvs\_resource\_group\_name) | Existing Resource Group Name | `string` | n/a | yes |
| <a name="input_pvs_service_name"></a> [pvs\_service\_name](#input\_pvs\_service\_name) | Existing IBM Cloud PowerVS Service Name | `string` | n/a | yes |
| <a name="input_pvs_subnet_names"></a> [pvs\_subnet\_names](#input\_pvs\_subnet\_names) | List of IBM Cloud PowerVS subnet names to be attached to Cloud connection | `list(any)` | n/a | yes |
| <a name="input_pvs_zone"></a> [pvs\_zone](#input\_pvs\_zone) | IBM Cloud PowerVS Zone | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
