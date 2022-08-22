<!-- BEGIN_TF_DOCS -->

# Submodule initial-validation

This submodule check whether the variables for cloud connections reuse and transit gateway name are provided

## Usage
Make sure you installed the Power flavor of version 0.0.19 or higher of Secure Landing Zone VPC with VSIs.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.43.0 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_connection_validate"></a> [cloud\_connection\_validate](#input\_cloud\_connection\_validate) | Verify reuse\_cloud\_connection and transit\_gateway\_name variables | <pre>object({<br>    reuse_cloud_connections = bool<br>    transit_gateway_name    = string<br>  })</pre> | n/a | yes |

## Outputs

No outputs.

## Resources

No resources.


## Usage

terraform apply -var-file="input.tfvars"

## Note

For all optional fields, default values (Eg: `null`) are given in variable.tf file. User can configure the same by overwriting with appropriate values.
<!-- END_TF_DOCS -->