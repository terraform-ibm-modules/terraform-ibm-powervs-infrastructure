# IBM Cloud catalog example for Power Virtual Server with VPC landing zone Quick-Start Variation

This example sets up the following infrastructure:
- A VPC Infrastructure with the following features:
    -  One VSI for management(jump/bastion).
    -  Installation and configuration of Squid Proxy, DNS Forwarder, NTP forwarder and NFS on the bastion host, and sets the host as the server for the NTP, NFS, and DNS services by using Ansible roles.

- A PowerVS workspace instance with the following network topology:
    - Creates two private networks: a management network and a backup network.
    - Creates one or two IBM Cloud connections.
    - Attaches the IBM Cloud connections to a transit gateway.
    - Attaches the private networks to the IBM Cloud connections.
    - Creates an SSH key for power workspace.

## Architecture diagram
![full-stack-variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/quick-start/quickstart-fullstack.svg)


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 1.5 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | =1.52.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_instance_init"></a> [instance\_init](#module\_instance\_init) | git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap.git//submodules//power_sap_instance_init | v6.2.0 |
| <a name="module_landing_zone"></a> [landing\_zone](#module\_landing\_zone) | git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone.git//patterns//vsi | v3.8.3 |
| <a name="module_powervs_infra"></a> [powervs\_infra](#module\_powervs\_infra) | ../../../../ | n/a |
| <a name="module_share_fs_instance"></a> [share\_fs\_instance](#module\_share\_fs\_instance) | git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap.git//submodules//power_instance | v6.2.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_IC_SCHEMATICS_WORKSPACE_ID"></a> [IC\_SCHEMATICS\_WORKSPACE\_ID](#input\_IC\_SCHEMATICS\_WORKSPACE\_ID) | leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace | `string` | `""` | no |
| <a name="input_cloud_connection"></a> [cloud\_connection](#input\_cloud\_connection) | Cloud connection configuration: speed (50, 100, 200, 500, 1000, 2000, 5000, 10000 Mb/s), count (1 or 2 connections), global\_routing (true or false), metered (true or false) | <pre>object({<br>    count          = number<br>    speed          = number<br>    global_routing = bool<br>    metered        = bool<br>  })</pre> | <pre>{<br>  "count": 2,<br>  "global_routing": true,<br>  "metered": true,<br>  "speed": 5000<br>}</pre> | no |
| <a name="input_configure_dns_forwarder"></a> [configure\_dns\_forwarder](#input\_configure\_dns\_forwarder) | Specify if DNS forwarder will be configured. This will allow you to use central DNS servers (e.g. IBM Cloud DNS servers) sitting outside of the created IBM PowerVS infrastructure. If yes, ensure 'dns\_forwarder\_config' optional variable is set properly. DNS forwarder will be installed on the private-svs vsi. | `bool` | `true` | no |
| <a name="input_configure_nfs_server"></a> [configure\_nfs\_server](#input\_configure\_nfs\_server) | Specify if NFS server will be configured. This will allow you easily to share files between PowerVS instances (e.g., SAP installation files). NFS server will be installed on the private-svs vsi. | `bool` | `true` | no |
| <a name="input_configure_ntp_forwarder"></a> [configure\_ntp\_forwarder](#input\_configure\_ntp\_forwarder) | Specify if NTP forwarder will be configured. This will allow you to synchronize time between IBM PowerVS instances. NTP forwarder will be installed on the private-svs vsi. | `bool` | `true` | no |
| <a name="input_configure_os"></a> [configure\_os](#input\_configure\_os) | Specify if OS on PowerVS instances should be configured for SAP or if only PowerVS instances should be created. | `bool` | `true` | no |
| <a name="input_dns_forwarder_config"></a> [dns\_forwarder\_config](#input\_dns\_forwarder\_config) | Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS. | <pre>object({<br>    dns_servers = string<br>  })</pre> | <pre>{<br>  "dns_servers": "161.26.0.7; 161.26.0.8; 9.9.9.9;"<br>}</pre> | no |
| <a name="input_external_access_ip"></a> [external\_access\_ip](#input\_external\_access\_ip) | Specify the IP address or CIDR to login through SSH to the environment after deployment. Access to this environment will be allowed only from this IP address. | `string` | `""` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | `null` | no |
| <a name="input_landing_zone_configuration"></a> [landing\_zone\_configuration](#input\_landing\_zone\_configuration) | OS image distro for VPC landing zone. Supported values are 'RHEL' or 'SLES' only. | `string` | n/a | yes |
| <a name="input_nfs_client_directory"></a> [nfs\_client\_directory](#input\_nfs\_client\_directory) | NFS directory on PowerVS instances. Will be used only if nfs\_server is setup in 'Power infrastructure for regulated industries' | `string` | `"/nfs"` | no |
| <a name="input_powervs_backup_network"></a> [powervs\_backup\_network](#input\_powervs\_backup\_network) | Name of the IBM Cloud PowerVS backup network and CIDR to create. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.52.0.0/24",<br>  "name": "bkp_net"<br>}</pre> | no |
| <a name="input_powervs_image_names"></a> [powervs\_image\_names](#input\_powervs\_image\_names) | List of Images to be imported into cloud account from catalog images | `list(string)` | <pre>[<br>  "SLES15-SP3-SAP",<br>  "SLES15-SP3-SAP-NETWEAVER",<br>  "RHEL8-SP4-SAP",<br>  "RHEL8-SP4-SAP-NETWEAVER"<br>]</pre> | no |
| <a name="input_powervs_management_network"></a> [powervs\_management\_network](#input\_powervs\_management\_network) | Name of the IBM Cloud PowerVS management subnet and CIDR to create. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.51.0.0/24",<br>  "name": "mgmt_net"<br>}</pre> | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_share_cpu_proc_type"></a> [powervs\_share\_cpu\_proc\_type](#input\_powervs\_share\_cpu\_proc\_type) | Dedicated or shared processors | `string` | `null` | no |
| <a name="input_powervs_share_instance_name"></a> [powervs\_share\_instance\_name](#input\_powervs\_share\_instance\_name) | Name of instance which will be created | `string` | n/a | yes |
| <a name="input_powervs_share_memory_size"></a> [powervs\_share\_memory\_size](#input\_powervs\_share\_memory\_size) | Amount of memory | `string` | `2` | no |
| <a name="input_powervs_share_number_of_instances"></a> [powervs\_share\_number\_of\_instances](#input\_powervs\_share\_number\_of\_instances) | Number of instances which will be created | `number` | `1` | no |
| <a name="input_powervs_share_number_of_processors"></a> [powervs\_share\_number\_of\_processors](#input\_powervs\_share\_number\_of\_processors) | Number of processors | `string` | `null` | no |
| <a name="input_powervs_share_server_type"></a> [powervs\_share\_server\_type](#input\_powervs\_share\_server\_type) | Processor type e980/s922/e1080/s1022 | `string` | `null` | no |
| <a name="input_powervs_share_storage_config"></a> [powervs\_share\_storage\_config](#input\_powervs\_share\_storage\_config) | DISKS To be created and attached to PowerVS Instance. Comma separated values.'disk\_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_powervs_share_vsi_os_config"></a> [powervs\_share\_vsi\_os\_config](#input\_powervs\_share\_vsi\_os\_config) | OS distro for powervs share instance vsi. Supported values are 'RHEL' or 'SLES' only. Provisions images RHEL8-SP4-SAP-NETWEAVER or SLES15-SP3-SAP-NETWEAVER as per OS config selection. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters. | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | Domain name to be set. | `string` | `""` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to public SSH key referenced by 'ssh\_public\_key'. Entered data must be in [heredoc strings format](https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud PowerVS workspace | `list(string)` | <pre>[<br>  "sap"<br>]</pre> | no |

## Outputs

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
