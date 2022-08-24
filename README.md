<!-- BEGIN_TF_DOCS -->

# PowerVS Infrastructure Module

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
ssh_private_key             = var.ssh_private_key
pvs_management_network      = var.pvs_management_network
pvs_backup_network          = var.pvs_backup_network
transit_gateway_name        = var.transit_gateway_name
reuse_cloud_connections     = var.reuse_cloud_connections
cloud_connection_count      = var.cloud_connection_count
cloud_connection_speed      = var.cloud_connection_speed
cloud_connection_gr         = var.cloud_connection_gr
cloud_connection_metered    = var.cloud_connection_metered
access_host_or_ip           = var.access_host_or_ip
squid_config                = var.squid_config
dns_forwarder_config        = var.dns_forwarder_config
ntp_forwarder_config        = var.ntp_forwarder_config
nfs_config                  = var.nfs_config
perform_proxy_client_setup  = var.perform_proxy_client_setup
}
```
<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ Basic PowerVS Infrastructure Module Example](examples/basic)
- [ Catalog PowerVS Infrastructure Module Example](examples/ibm-catalog/standard-solution)
- [ Standard PowerVS Infrastructure Module Example](examples/standard)
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
| <a name="module_power_management_service_dns"></a> [power\_management\_service\_dns](#module\_power\_management\_service\_dns) | ./submodules/power_management_services_setup | n/a |
| <a name="module_power_management_service_nfs"></a> [power\_management\_service\_nfs](#module\_power\_management\_service\_nfs) | ./submodules/power_management_services_setup | n/a |
| <a name="module_power_management_service_ntp"></a> [power\_management\_service\_ntp](#module\_power\_management\_service\_ntp) | ./submodules/power_management_services_setup | n/a |
| <a name="module_power_management_service_squid"></a> [power\_management\_service\_squid](#module\_power\_management\_service\_squid) | ./submodules/power_management_services_setup | n/a |
| <a name="module_power_service"></a> [power\_service](#module\_power\_service) | ./submodules/power_service | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | The public IP address for the jump or Bastion server. The address is used to reach the target or server\_host IP address and to configure the DNS, NTP, NFS, and Squid proxy services. | `string` | n/a | yes |
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Required number of Cloud connections to create or reuse. The maximum number of connections i two per location. | `string` | `2` | no |
| <a name="input_cloud_connection_gr"></a> [cloud\_connection\_gr](#input\_cloud\_connection\_gr) | Whether to enable global routing for this IBM Cloud connection. You can specify thia value when you create a connection. | `bool` | `null` | no |
| <a name="input_cloud_connection_metered"></a> [cloud\_connection\_metered](#input\_cloud\_connection\_metered) | Whether to enable metering for this IBM Cloud connection. You can specify thia value when you create a connection. | `bool` | `null` | no |
| <a name="input_cloud_connection_speed"></a> [cloud\_connection\_speed](#input\_cloud\_connection\_speed) | Speed in megabits per second. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when you create a connection. | `string` | `5000` | no |
| <a name="input_dns_forwarder_config"></a> [dns\_forwarder\_config](#input\_dns\_forwarder\_config) | Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS | `map(any)` | <pre>{<br>  "dns_enable": "false",<br>  "dns_servers": "161.26.0.7; 161.26.0.8; 9.9.9.9;",<br>  "server_host_or_ip": "inet-svs"<br>}</pre> | no |
| <a name="input_nfs_config"></a> [nfs\_config](#input\_nfs\_config) | Configuration for the shared NFS file system (for example, for the installation media). | `map(any)` | <pre>{<br>  "nfs_directory": "/nfs",<br>  "nfs_enable": "true",<br>  "server_host_or_ip": "private-svs"<br>}</pre> | no |
| <a name="input_ntp_forwarder_config"></a> [ntp\_forwarder\_config](#input\_ntp\_forwarder\_config) | Configuration for the NTP forwarder to an NTP service that is not reachable directly from PowerVS | `map(any)` | <pre>{<br>  "ntp_enable": "false",<br>  "server_host_or_ip": "inet-svs"<br>}</pre> | no |
| <a name="input_perform_proxy_client_setup"></a> [perform\_proxy\_client\_setup](#input\_perform\_proxy\_client\_setup) | Proxy configuration to allow internet access for a VM or LPAR. | <pre>object(<br>    {<br>      squid_client_ips = list(string)<br>      squid_server_ip  = string<br>      no_proxy_env     = string<br>    }<br>  )</pre> | `null` | no |
| <a name="input_pvs_backup_network"></a> [pvs\_backup\_network](#input\_pvs\_backup\_network) | Name of the IBM Cloud PowerVS backup network and CIDR to create | `map(any)` | <pre>{<br>  "cidr": "10.52.0.0/24",<br>  "name": "bkp_net"<br>}</pre> | no |
| <a name="input_pvs_management_network"></a> [pvs\_management\_network](#input\_pvs\_management\_network) | Name of the IBM Cloud PowerVS management subnet and CIDR to create | `map(any)` | <pre>{<br>  "cidr": "10.51.0.0/24",<br>  "name": "mgmt_net"<br>}</pre> | no |
| <a name="input_pvs_resource_group_name"></a> [pvs\_resource\_group\_name](#input\_pvs\_resource\_group\_name) | Existing resource group name | `string` | n/a | yes |
| <a name="input_pvs_service_name"></a> [pvs\_service\_name](#input\_pvs\_service\_name) | Name of the PowerVS service to create | `string` | `"power-service"` | no |
| <a name="input_pvs_sshkey_name"></a> [pvs\_sshkey\_name](#input\_pvs\_sshkey\_name) | Name of the PowerVS SSH key to create | `string` | `"ssh-key-pvs"` | no |
| <a name="input_pvs_zone"></a> [pvs\_zone](#input\_pvs\_zone) | IBM Cloud PowerVS zone | `string` | n/a | yes |
| <a name="input_reuse_cloud_connections"></a> [reuse\_cloud\_connections](#input\_reuse\_cloud\_connections) | When true, IBM Cloud connections are reused (if attached to the transit gateway). | `bool` | `false` | no |
| <a name="input_squid_config"></a> [squid\_config](#input\_squid\_config) | Configuration for the Squid proxy to a DNS service that is not reachable directly from PowerVS | `map(any)` | <pre>{<br>  "server_host_or_ip": "inet-svs",<br>  "squid_enable": "false"<br>}</pre> | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | SSH private key value to log into the server. The key is not uploaded or stored. | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for the PowerVM to create | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud PowerVS service | `list(string)` | `null` | no |
| <a name="input_transit_gateway_name"></a> [transit\_gateway\_name](#input\_transit\_gateway\_name) | Name of the existing transit gateway. Required when you create new IBM Cloud connections. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pvs_backup_network_name"></a> [pvs\_backup\_network\_name](#output\_pvs\_backup\_network\_name) | Name of the created backup network. |
| <a name="output_pvs_management_network_name"></a> [pvs\_management\_network\_name](#output\_pvs\_management\_network\_name) | Name of the created management network. |
| <a name="output_pvs_resource_group_name"></a> [pvs\_resource\_group\_name](#output\_pvs\_resource\_group\_name) | Name of the IBM PowerVS resource group where elements were created. |
| <a name="output_pvs_service_name"></a> [pvs\_service\_name](#output\_pvs\_service\_name) | Name of the service where elements were created. |
| <a name="output_pvs_ssh_key_name"></a> [pvs\_ssh\_key\_name](#output\_pvs\_ssh\_key\_name) | Name of the created ssh key. |
| <a name="output_pvs_zone"></a> [pvs\_zone](#output\_pvs\_zone) | Name of the IBM PowerVS zone where elements were created. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing

You can report issues and request features for this module in the [terraform-ibm-issue-tracker](https://github.com/terraform-ibm-modules/terraform-ibm-issue-tracker/issues) repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
