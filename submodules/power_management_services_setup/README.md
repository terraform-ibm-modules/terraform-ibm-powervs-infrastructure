# Submodule power_management_services_setup

This submodule Installs and configures the Squid Proxy, DNS Forwarder, NTP Forwarder, NFS on specified host and sets the host as server for these services

## Usage
```hcl
provider "ibm" {
region           = "sao"
zone             = "sao01"
ibmcloud_api_key = "your api key" != null ? "your api key" : null
}

module "power_management_service_squid" {

source     = "./submodules/power_management_services_setup"
access_host_or_ip          = var.access_host_or_ip
target_server_ip           = var.target_server_ip
ssh_private_key            = var.ssh_private_key
service_config             = var.service_config
perform_proxy_client_setup = var.perform_proxy_client_setup
}

```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.execute_ansible_role](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.install_packages](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.perform_proxy_client_setup](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | Jump/Bastion server Public IP to reach the target/server\_host ip to configure the DNS,NTP,NFS,SQUID services | `string` | n/a | yes |
| <a name="input_perform_proxy_client_setup"></a> [perform\_proxy\_client\_setup](#input\_perform\_proxy\_client\_setup) | Configures a Vm/Lpar to have internet access by setting proxy on it. | <pre>object(<br>    {<br>      squid_client_ips = list(string)<br>      squid_server_ip  = string<br>      squid_port       = string<br>      no_proxy_hosts   = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_service_config"></a> [service\_config](#input\_service\_config) | An object which contains configuration for NFS, NTP, DNS, Squid Services | `any` | `{}` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key used to login to IBM PowerVS instances.Entered data must be in heredoc strings format (https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. | `string` | n/a | yes |
| <a name="input_target_server_ip"></a> [target\_server\_ip](#input\_target\_server\_ip) | Target/server\_host ip on which the DNS,NTP,NFS,SQUID services will be configured. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
