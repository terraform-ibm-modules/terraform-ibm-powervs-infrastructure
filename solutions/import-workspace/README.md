# IBM Cloud solution for Power Virtual Server with VPC landing zone Full-Stack Variation

This solution takes pre-existing VPC and PowerVS infrastructure resource details as inputs and creates a schematics workspace for them. The created schematics workspace's id can be used as pre-requisite workspace to install the deployable architecture 'Power Virtual Server for SAP HANA' to create and configure the Power LPARs for SAP over the the existing infrastructure landscape.


### Notes:

| Variation  | Available on IBM Catalog  |  Requires Schematics Workspace ID | Imports VPC Landing Zone | Imports VPC VSI OS Config | Imports PowerVS Infrastructure | Imports PowerVS Instance | Performs PowerVS OS Config |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [Full-Stack](./)  | :heavy_check_mark:  | N/A  | :heavy_check_mark:  | :heavy_check_mark:  |  :heavy_check_mark: | N/A | N/A |


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 1.6 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | =1.58.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_access_host"></a> [access\_host](#module\_access\_host) | ./module/vpc | n/a |
| <a name="module_edge_sg_rules_creation"></a> [edge\_sg\_rules\_creation](#module\_edge\_sg\_rules\_creation) | ./module/security-group | n/a |
| <a name="module_edge_vpc_acl_rules_creation"></a> [edge\_vpc\_acl\_rules\_creation](#module\_edge\_vpc\_acl\_rules\_creation) | ./module/acl | n/a |
| <a name="module_edge_vsi"></a> [edge\_vsi](#module\_edge\_vsi) | ./module/vpc | n/a |
| <a name="module_management_sg_rules_creation"></a> [management\_sg\_rules\_creation](#module\_management\_sg\_rules\_creation) | ./module/security-group | n/a |
| <a name="module_management_vpc_acl_rules_creation"></a> [management\_vpc\_acl\_rules\_creation](#module\_management\_vpc\_acl\_rules\_creation) | ./module/acl | n/a |
| <a name="module_power_workspace_data_retrieval"></a> [power\_workspace\_data\_retrieval](#module\_power\_workspace\_data\_retrieval) | ./module/powervs | n/a |
| <a name="module_wokload_sg_rules_creation"></a> [wokload\_sg\_rules\_creation](#module\_wokload\_sg\_rules\_creation) | ./module/security-group | n/a |
| <a name="module_workload_vpc_acl_rules_creation"></a> [workload\_vpc\_acl\_rules\_creation](#module\_workload\_vpc\_acl\_rules\_creation) | ./module/acl | n/a |
| <a name="module_workload_vsi"></a> [workload\_vsi](#module\_workload\_vsi) | ./module/vpc | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_is_network_acl.edge_acls](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.58.1/docs/data-sources/is_network_acl) | data source |
| [ibm_is_network_acl.management_acls](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.58.1/docs/data-sources/is_network_acl) | data source |
| [ibm_is_network_acl.workload_acls](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.58.1/docs/data-sources/is_network_acl) | data source |
| [ibm_is_subnet.edge_subnets](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.58.1/docs/data-sources/is_subnet) | data source |
| [ibm_is_subnet.management_subnets](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.58.1/docs/data-sources/is_subnet) | data source |
| [ibm_is_subnet.workload_subnets](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.58.1/docs/data-sources/is_subnet) | data source |
| [ibm_tg_gateway.ds_tggateway](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.58.1/docs/data-sources/tg_gateway) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_IC_SCHEMATICS_WORKSPACE_ID"></a> [IC\_SCHEMATICS\_WORKSPACE\_ID](#input\_IC\_SCHEMATICS\_WORKSPACE\_ID) | leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace. | `string` | `""` | no |
| <a name="input_access_host"></a> [access\_host](#input\_access\_host) | Name of the existing access host VSI and its floating ip. | <pre>object({<br>    vsi_name    = string<br>    floating_ip = string<br>  })</pre> | <pre>{<br>  "floating_ip": "",<br>  "vsi_name": ""<br>}</pre> | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_powervs_backup_network_name"></a> [powervs\_backup\_network\_name](#input\_powervs\_backup\_network\_name) | Name of backup network in existing PowerVS Workspace. | `string` | n/a | yes |
| <a name="input_powervs_management_network_name"></a> [powervs\_management\_network\_name](#input\_powervs\_management\_network\_name) | Name of management network in existing PowerVS Workspace. | `string` | n/a | yes |
| <a name="input_powervs_sshkey_name"></a> [powervs\_sshkey\_name](#input\_powervs\_sshkey\_name) | SSH public key name used for the existing PowerVS Workspace. | `string` | n/a | yes |
| <a name="input_powervs_workspace_name"></a> [powervs\_workspace\_name](#input\_powervs\_workspace\_name) | Name of the existing PowerVS Workspace. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS Workspace is created. | `string` | n/a | yes |
| <a name="input_proxy_host"></a> [proxy\_host](#input\_proxy\_host) | Name of the existing VSI on which proxy server is configured and proxy server port. | <pre>object({<br>    vsi_name = string<br>    port     = string<br>  })</pre> | <pre>{<br>  "port": "",<br>  "vsi_name": ""<br>}</pre> | no |
| <a name="input_transit_gateway_name"></a> [transit\_gateway\_name](#input\_transit\_gateway\_name) | The name of the transit gateway that connects the existing VPCs and PowerVS Workspace. | `string` | n/a | yes |
| <a name="input_workload_host"></a> [workload\_host](#input\_workload\_host) | Name of the existing workload host VSI name and NFS path. | <pre>object({<br>    vsi_name = string<br>    nfs_path = string<br>  })</pre> | <pre>{<br>  "nfs_path": "",<br>  "vsi_name": ""<br>}</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Access host(jump/bastion) for created PowerVS infrastructure. |
| <a name="output_cloud_connection_count"></a> [cloud\_connection\_count](#output\_cloud\_connection\_count) | Number of cloud connections configured in created PowerVS infrastructure. |
| <a name="output_dns_host_or_ip"></a> [dns\_host\_or\_ip](#output\_dns\_host\_or\_ip) | DNS forwarder host for created PowerVS infrastructure. |
| <a name="output_nfs_host_or_ip_path"></a> [nfs\_host\_or\_ip\_path](#output\_nfs\_host\_or\_ip\_path) | NFS host for created PowerVS infrastructure. |
| <a name="output_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#output\_ntp\_host\_or\_ip) | NTP host for created PowerVS infrastructure. |
| <a name="output_powervs_backup_subnet"></a> [powervs\_backup\_subnet](#output\_powervs\_backup\_subnet) | Name, ID and CIDR of backup private network in created PowerVS infrastructure. |
| <a name="output_powervs_images"></a> [powervs\_images](#output\_powervs\_images) | Object containing imported PowerVS image names and image ids. |
| <a name="output_powervs_management_subnet"></a> [powervs\_management\_subnet](#output\_powervs\_management\_subnet) | Name, ID and CIDR of management private network in created PowerVS infrastructure. |
| <a name="output_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#output\_powervs\_resource\_group\_name) | IBM Cloud resource group where PowerVS infrastructure is created. |
| <a name="output_powervs_ssh_public_key"></a> [powervs\_ssh\_public\_key](#output\_powervs\_ssh\_public\_key) | SSH public key name and value in created PowerVS infrastructure. |
| <a name="output_powervs_workspace_guid"></a> [powervs\_workspace\_guid](#output\_powervs\_workspace\_guid) | PowerVS infrastructure workspace guid. The GUID of the resource instance. |
| <a name="output_powervs_workspace_id"></a> [powervs\_workspace\_id](#output\_powervs\_workspace\_id) | PowerVS infrastructure workspace CRN. |
| <a name="output_powervs_workspace_name"></a> [powervs\_workspace\_name](#output\_powervs\_workspace\_name) | PowerVS infrastructure workspace name. |
| <a name="output_powervs_zone"></a> [powervs\_zone](#output\_powervs\_zone) | Zone where PowerVS infrastructure is created. |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | The prefix that is associated with all resources |
| <a name="output_proxy_host_or_ip_port"></a> [proxy\_host\_or\_ip\_port](#output\_proxy\_host\_or\_ip\_port) | Proxy host:port for created PowerVS infrastructure. |
| <a name="output_schematics_workspace_id"></a> [schematics\_workspace\_id](#output\_schematics\_workspace\_id) | ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics. |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key) | The string value of the ssh public key used when deploying VPC |
| <a name="output_transit_gateway_id"></a> [transit\_gateway\_id](#output\_transit\_gateway\_id) | The ID of transit gateway. |
| <a name="output_transit_gateway_name"></a> [transit\_gateway\_name](#output\_transit\_gateway\_name) | The name of the transit gateway. |
| <a name="output_vpc_names"></a> [vpc\_names](#output\_vpc\_names) | A list of the names of the VPC. |
| <a name="output_vsi_list"></a> [vsi\_list](#output\_vsi\_list) | A list of VSI with name, id, floating IP, primary ipv4 address, secondary ipv4 address, VPC name, and zone. |
| <a name="output_vsi_names"></a> [vsi\_names](#output\_vsi\_names) | A list of the vsis names provisioned within the VPCs. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
