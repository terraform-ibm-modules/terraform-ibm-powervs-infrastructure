# IBM Cloud catalog example for Power Virtual Server with VPC landing zone Full-Stack Variation

This example sets up the following infrastructure:
- A VPC Infrastructure with the following components:
    -  Provisions three VPCs with one VSI in each VPC (one management(jump/bastion) VSI, one inet-svs VSI configured as squid proxy server, one private-svs VSI configured as NFS, NTP, DNS server).
    - Installs and configures the Squid Proxy, DNS Forwarder, NTP forwarder and NFS on hosts, and sets the host as the server for the NTP, NFS, and DNS services by using Ansible roles.

- A PowerVS workspace instance with the following network topology:
    - Creates two private networks: a management network and a backup network.
    - Creates one or two IBM Cloud connections.
    - Attaches the IBM Cloud connections to a transit gateway.
    - Attaches the private networks to the IBM Cloud connections.
    - Creates an SSH key.

| Variation  | Available on IBM Catalog  |  Requires Schematics Workspace ID | Creates VPC Landing Zone | Performs VPC VSI OS Config | Creates PowerVS Infrastructure | Creates PowerVS Instance | Performs PowerVS OS Config |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [Full-Stack](./)  | :heavy_check_mark:  | N/A  | :heavy_check_mark:  | :heavy_check_mark:  |  :heavy_check_mark: | N/A | N/A |

## Reference architecture
[PowerVS workspace full-stack variation](../../reference-architectures/full-stack/deploy-arch-ibm-pvs-inf-full-stack.md)


