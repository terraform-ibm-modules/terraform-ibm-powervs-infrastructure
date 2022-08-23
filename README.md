# PowerVS infrastructure module

The PowerVS infrastructure module automates the following tasks:

- Creates the PowerVS service
- Creates an ssh key
- Creates two private networks: a management network and a backup network
- Creates two IBM Cloud connections with an option to reuse cloud connections
- Attaches the IBM Cloud connections to a transit gateway
- Attaches the private networks to the IBM Cloud connections

## Usage

```hcl
provider "ibm" {
  region    =   var.pvs_region
  zone      =   var.pvs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

module "power-infrastructure" {
  # Replace "main" with a GIT release version to lock into a specific release
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure.git?ref=main"

  pvs_zone                    = var.pvs_zone
  pvs_resource_group_name     = var.pvs_resource_group_name
  pvs_service_name            = var.pvs_service_name
  tags                        = var.tags
  pvs_sshkey_name             = var.pvs_sshkey_name
  ssh_public_key              = var.ssh_public_key
  pvs_management_network      = var.pvs_management_network
  pvs_backup_network          = var.pvs_backup_network
  reuse_cloud_connections     = var.reuse_cloud_connections
  transit_gateway_name        = var.transit_gateway_name
  cloud_connection_count      = var.cloud_connection_count
  cloud_connection_speed      = var.cloud_connection_speed
  cloud_connection_gr         = var.cloud_connection_gr
  cloud_connection_metered    = var.cloud_connection_metered
  ibmcloud_api_key            = var.ibmcloud_api_key
}
```

You can configure the details in a `input.tfvars` variable definitions file.

```bash
terraform apply -var-file="input.tfvars"
```

## Required IAM access policies

TBC

<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [# Catalog PowerVS Infrastructure Module Example](examples/standard-catalog)
- [# Basic PowerVS Infrastructure Module Example](examples/basic)
<!-- END EXAMPLES HOOK -->

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.21.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_connection_attach"></a> [cloud\_connection\_attach](#module\_cloud\_connection\_attach) | ./submodules/power_cloudconnection_attach | n/a |
| <a name="module_cloud_connection_create"></a> [cloud\_connection\_create](#module\_cloud\_connection\_create) | ./submodules/power_cloudconnection_create | n/a |
| <a name="module_initial_validation"></a> [initial\_validation](#module\_initial\_validation) | ./submodules/initial_validation | n/a |
| <a name="module_power_service"></a> [power\_service](#module\_power\_service) | ./submodules/power_service | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Required number of Cloud connections which will be created/Reused. Maximum is 2 per location | `string` | `2` | no |
| <a name="input_cloud_connection_gr"></a> [cloud\_connection\_gr](#input\_cloud\_connection\_gr) | Enable global routing for this cloud connection.Can be specified when creating new connection | `bool` | `null` | no |
| <a name="input_cloud_connection_metered"></a> [cloud\_connection\_metered](#input\_cloud\_connection\_metered) | Enable metered for this cloud connection. Can be specified when creating new connection | `bool` | `null` | no |
| <a name="input_cloud_connection_speed"></a> [cloud\_connection\_speed](#input\_cloud\_connection\_speed) | Speed in megabits per sec. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when creating new connection | `string` | `5000` | no |
| <a name="input_pvs_backup_network"></a> [pvs\_backup\_network](#input\_pvs\_backup\_network) | IBM Cloud PowerVS Backup Network name and cidr which will be created | `map(any)` | <pre>{<br>  "cidr": "10.52.0.0/24",<br>  "name": "bkp_net"<br>}</pre> | no |
| <a name="input_pvs_management_network"></a> [pvs\_management\_network](#input\_pvs\_management\_network) | IBM Cloud PowerVS Management Subnet name and cidr which will be created | `map(any)` | <pre>{<br>  "cidr": "10.51.0.0/24",<br>  "name": "mgmt_net"<br>}</pre> | no |
| <a name="input_pvs_resource_group_name"></a> [pvs\_resource\_group\_name](#input\_pvs\_resource\_group\_name) | Existing Resource Group Name | `string` | n/a | yes |
| <a name="input_pvs_service_name"></a> [pvs\_service\_name](#input\_pvs\_service\_name) | Name of PowerVS service which will be created | `string` | `"power-service"` | no |
| <a name="input_pvs_sshkey_name"></a> [pvs\_sshkey\_name](#input\_pvs\_sshkey\_name) | Name of PowerVS SSH Key which will be created | `string` | `"ssh-key-pvs"` | no |
| <a name="input_pvs_zone"></a> [pvs\_zone](#input\_pvs\_zone) | IBM Cloud PowerVS Zone | `string` | n/a | yes |
| <a name="input_reuse_cloud_connections"></a> [reuse\_cloud\_connections](#input\_reuse\_cloud\_connections) | When the value is true, cloud connections will be reused (and is already attached to Transit gateway) | `bool` | `false` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for PowerVM creation | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tag names for IBM Cloud PowerVS service | `list(string)` | `null` | no |
| <a name="input_transit_gateway_name"></a> [transit\_gateway\_name](#input\_transit\_gateway\_name) | Name of the existing transit gateway. Required when creating new cloud connections | `string` | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing

You can report issues and request features for this module in the [terraform-ibm-issue-tracker](https://github.com/terraform-ibm-modules/terraform-ibm-issue-tracker/issues) repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
