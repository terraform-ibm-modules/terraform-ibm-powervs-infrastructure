# Submodule power-cloudconnection-create

This submodule creates a PowerVs service, 2 private networks and a SSH key

## Usage
```hcl
provider "ibm" {
region           = "sao"
zone             = "sao01"
ibmcloud_api_key = "your api key" != null ? "your api key" : null
}

module "power_service" {
source = "./submodules/power_workspace"

powervs_zone                = var.powervs_zone
powervs_resource_group_name = var.powervs_resource_group_name
powervs_workspace_name      = var.powervs_workspace_name
tags                        = var.tags
powervs_sshkey_name         = var.powervs_sshkey_name
ssh_public_key              = var.ssh_public_key
powervs_management_network  = var.powervs_management_network
powervs_backup_network      = var.powervs_backup_network
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
| [ibm_pi_image.import_images_1](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/resources/pi_image) | resource |
| [ibm_pi_image.import_images_2](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/resources/pi_image) | resource |
| [ibm_pi_key.ssh_key](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/resources/pi_key) | resource |
| [ibm_pi_network.backup_network](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/resources/pi_network) | resource |
| [ibm_pi_network.management_network](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/resources/pi_network) | resource |
| [ibm_resource_instance.powervs_workspace](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/resources/resource_instance) | resource |
| [ibm_pi_catalog_images.catalog_images_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/data-sources/pi_catalog_images) | data source |
| [ibm_resource_group.resource_group_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_powervs_backup_network"></a> [powervs\_backup\_network](#input\_powervs\_backup\_network) | IBM Cloud PowerVS Backup Network name and cidr which will be created. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | n/a | yes |
| <a name="input_powervs_image_names"></a> [powervs\_image\_names](#input\_powervs\_image\_names) | List of Images to be imported into cloud account from catalog images | `list(string)` | n/a | yes |
| <a name="input_powervs_management_network"></a> [powervs\_management\_network](#input\_powervs\_management\_network) | IBM Cloud PowerVS Management Subnet name and cidr which will be created. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | n/a | yes |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing Resource Group Name | `string` | n/a | yes |
| <a name="input_powervs_sshkey_name"></a> [powervs\_sshkey\_name](#input\_powervs\_sshkey\_name) | Name of IBM Cloud PowerVS SSH Key which will be created | `string` | n/a | yes |
| <a name="input_powervs_workspace_name"></a> [powervs\_workspace\_name](#input\_powervs\_workspace\_name) | Name of IBM Cloud PowerVS workspace which will be created | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud PowerVS Zone. | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for PowerVM creation | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tag names for IBM Cloud PowerVS workspace | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