## Architecture diagram
![full-stack-variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/full-stack/deploy-arch-ibm-pvs-inf-full-stack.svg)


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 1.6 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | =1.54.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_landing_zone"></a> [landing\_zone](#module\_landing\_zone) | terraform-ibm-modules/landing-zone/ibm//patterns//vsi//module | 4.4.6 |
| <a name="module_powervs_infra"></a> [powervs\_infra](#module\_powervs\_infra) | ../../ | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_IC_SCHEMATICS_WORKSPACE_ID"></a> [IC\_SCHEMATICS\_WORKSPACE\_ID](#input\_IC\_SCHEMATICS\_WORKSPACE\_ID) | leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace. | `string` | `""` | no |
| <a name="input_cloud_connection"></a> [cloud\_connection](#input\_cloud\_connection) | Cloud connection configuration: speed (50, 100, 200, 500, 1000, 2000, 5000, 10000 Mb/s), count (1 or 2 connections), global\_routing (true or false), metered (true or false) | <pre>object({<br>    count          = number<br>    speed          = number<br>    global_routing = bool<br>    metered        = bool<br>  })</pre> | <pre>{<br>  "count": 2,<br>  "global_routing": true,<br>  "metered": true,<br>  "speed": 5000<br>}</pre> | no |
| <a name="input_configure_dns_forwarder"></a> [configure\_dns\_forwarder](#input\_configure\_dns\_forwarder) | Specify if DNS forwarder will be configured. This will allow you to use central DNS servers (e.g. IBM Cloud DNS servers) sitting outside of the created IBM PowerVS infrastructure. If yes, ensure 'dns\_forwarder\_config' optional variable is set properly. DNS forwarder will be installed on the private-svs vsi. | `bool` | `true` | no |
| <a name="input_configure_nfs_server"></a> [configure\_nfs\_server](#input\_configure\_nfs\_server) | Specify if NFS server will be configured. This will allow you easily to share files between PowerVS instances (e.g., SAP installation files). NFS server will be installed on the private-svs vsi. | `bool` | `true` | no |
| <a name="input_configure_ntp_forwarder"></a> [configure\_ntp\_forwarder](#input\_configure\_ntp\_forwarder) | Specify if NTP forwarder will be configured. This will allow you to synchronize time between IBM PowerVS instances. NTP forwarder will be installed on the private-svs vsi. | `bool` | `true` | no |
| <a name="input_dns_forwarder_config"></a> [dns\_forwarder\_config](#input\_dns\_forwarder\_config) | Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS. | <pre>object({<br>    dns_servers = string<br>  })</pre> | <pre>{<br>  "dns_servers": "161.26.0.7; 161.26.0.8; 9.9.9.9;"<br>}</pre> | no |
| <a name="input_external_access_ip"></a> [external\_access\_ip](#input\_external\_access\_ip) | Specify the IP address or CIDR to login through SSH to the environment after deployment. Access to this environment will be allowed only from this IP address. | `string` | n/a | yes |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_landing_zone_configuration"></a> [landing\_zone\_configuration](#input\_landing\_zone\_configuration) | VPC landing zone configuration. | `string` | n/a | yes |
| <a name="input_powervs_backup_network"></a> [powervs\_backup\_network](#input\_powervs\_backup\_network) | Name of the IBM Cloud PowerVS backup network and CIDR to create. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.52.0.0/24",<br>  "name": "bkp_net"<br>}</pre> | no |
| <a name="input_powervs_image_names"></a> [powervs\_image\_names](#input\_powervs\_image\_names) | List of Images to be imported into cloud account from catalog images | `list(string)` | <pre>[<br>  "SLES15-SP3-SAP",<br>  "SLES15-SP3-SAP-NETWEAVER",<br>  "RHEL8-SP4-SAP",<br>  "RHEL8-SP4-SAP-NETWEAVER"<br>]</pre> | no |
| <a name="input_powervs_management_network"></a> [powervs\_management\_network](#input\_powervs\_management\_network) | Name of the IBM Cloud PowerVS management subnet and CIDR to create. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.51.0.0/24",<br>  "name": "mgmt_net"<br>}</pre> | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters. | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to public SSH key referenced by 'ssh\_public\_key'. Entered data must be in [heredoc strings format](https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud PowerVS workspace | `list(string)` | <pre>[<br>  "sap"<br>]</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Access host(jump/bastion) for created PowerVS infrastructure. |
| <a name="output_cloud_connection_count"></a> [cloud\_connection\_count](#output\_cloud\_connection\_count) | Number of cloud connections configured in created PowerVS infrastructure. |
| <a name="output_dns_host_or_ip"></a> [dns\_host\_or\_ip](#output\_dns\_host\_or\_ip) | DNS forwarder host for created PowerVS infrastructure. |
| <a name="output_nfs_host_or_ip_path"></a> [nfs\_host\_or\_ip\_path](#output\_nfs\_host\_or\_ip\_path) | NFS host for created PowerVS infrastructure. |
| <a name="output_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#output\_ntp\_host\_or\_ip) | NTP host for created PowerVS infrastructure. |
| <a name="output_powervs_backup_network_name"></a> [powervs\_backup\_network\_name](#output\_powervs\_backup\_network\_name) | Name of backup network in created PowerVS infrastructure. |
| <a name="output_powervs_backup_network_subnet"></a> [powervs\_backup\_network\_subnet](#output\_powervs\_backup\_network\_subnet) | Subnet CIDR of backup network in created PowerVS infrastructure. |
| <a name="output_powervs_management_network_name"></a> [powervs\_management\_network\_name](#output\_powervs\_management\_network\_name) | Name of management network in created PowerVS infrastructure. |
| <a name="output_powervs_management_network_subnet"></a> [powervs\_management\_network\_subnet](#output\_powervs\_management\_network\_subnet) | Subnet CIDR  of management network in created PowerVS infrastructure. |
| <a name="output_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#output\_powervs\_resource\_group\_name) | IBM Cloud resource group where PowerVS infrastructure is created. |
| <a name="output_powervs_sshkey_name"></a> [powervs\_sshkey\_name](#output\_powervs\_sshkey\_name) | SSH public key name in created PowerVS infrastructure. |
| <a name="output_powervs_workspace_crn"></a> [powervs\_workspace\_crn](#output\_powervs\_workspace\_crn) | PowerVS infrastructure workspace CRN. |
| <a name="output_powervs_workspace_name"></a> [powervs\_workspace\_name](#output\_powervs\_workspace\_name) | PowerVS infrastructure workspace name. |
| <a name="output_powervs_zone"></a> [powervs\_zone](#output\_powervs\_zone) | Zone where PowerVS infrastructure is created. |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | The prefix that is associated with all resources |
| <a name="output_proxy_host_or_ip_port"></a> [proxy\_host\_or\_ip\_port](#output\_proxy\_host\_or\_ip\_port) | Proxy host:port for created PowerVS infrastructure. |
| <a name="output_schematics_workspace_id"></a> [schematics\_workspace\_id](#output\_schematics\_workspace\_id) | ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics. |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key) | The string value of the ssh public key used when deploying VPC |
| <a name="output_transit_gateway_name"></a> [transit\_gateway\_name](#output\_transit\_gateway\_name) | The name of the transit gateway. |
| <a name="output_vpc_names"></a> [vpc\_names](#output\_vpc\_names) | A list of the names of the VPC. |
| <a name="output_vsi_list"></a> [vsi\_list](#output\_vsi\_list) | A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP. |
| <a name="output_vsi_names"></a> [vsi\_names](#output\_vsi\_names) | A list of the vsis names provisioned within the VPCs. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
