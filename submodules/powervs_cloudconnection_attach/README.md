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
source                      = "./submodules/powervs_cloudconnection_attach"
powervs_zone                = var.powervs_zone
powervs_resource_group_name = var.powervs_resource_group_name
powervs_workspace_name      = var.powervs_workspace_name
cloud_connection_count      = var.cloud_connection_count
powervs_subnet_names        = var.powervs_subnet_names
}
```

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
| [ibm_pi_cloud_connection_network_attach.powervs_subnet_bkp_nw_attach](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_cloud_connection_network_attach) | resource |
| [ibm_pi_cloud_connection_network_attach.powervs_subnet_bkp_nw_attach_backup](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_cloud_connection_network_attach) | resource |
| [ibm_pi_cloud_connection_network_attach.powervs_subnet_mgmt_nw_attach](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_cloud_connection_network_attach) | resource |
| [ibm_pi_cloud_connection_network_attach.powervs_subnet_mgmt_nw_attach_backup](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_cloud_connection_network_attach) | resource |
| [ibm_pi_cloud_connections.cloud_connection_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/pi_cloud_connections) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Number of cloud connections where private networks should be attached to. Default is to use redundant cloud connection pair. | `number` | n/a | yes |
| <a name="input_powervs_subnet_ids"></a> [powervs\_subnet\_ids](#input\_powervs\_subnet\_ids) | List of IBM Cloud PowerVS subnet ids to be attached to Cloud connection. Maximum of 2 subnets in a list are supported. | `list(any)` | n/a | yes |
| <a name="input_powervs_workspace_guid"></a> [powervs\_workspace\_guid](#input\_powervs\_workspace\_guid) | Existing IBM Cloud PowerVS Workspace GUID. | `string` | n/a | yes |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
