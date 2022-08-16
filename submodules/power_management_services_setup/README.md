# Submodule power_management_services_setup

This submodule is used to Install and configure the services DNS, NTP, NFS, SQUID on target host and sets the host as server for these services

## Usage
```
provider "ibm" {
  region           = "sao"
  zone             = "sao01"
  ibmcloud_api_key = "your api key" != null ? "your api key" : null   # pragma: allowlist secret
}

module "cloud-connection-create" {
  source  = "./power_management_services_setup"
  count                       = var.dns_forwarder_config["dns_enable"] ? 1 : 0

  access_host_or_ip           = var.access_host_or_ip
  target_server_ip            = var.dns_forwarder_config["server_host_or_ip"]
  ssh_private_key             = var.ssh_private_key  # pragma: allowlist secret
  service_config              = var.dns_forwarder_config
}

}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.execute_ansible_role](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.install_packages](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | Jump/Bastion server Public IP to reach the target/server\_host ip to configure the DNS,NTP,NFS,SQUID services | `string` | n/a | yes |
| <a name="input_service_config"></a> [service\_config](#input\_service\_config) | Name of the existing transit gateway. Required when creating new cloud connections | `map(any)` | `{}` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | SSh private key value to login to server. It will not be uploaded / stored anywhere. | `string` | n/a | yes |
| <a name="input_target_server_ip"></a> [target\_server\_ip](#input\_target\_server\_ip) | Target/server\_host ip on which the DNS,NTP,NFS,SQUID services will be configured. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
