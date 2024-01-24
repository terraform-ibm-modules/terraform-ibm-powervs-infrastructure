# IBM Cloud solution for Power Virtual Server with VPC landing zone Import-Workspace Variation

This solution helps to install the deployable architecture ['Power Virtual Server for SAP HANA'](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-sap-9aa6135e-75d5-467e-9f4a-ac2a21c069b8-global) on top of a pre-existing Power Virtual Server(PowerVS) landscape. 'Power Virtual Server for SAP HANA' automation requires a schematics workspace id for installation. The 'import-workspace' solution creates a schematics workspace by taking pre-existing VPC and PowerVS infrastructure resource details as inputs. The ID of this schematics workspace will be the pre-requisite workspace id required by 'Power Virtual Server for SAP HANA' to create and configure the PowerVS instances for SAP on top of the existing infrastructure.

### Pre-requisites:
The pre-existing infrastructure must meet the following conditions to use the 'import-workspace' solution to create a schematics workspace:
- **Virtual Private Cloud(VPC) side**
    - Existing VPC or VPCs with virtual servers instances, ACL/ACLs, and Security Groups.
    - Existing access host(jump server) which is an intel based virtual server instance that can access Power virtual server instances.
    - Existing Transit Gateway.
    - The VPC in which the jump host exists must be attached to the Transit Gateway.
    - The necessary ACLs and security group rules for VPC in which the access host(jump server) exists must allow SSH login to the Power virtual server instances which would be created using ['Power Virtual Server for SAP HANA'](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-sap-9aa6135e-75d5-467e-9f4a-ac2a21c069b8-global) automation.
- **Power Virtual Server Workspace side**
    - Existing Power Virtual Server Workspace with at-least two private subnets.
    - Power Virtual Server Workspace/Cloud Connections must be attached to above Transit Gateway.
    - SSH key pairs used to login to access host/jump host(intel based virtual server instance) on VPC side should match to the existing SSH key used in PowerVS Workspace.
- **Mandatory Management Network Services**
    - Existing Proxy server ip and port required to configure the internet access required for PowerVS instances.
- **Optional Management Network Services**
    - Existing DNS server ip for the PowerVS instances.
    - Existing NTP server ip for the PowerVS instances.
    - Existing NFS server ip and path for the PowerVS instances.
    - If the above parameters are provided, then it must be made sure IPs are reachable on Power virtual server instances which would be created using ['Power Virtual Server for SAP HANA'](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-sap-9aa6135e-75d5-467e-9f4a-ac2a21c069b8-global) automation.

**NOTE:** IBM Cloud has a quota of 100 ACL rules per ACL. The 'Import-Workspace' variation will create 52 new ACL rules for providing schematics servers access to the access host(this access is required for 'Power Virtual Server for SAP HANA' automation). Please ensure the concerned ACL can take in new ACL rules without exceeding the quota of 100 so the deployment will be successful.

#### Resources Created:
1. ACL rules for IBM Cloud Schematics are created for the VPC subnets in which access host(jump server) exists.
2. Schematics workspace required by 'Power Virtual Server for SAP HANA' to create and configure the PowerVS instances for SAP on top of the existing infrastructure.

### Notes:

| Variation  | Available on IBM Catalog  |  Requires Schematics Workspace ID | Imports VPC Landing Zone | Imports VPC VSI OS Config | Imports PowerVS Infrastructure | Imports PowerVS Instance | Performs PowerVS OS Config |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [Import-Workspace](./)  | :heavy_check_mark:  | N/A  | N/A  | N/A  |  N/A  | N/A | N/A |

