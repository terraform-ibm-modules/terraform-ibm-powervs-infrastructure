# Submodule initial-validation

This submodule checks the right combination of variables and validates them

## Usage
```hcl
provider "ibm" {
region           = "sao"
zone             = "sao01"
ibmcloud_api_key = "your api key" != null ? "your api key" : null
}

module "initial_validation" {
source = "./submodules/initial_validation"
cloud_connection_validate = var.cloud_connection_validate
}

```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_connection_validate"></a> [cloud\_connection\_validate](#input\_cloud\_connection\_validate) | Verify reuse\_cloud\_connection and transit\_gateway\_name variables | <pre>object({<br>    reuse_cloud_connections = bool<br>    transit_gateway_name    = string<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
