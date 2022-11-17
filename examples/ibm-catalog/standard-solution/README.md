# IBM Cloud catalog example for Power infrastructure for regulated industries

This example illustrates how to use the `power-infrastructure` module in the IBM catalog. It provisions the following infrastructure:

- A PowerVS workspace instance with the following network topology:
    - Creates two private networks: a management network and a backup network
    - Creates one or two IBM Cloud connections with an option to reuse the connections
    - Attaches the IBM Cloud connections to a transit gateway
    - Attaches the private networks to the IBM Cloud connections
    - Creates an SSH key
    - Installs and configures the Squid Proxy, DNS Forwarder, NTP Forwarder and NFS on specified host, and sets the host as server for these services

## Before you begin

Install a current version of the [IBM Secure Landing Zone](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone) module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | = 1.45.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_powervs_infra"></a> [powervs\_infra](#module\_powervs\_infra) | ../../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_schematics_output.schematics_output](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.45.1/docs/data-sources/schematics_output) | data source |
| [ibm_schematics_workspace.schematics_workspace](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.45.1/docs/data-sources/schematics_workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_IC_SCHEMATICS_WORKSPACE_ID"></a> [IC\_SCHEMATICS\_WORKSPACE\_ID](#input\_IC\_SCHEMATICS\_WORKSPACE\_ID) | leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace | `string` | `""` | no |
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Required number of Cloud connections to create or reuse. The maximum number of connections is two per location. | `number` | `2` | no |
| <a name="input_cloud_connection_gr"></a> [cloud\_connection\_gr](#input\_cloud\_connection\_gr) | Whether to enable global routing for this IBM Cloud connection. You can specify thia value when you create a connection. | `bool` | `true` | no |
| <a name="input_cloud_connection_metered"></a> [cloud\_connection\_metered](#input\_cloud\_connection\_metered) | Whether to enable metering for this IBM Cloud connection. You can specify thia value when you create a connection. | `bool` | `false` | no |
| <a name="input_cloud_connection_speed"></a> [cloud\_connection\_speed](#input\_cloud\_connection\_speed) | Speed in megabits per second. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when you create a connection. | `number` | `5000` | no |
| <a name="input_configure_dns_forwarder"></a> [configure\_dns\_forwarder](#input\_configure\_dns\_forwarder) | Specify if DNS forwarder will be configured. This will allow you to use central DNS servers (e.g. IBM Cloud DNS servers) sitting outside of the created IBM PowerVS infrastructure. If yes, ensure 'dns\_forwarder\_config' optional variable is set properly. | `bool` | `true` | no |
| <a name="input_configure_nfs_server"></a> [configure\_nfs\_server](#input\_configure\_nfs\_server) | Specify if NFS server will be configured. This will allow you easily to share files between PowerVS instances (e.g., SAP installation files). If yes, ensure 'nfs\_config' optional variable is set properly. | `bool` | `true` | no |
| <a name="input_configure_ntp_forwarder"></a> [configure\_ntp\_forwarder](#input\_configure\_ntp\_forwarder) | Specify if NTP forwarder will be configured. This will allow you to synchronize time between IBM PowerVS instances. If yes, ensure 'ntp\_forwarder\_config' optional variable is set properly. | `bool` | `true` | no |
| <a name="input_configure_proxy"></a> [configure\_proxy](#input\_configure\_proxy) | Specify if proxy will be configured. Proxy is mandatory for the landscape, so set this to 'false' only if proxy already exists. Proxy will allow to communcate from IBM PowerVS instances with IBM Cloud network and with public internet. | `bool` | `true` | no |
| <a name="input_dns_forwarder_config"></a> [dns\_forwarder\_config](#input\_dns\_forwarder\_config) | Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS | <pre>object({<br>    server_host_or_ip = string<br>    dns_servers       = string<br>  })</pre> | <pre>{<br>  "dns_servers": "161.26.0.7; 161.26.0.8; 9.9.9.9;",<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud Api Key | `string` | n/a | yes |
| <a name="input_nfs_config"></a> [nfs\_config](#input\_nfs\_config) | Configuration for the shared NFS file system (for example, for the installation media). | <pre>object({<br>    server_host_or_ip = string<br>    nfs_directory     = string<br>  })</pre> | <pre>{<br>  "nfs_directory": "/nfs",<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_ntp_forwarder_config"></a> [ntp\_forwarder\_config](#input\_ntp\_forwarder\_config) | Configuration for the NTP forwarder to an NTP service that is not reachable directly from PowerVS | <pre>object({<br>    server_host_or_ip = string<br>  })</pre> | <pre>{<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_powervs_backup_network"></a> [powervs\_backup\_network](#input\_powervs\_backup\_network) | Name of the IBM Cloud PowerVS backup network and CIDR to create. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.52.0.0/24",<br>  "name": "bkp_net"<br>}</pre> | no |
| <a name="input_powervs_image_names"></a> [powervs\_image\_names](#input\_powervs\_image\_names) | List of Images to be imported into cloud account from catalog images | `list(string)` | <pre>[<br>  "SLES15-SP3-SAP",<br>  "SLES15-SP3-SAP-NETWEAVER",<br>  "RHEL8-SP4-SAP",<br>  "RHEL8-SP4-SAP-NETWEAVER"<br>]</pre> | no |
| <a name="input_powervs_management_network"></a> [powervs\_management\_network](#input\_powervs\_management\_network) | Name of the IBM Cloud PowerVS management subnet and CIDR to create. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.51.0.0/24",<br>  "name": "mgmt_net"<br>}</pre> | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. | `string` | n/a | yes |
| <a name="input_prerequisite_workspace_id"></a> [prerequisite\_workspace\_id](#input\_prerequisite\_workspace\_id) | IBM Cloud Schematics workspace ID of an existing Secure infrastructure on VPC for regulated industries with VSIs deployment. If you do not yet have an existing deployment, click [here](https://cloud.ibm.com/catalog/content/slz-vpc-with-vsis-a87ed9a5-d130-47a3-980b-5ceb1d4f9280-global#create) to create one. When you deploy this module, use one of supported [configurations](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/examples/ibm-catalog/standard-solution/slz_json_configs_for_powervs). Copy the configuration from the link into the `override_json_string` deployment value. | `string` | n/a | yes |
| <a name="input_reuse_cloud_connections"></a> [reuse\_cloud\_connections](#input\_reuse\_cloud\_connections) | When true, IBM Cloud connections are reused (if attached to the transit gateway). | `bool` | `false` | no |
| <a name="input_squid_config"></a> [squid\_config](#input\_squid\_config) | Configuration for the Squid proxy to a DNS service that is not reachable directly from PowerVS | <pre>object({<br>    server_host_or_ip = string<br>    squid_port        = string<br>  })</pre> | <pre>{<br>  "server_host_or_ip": "",<br>  "squid_port": ""<br>}</pre> | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh\_public\_key'. Entered data must be in [heredoc strings format](https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud PowerVS workspace | `list(string)` | <pre>[<br>  "sap"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Access host for created PowerVS infrastructure. |
| <a name="output_cloud_connection_count"></a> [cloud\_connection\_count](#output\_cloud\_connection\_count) | Number of cloud connections configured in created PowerVS infrastructure. |
| <a name="output_dns_host_or_ip"></a> [dns\_host\_or\_ip](#output\_dns\_host\_or\_ip) | DNS forwarder host for created PowerVS infrastructure. |
| <a name="output_nfs_path"></a> [nfs\_path](#output\_nfs\_path) | NFS host for created PowerVS infrastructure. |
| <a name="output_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#output\_ntp\_host\_or\_ip) | NTP host for created PowerVS infrastructure. |
| <a name="output_powervs_backup_network_name"></a> [powervs\_backup\_network\_name](#output\_powervs\_backup\_network\_name) | Name of backup network in created PowerVS infrastructure. |
| <a name="output_powervs_management_network_name"></a> [powervs\_management\_network\_name](#output\_powervs\_management\_network\_name) | Name of management network in created PowerVS infrastructure. |
| <a name="output_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#output\_powervs\_resource\_group\_name) | IBM Cloud resource group where PowerVS infrastructure is created. |
| <a name="output_powervs_sshkey_name"></a> [powervs\_sshkey\_name](#output\_powervs\_sshkey\_name) | SSH public key name in created PowerVS infrastructure. |
| <a name="output_powervs_workspace_name"></a> [powervs\_workspace\_name](#output\_powervs\_workspace\_name) | PowerVS infrastructure workspace name. |
| <a name="output_powervs_zone"></a> [powervs\_zone](#output\_powervs\_zone) | Zone where PowerVS infrastructure is created. |
| <a name="output_proxy_host_or_ip_port"></a> [proxy\_host\_or\_ip\_port](#output\_proxy\_host\_or\_ip\_port) | Proxy host:port for created PowerVS infrastructure. |
| <a name="output_schematics_workspace_id"></a> [schematics\_workspace\_id](#output\_schematics\_workspace\_id) | ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
