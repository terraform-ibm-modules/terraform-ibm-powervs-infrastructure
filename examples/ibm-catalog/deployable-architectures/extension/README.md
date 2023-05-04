# IBM Cloud catalog example for Power Virtual Server with VPC landing zone Extension Variation

This example extends an existing PowerVS infrastructure for deployable architectures deployed as full-stack with an additional PowerVS workspace.
It provisions the following infrastructure on top of deployed Full Stack solution :

- A PowerVS workspace instance with the following network topology:
    - Creates two private networks: a management network and a backup network
    - Creates one or two IBM Cloud connections
    - Attaches the IBM Cloud connections to a transit gateway
    - Attaches the private networks to the IBM Cloud connections
    - Creates an SSH key
    - Optionally configures the public internet proxy (Squid), DNS forwarder, NTP forwarder and NFS on a specified host and sets the host as server for these services by using Ansible roles.

## Before you begin

If you do not have a PowerVS infrastructure that is the full stack solution for a PowerVS Workspace that includes the full stack solution for Secure Landing Zone, create it first.

Alternative: Deploy Secure infrastructure on VPC for regulated industries. Click [here](https://cloud.ibm.com/catalog/content/slz-vpc-with-vsis-a87ed9a5-d130-47a3-980b-5ceb1d4f9280-global#create) to create one and choose the standard flavor. When you deploy this module, use one of supported [configurations](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/examples/ibm-catalog/standard-solution/slz_json_configs_for_powervs). Copy the configuration from the link into the `override_json_string` deployment value and set `override` to True.

## Architecture diagram
![extension-variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/extension/deploy-arch-ibm-pvs-inf-extension.svg)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 1.5 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | =1.49.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_powervs_infra"></a> [powervs\_infra](#module\_powervs\_infra) | ../../../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_schematics_output.schematics_output](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.49.0/docs/data-sources/schematics_output) | data source |
| [ibm_schematics_workspace.schematics_workspace](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.49.0/docs/data-sources/schematics_workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_IC_SCHEMATICS_WORKSPACE_ID"></a> [IC\_SCHEMATICS\_WORKSPACE\_ID](#input\_IC\_SCHEMATICS\_WORKSPACE\_ID) | leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace | `string` | `""` | no |
| <a name="input_cloud_connection"></a> [cloud\_connection](#input\_cloud\_connection) | Cloud connection configuration: speed (50, 100, 200, 500, 1000, 2000, 5000, 10000 Mb/s), count (1 or 2 connections), global\_routing (true or false), metered (true or false) | <pre>object({<br>    count          = number<br>    speed          = number<br>    global_routing = bool<br>    metered        = bool<br>  })</pre> | <pre>{<br>  "count": 2,<br>  "global_routing": true,<br>  "metered": true,<br>  "speed": 5000<br>}</pre> | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | `null` | no |
| <a name="input_powervs_backup_network"></a> [powervs\_backup\_network](#input\_powervs\_backup\_network) | Name of the IBM Cloud PowerVS backup network and CIDR to create. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.62.0.0/24",<br>  "name": "bkp_net"<br>}</pre> | no |
| <a name="input_powervs_image_names"></a> [powervs\_image\_names](#input\_powervs\_image\_names) | List of Images to be imported into cloud account from catalog images | `list(string)` | <pre>[<br>  "SLES15-SP3-SAP",<br>  "SLES15-SP3-SAP-NETWEAVER",<br>  "RHEL8-SP4-SAP",<br>  "RHEL8-SP4-SAP-NETWEAVER"<br>]</pre> | no |
| <a name="input_powervs_management_network"></a> [powervs\_management\_network](#input\_powervs\_management\_network) | Name of the IBM Cloud PowerVS management subnet and CIDR to create. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.61.0.0/24",<br>  "name": "mgmt_net"<br>}</pre> | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. | `string` | n/a | yes |
| <a name="input_prerequisite_workspace_id"></a> [prerequisite\_workspace\_id](#input\_prerequisite\_workspace\_id) | IBM Cloud Schematics workspace ID of the prerequisite infrastructure. If you do not have an existing deployment yet, create a new architecture. | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh\_public\_key'. Entered data must be in [heredoc strings format](https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud PowerVS workspace | `list(string)` | <pre>[<br>  "sap"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Access host for created PowerVS infrastructure. |
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
| <a name="output_schematics_workspace_id"></a> [schematics\_workspace\_id](#output\_schematics\_workspace\_id) | ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics |
| <a name="output_transit_gateway_name"></a> [transit\_gateway\_name](#output\_transit\_gateway\_name) | The name of the transit gateway. |
| <a name="output_vpc_names"></a> [vpc\_names](#output\_vpc\_names) | A list of the names of the VPC. |
| <a name="output_vsi_list"></a> [vsi\_list](#output\_vsi\_list) | A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP. |
| <a name="output_vsi_names"></a> [vsi\_names](#output\_vsi\_names) | A list of the vsis names provisioned within the VPCs. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
