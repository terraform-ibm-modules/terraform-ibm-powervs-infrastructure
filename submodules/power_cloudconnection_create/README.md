<!-- BEGIN_TF_DOCS -->

# Submodule power-cloudconnection-create

This submodule creates Cloud Connections and attaches the cloud connections to the Transit gateway.

## Usage
```hcl
provider "ibm" {
region           = "sao"
zone             = "sao01"
ibmcloud_api_key = "your api key" != null ? "your api key" : null
}

module "cloud_connection_create" {
source                   = "./submodules/power_cloudconnection_create"
pvs_zone                 = var.pvs_zone
pvs_resource_group_name  = var.pvs_resource_group_name
pvs_service_name         = var.pvs_service_name
transit_gateway_name     = var.transit_gateway_name
cloud_connection_count   = var.cloud_connection_count
cloud_connection_speed   = var.cloud_connection_speed
cloud_connection_gr      = var.cloud_connection_gr
cloud_connection_metered = var.cloud_connection_metered
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.43.0 |

## Resources

| Name | Type |
|------|------|
| [ibm_pi_cloud_connection.cloud_connection](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_cloud_connection) | resource |
| [ibm_pi_cloud_connection.cloud_connection_backup](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_cloud_connection) | resource |
| [ibm_tg_connection.ibm_tg_connection_1](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/tg_connection) | resource |
| [ibm_tg_connection.ibm_tg_connection_2](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/tg_connection) | resource |
| [time_sleep.dl_1_resource_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.dl_2_resource_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [ibm_dl_gateway.gateway_ds_1](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/dl_gateway) | data source |
| [ibm_dl_gateway.gateway_ds_2](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/dl_gateway) | data source |
| [ibm_resource_group.resource_group_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_group) | data source |
| [ibm_resource_instance.pvs_service_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |
| [ibm_tg_gateway.tg_gateway_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/tg_gateway) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pvs_zone"></a> [pvs\_zone](#input\_pvs\_zone) | IBM Cloud PowerVS Zone | `string` | n/a | yes |
| <a name="input_pvs_resource_group_name"></a> [pvs\_resource\_group\_name](#input\_pvs\_resource\_group\_name) | Existing Resource Group Name | `string` | n/a | yes |
| <a name="input_pvs_service_name"></a> [pvs\_service\_name](#input\_pvs\_service\_name) | Existing IBM Cloud PowerVS Service Name | `string` | n/a | yes |
| <a name="input_transit_gateway_name"></a> [transit\_gateway\_name](#input\_transit\_gateway\_name) | Name of the existing transit gateway. Required when creating new cloud connections | `string` | `null` | no |
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Required number of Cloud connections which will be created/Reused. Maximum is 2 per location | `string` | `2` | no |
| <a name="input_cloud_connection_speed"></a> [cloud\_connection\_speed](#input\_cloud\_connection\_speed) | Speed in megabits per sec. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when creating new connection | `string` | `null` | no |
| <a name="input_cloud_connection_gr"></a> [cloud\_connection\_gr](#input\_cloud\_connection\_gr) | Enable global routing for this cloud connection.Can be specified when creating new connection | `bool` | `null` | no |
| <a name="input_cloud_connection_metered"></a> [cloud\_connection\_metered](#input\_cloud\_connection\_metered) | Enable metered for this cloud connection. Can be specified when creating new connection | `bool` | `null` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
