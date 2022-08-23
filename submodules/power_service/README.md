<!-- BEGIN_TF_DOCS -->

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
source = "./submodules/power_service"

pvs_zone                = var.pvs_zone
pvs_resource_group_name = var.pvs_resource_group_name
pvs_service_name        = var.pvs_service_name
tags                    = var.tags
pvs_sshkey_name         = var.pvs_sshkey_name
ssh_public_key          = var.ssh_public_key
pvs_management_network  = var.pvs_management_network
pvs_backup_network      = var.pvs_backup_network
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
| [ibm_pi_key.ssh_key](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_key) | resource |
| [ibm_pi_network.backup_network](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_network) | resource |
| [ibm_pi_network.management_network](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_network) | resource |
| [ibm_resource_instance.pvs_service](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_group.resource_group_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pvs_zone"></a> [pvs\_zone](#input\_pvs\_zone) | IBM Cloud PowerVS Zone. | `string` | n/a | yes |
| <a name="input_pvs_resource_group_name"></a> [pvs\_resource\_group\_name](#input\_pvs\_resource\_group\_name) | Existing Resource Group Name | `string` | n/a | yes |
| <a name="input_pvs_service_name"></a> [pvs\_service\_name](#input\_pvs\_service\_name) | Name of IBM Cloud PowerVS service which will be created | `string` | n/a | yes |
| <a name="input_pvs_sshkey_name"></a> [pvs\_sshkey\_name](#input\_pvs\_sshkey\_name) | Name of IBM Cloud PowerVS SSH Key which will be created | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for PowerVM creation | `string` | n/a | yes |
| <a name="input_pvs_management_network"></a> [pvs\_management\_network](#input\_pvs\_management\_network) | IBM Cloud PowerVS Management Subnet name and cidr which will be created. | `map(any)` | n/a | yes |
| <a name="input_pvs_backup_network"></a> [pvs\_backup\_network](#input\_pvs\_backup\_network) | IBM Cloud PowerVS Backup Network name and cidr which will be created. | `map(any)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tag names for IBM Cloud PowerVS service | `list(string)` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