## Architecture diagram
![import-workspace-variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/import-workspace/deploy-arch-ibm-pvs-inf-import-workspace.svg)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 1.6 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | =1.61.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_access_host"></a> [access\_host](#module\_access\_host) | ../../modules/import-powervs-vpc/vpc | n/a |
| <a name="module_management_sg_rules"></a> [management\_sg\_rules](#module\_management\_sg\_rules) | ../../modules/import-powervs-vpc/security-group | n/a |
| <a name="module_management_vpc_acl_rules"></a> [management\_vpc\_acl\_rules](#module\_management\_vpc\_acl\_rules) | ../../modules/import-powervs-vpc/acl | n/a |
| <a name="module_powervs_workspace_ds"></a> [powervs\_workspace\_ds](#module\_powervs\_workspace\_ds) | ../../modules/import-powervs-vpc/powervs | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_is_network_acl.management_acls_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.61.0/docs/data-sources/is_network_acl) | data source |
| [ibm_is_subnet.management_subnets_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.61.0/docs/data-sources/is_subnet) | data source |
| [ibm_tg_gateway.tgw_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.61.0/docs/data-sources/tg_gateway) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_IC_SCHEMATICS_WORKSPACE_ID"></a> [IC\_SCHEMATICS\_WORKSPACE\_ID](#input\_IC\_SCHEMATICS\_WORKSPACE\_ID) | leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace. | `string` | `""` | no |
| <a name="input_access_host"></a> [access\_host](#input\_access\_host) | Name of the existing access host VSI and its floating ip. Acls will be added to allow schematics IPs to the corresponding VPC. | <pre>object({<br>    vsi_name    = string<br>    floating_ip = string<br>  })</pre> | n/a | yes |
| <a name="input_dns_server_ip"></a> [dns\_server\_ip](#input\_dns\_server\_ip) | DNS server IP address. | `string` | `""` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_nfs_server_ip_path"></a> [nfs\_server\_ip\_path](#input\_nfs\_server\_ip\_path) | NFS server IP address and Path. If the NFS server VSI name is provided, the nfs path should not be empty and must begin with '/' character. For example: nfs\_server\_ip\_path = {"ip"   = "10.20.10.4", "nfs\_path" = "/nfs"} | <pre>object({<br>    ip       = string<br>    nfs_path = string<br>  })</pre> | <pre>{<br>  "ip": "",<br>  "nfs_path": ""<br>}</pre> | no |
| <a name="input_ntp_server_ip"></a> [ntp\_server\_ip](#input\_ntp\_server\_ip) | NTP server IP address. | `string` | `""` | no |
| <a name="input_powervs_backup_network_name"></a> [powervs\_backup\_network\_name](#input\_powervs\_backup\_network\_name) | Name of the existing subnet used for backup network in existing PowerVS workspace. | `string` | n/a | yes |
| <a name="input_powervs_management_network_name"></a> [powervs\_management\_network\_name](#input\_powervs\_management\_network\_name) | Name of the existing subnet used for management network in existing PowerVS workspace. | `string` | n/a | yes |
| <a name="input_powervs_sshkey_name"></a> [powervs\_sshkey\_name](#input\_powervs\_sshkey\_name) | SSH public key name used for the existing PowerVS workspace. | `string` | n/a | yes |
| <a name="input_powervs_workspace_guid"></a> [powervs\_workspace\_guid](#input\_powervs\_workspace\_guid) | Name of the existing PowerVS workspace. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS workspace exists. | `string` | n/a | yes |
| <a name="input_proxy_server_ip_port"></a> [proxy\_server\_ip\_port](#input\_proxy\_server\_ip\_port) | Existing Proxy Server IP and port. This will be required to configure internet access for PowerVS instances. | <pre>object({<br>    ip   = string<br>    port = number<br>  })</pre> | n/a | yes |
| <a name="input_transit_gateway_name"></a> [transit\_gateway\_name](#input\_transit\_gateway\_name) | The name of the existing transit gateway that has VPCs and PowerVS workspace connected to it. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Access host(jump/bastion) for existing PowerVS infrastructure. |
| <a name="output_cloud_connection_count"></a> [cloud\_connection\_count](#output\_cloud\_connection\_count) | Number of cloud connections configured in existing PowerVS infrastructure. |
| <a name="output_dns_host_or_ip"></a> [dns\_host\_or\_ip](#output\_dns\_host\_or\_ip) | DNS forwarder host for existing PowerVS infrastructure. |
| <a name="output_nfs_host_or_ip_path"></a> [nfs\_host\_or\_ip\_path](#output\_nfs\_host\_or\_ip\_path) | NFS host for existing PowerVS infrastructure. |
| <a name="output_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#output\_ntp\_host\_or\_ip) | NTP host for existing PowerVS infrastructure. |
| <a name="output_powervs_backup_subnet"></a> [powervs\_backup\_subnet](#output\_powervs\_backup\_subnet) | Name, ID and CIDR of backup private network in existing PowerVS infrastructure. |
| <a name="output_powervs_images"></a> [powervs\_images](#output\_powervs\_images) | Object containing imported PowerVS image names and image ids. |
| <a name="output_powervs_management_subnet"></a> [powervs\_management\_subnet](#output\_powervs\_management\_subnet) | Name, ID and CIDR of management private network in existing PowerVS infrastructure. |
| <a name="output_powervs_ssh_public_key"></a> [powervs\_ssh\_public\_key](#output\_powervs\_ssh\_public\_key) | SSH public key name and value used in existing PowerVS infrastructure. |
| <a name="output_powervs_workspace_guid"></a> [powervs\_workspace\_guid](#output\_powervs\_workspace\_guid) | PowerVS infrastructure workspace guid. The GUID of the resource instance. |
| <a name="output_powervs_workspace_id"></a> [powervs\_workspace\_id](#output\_powervs\_workspace\_id) | PowerVS infrastructure workspace CRN. |
| <a name="output_powervs_workspace_name"></a> [powervs\_workspace\_name](#output\_powervs\_workspace\_name) | PowerVS infrastructure workspace name. |
| <a name="output_powervs_zone"></a> [powervs\_zone](#output\_powervs\_zone) | Zone of existing PowerVS infrastructure. |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | The prefix that is associated with all resources |
| <a name="output_proxy_host_or_ip_port"></a> [proxy\_host\_or\_ip\_port](#output\_proxy\_host\_or\_ip\_port) | Proxy host:port for existing PowerVS infrastructure. |
| <a name="output_schematics_workspace_id"></a> [schematics\_workspace\_id](#output\_schematics\_workspace\_id) | ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics. |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key) | The string value of the ssh public key used when deploying VPC |
| <a name="output_transit_gateway_id"></a> [transit\_gateway\_id](#output\_transit\_gateway\_id) | The ID of transit gateway. |
| <a name="output_transit_gateway_name"></a> [transit\_gateway\_name](#output\_transit\_gateway\_name) | The name of the transit gateway. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
