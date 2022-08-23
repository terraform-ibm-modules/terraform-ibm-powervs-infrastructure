<!-- BEGIN_TF_DOCS -->

# Submodule initial-validation

This submodule check whether the variables for cloud connections reuse and transit gateway name are provided

## Usage
```
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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.43.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_connection_validate"></a> [cloud\_connection\_validate](#input\_cloud\_connection\_validate) | Verify reuse\_cloud\_connection and transit\_gateway\_name variables | <pre>object({<br>    reuse_cloud_connections = bool<br>    transit_gateway_name    = string<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
