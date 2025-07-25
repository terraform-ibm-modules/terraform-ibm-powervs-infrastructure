# IBM Cloud Solution for Power Virtual Server with VPC Landing Zone Quickstart (Standard plus VSI) Variation

This example sets up the following infrastructure:
- A **VPC Infrastructure** with the following components:
    - One VSI for management (jump/bastion)
    - One VSI for network-services configured as squid proxy, NTP and DNS servers(using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/). This VSI also acts as central ansible execution node.
    - Optional VSI for Monitoring host
    - Optional [Client to site VPN server](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-client-to-site-overview)
    - Optional [File storage share](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create&interface=ui)
    - Optional [Application load balancer](https://cloud.ibm.com/docs/vpc?topic=vpc-load-balancers&interface=ui)
    - Optional [IBM Cloud Security and Compliance Center Workload Protection](https://cloud.ibm.com/docs/workload-protection) and SCC Workload Protection agent configuration on the VSIs in the deployment
    - IBM Cloud Object storage(COS) Virtual Private endpoint gateway(VPE)
    - IBM Cloud Object storage(COS) Instance and buckets
    - VPC flow logs
    - KMS keys
    - Activity tracker
    - Optional Secrets Manager Instance Instance with private certificate.

- A local or global **transit gateway**
- An optional IBM Cloud Monitoring Instance

- A **Power Virtual Server** workspace with the following network topology:
    - Creates two private networks: a management network and a backup network.
    - Attaches the PowerVS workspace to transit gateway.
    - Creates an SSH key.

- A **PowerVS Instance** with following options:
    - t-shirt profile (Aix/IBMi/SAP Image)
    - Custom profile ( cores, memory, storage and image)
    - 1 volume
    - Network management services, filesystems and SCC Workload protection agents are configured for AIX and Linux instances.

## Solutions

| Variation  | Available on IBM Catalog  |  Requires Schematics Workspace ID | Creates VPC Landing Zone | Performs VPC VSI OS Config | Creates PowerVS Infrastructure | Creates PowerVS Instance | Performs PowerVS OS Config |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [Quickstart (Standard plus VSI)](./)    | :heavy_check_mark:  |   N/A  | :heavy_check_mark:| :heavy_check_mark: | :heavy_check_mark:  | :heavy_check_mark: | :heavy_check_mark: |

## Reference architecture
[Quickstart (Standard plus VSI) variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/standard-with.instance/deploy-arch-ibm-pvs-inf-standard-plus-vsi.md)

## Architecture diagram
![Quickstart (Standard plus VSI)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/standard-plus-vsi/deploy-arch-ibm-pvs-inf-standard-plus-vsi.svg)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.80.4 |
| <a name="requirement_restapi"></a> [restapi](#requirement\_restapi) | 2.0.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.13.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pi_scc_wp_agent"></a> [pi\_scc\_wp\_agent](#module\_pi\_scc\_wp\_agent) | ../../modules/powervs-vpc-landing-zone/submodules/ansible | n/a |
| <a name="module_powervs_instance"></a> [powervs\_instance](#module\_powervs\_instance) | terraform-ibm-modules/powervs-instance/ibm | 2.6.2 |
| <a name="module_standard"></a> [standard](#module\_standard) | ../../modules/powervs-vpc-landing-zone | n/a |

### Resources

| Name | Type |
|------|------|
| [terraform_data.aix_init](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [time_sleep.wait_for_dependencies](https://registry.terraform.io/providers/hashicorp/time/0.13.1/docs/resources/sleep) | resource |
| [ibm_iam_auth_token.auth_token](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.80.4/docs/data-sources/iam_auth_token) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_IC_SCHEMATICS_WORKSPACE_ID"></a> [IC\_SCHEMATICS\_WORKSPACE\_ID](#input\_IC\_SCHEMATICS\_WORKSPACE\_ID) | leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace | `string` | `""` | no |
| <a name="input_ansible_vault_password"></a> [ansible\_vault\_password](#input\_ansible\_vault\_password) | Vault password to encrypt ansible playbooks that contain sensitive information. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]\_{\|}~. | `string` | n/a | yes |
| <a name="input_client_to_site_vpn"></a> [client\_to\_site\_vpn](#input\_client\_to\_site\_vpn) | VPN configuration - the client ip pool and list of users email ids to access the environment. If enabled, then a Secret Manager instance is also provisioned with certificates generated. See optional parameters to reuse an existing Secrets manager instance. | <pre>object({<br/>    enable                        = bool<br/>    client_ip_pool                = string<br/>    vpn_client_access_group_users = list(string)<br/>  })</pre> | <pre>{<br/>  "client_ip_pool": "192.168.0.0/16",<br/>  "enable": true,<br/>  "vpn_client_access_group_users": []<br/>}</pre> | no |
| <a name="input_configure_dns_forwarder"></a> [configure\_dns\_forwarder](#input\_configure\_dns\_forwarder) | Specify if DNS forwarder will be configured. This will allow you to use central DNS servers (e.g. IBM Cloud DNS servers) sitting outside of the created IBM PowerVS infrastructure. If yes, ensure 'dns\_forwarder\_config' optional variable is set properly. DNS forwarder will be installed on the network-services vsi. | `bool` | `true` | no |
| <a name="input_configure_nfs_server"></a> [configure\_nfs\_server](#input\_configure\_nfs\_server) | Specify if NFS server will be configured. This will allow you easily to share files between PowerVS instances (e.g., SAP installation files). [File storage share and mount target](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create&interface=ui) in VPC will be created.. If yes, ensure 'nfs\_server\_config' optional variable is set properly below. Default value is '200GB' which will be mounted on specified directory in network-service vsi. | `bool` | `true` | no |
| <a name="input_configure_ntp_forwarder"></a> [configure\_ntp\_forwarder](#input\_configure\_ntp\_forwarder) | Specify if NTP forwarder will be configured. This will allow you to synchronize time between IBM PowerVS instances. NTP forwarder will be installed on the network-services vsi. | `bool` | `true` | no |
| <a name="input_custom_profile"></a> [custom\_profile](#input\_custom\_profile) | Overrides t-shirt profile: Custom PowerVS instance. Specify 'sap\_profile\_id' [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs) or combination of 'cores' & 'memory'. Optionally volumes can be created. | <pre>object({<br/>    sap_profile_id = string<br/>    cores          = string<br/>    memory         = string<br/>    server_type    = string<br/>    proc_type      = string<br/>    storage = object({<br/>      size = string<br/>      tier = string<br/>    })<br/>  })</pre> | <pre>{<br/>  "cores": "",<br/>  "memory": "",<br/>  "proc_type": "",<br/>  "sap_profile_id": null,<br/>  "server_type": "",<br/>  "storage": {<br/>    "size": "",<br/>    "tier": ""<br/>  }<br/>}</pre> | no |
| <a name="input_custom_profile_instance_boot_image"></a> [custom\_profile\_instance\_boot\_image](#input\_custom\_profile\_instance\_boot\_image) | Override the t-shirt size specs of PowerVS Workspace instance by selecting an image name and providing valid 'custom\_profile' optional parameter. | `string` | `"none"` | no |
| <a name="input_dns_forwarder_config"></a> [dns\_forwarder\_config](#input\_dns\_forwarder\_config) | Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS. | <pre>object({<br/>    dns_servers = string<br/>  })</pre> | <pre>{<br/>  "dns_servers": "161.26.0.7; 161.26.0.8; 9.9.9.9;"<br/>}</pre> | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Specify whether Monitoring will be enabled. This includes the creation of an IBM Cloud Monitoring Instance and an Intel Monitoring Instance to host the services. If you already have an existing monitoring instance then specify in optional parameter 'existing\_monitoring\_instance\_crn' and setting this parameter to true. | `bool` | `false` | no |
| <a name="input_enable_scc_wp"></a> [enable\_scc\_wp](#input\_enable\_scc\_wp) | Enable SCC Workload Protection and install and configure the SCC Workload Protection agent on all intel VSIs in this deployment. If set to true, then value for 'ansible\_vault\_password' in optional parameter must be set. | `bool` | `true` | no |
| <a name="input_existing_monitoring_instance_crn"></a> [existing\_monitoring\_instance\_crn](#input\_existing\_monitoring\_instance\_crn) | Existing CRN of IBM Cloud Monitoring Instance. If value is null, then an IBM Cloud Monitoring Instance will not be created but an intel VSI instance will be created if 'enable\_monitoring' is true. | `string` | `null` | no |
| <a name="input_existing_sm_instance_guid"></a> [existing\_sm\_instance\_guid](#input\_existing\_sm\_instance\_guid) | An existing Secrets Manager GUID. If not provided a new instance will be provisioned. | `string` | `null` | no |
| <a name="input_existing_sm_instance_region"></a> [existing\_sm\_instance\_region](#input\_existing\_sm\_instance\_region) | Required if value is passed into `var.existing_sm_instance_guid`. | `string` | `null` | no |
| <a name="input_external_access_ip"></a> [external\_access\_ip](#input\_external\_access\_ip) | Specify the source IP address or CIDR for login through SSH to the environment after deployment. Access to the environment will be allowed only from this IP address. Can be set to 'null' if you choose to use client to site vpn. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_network_services_vsi_profile"></a> [network\_services\_vsi\_profile](#input\_network\_services\_vsi\_profile) | Compute profile configuration of the network services vsi (cpu and memory configuration). Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui). | `string` | `"cx2-2x4"` | no |
| <a name="input_nfs_server_config"></a> [nfs\_server\_config](#input\_nfs\_server\_config) | Configuration for the NFS server. 'size' is in GB, 'iops' is maximum input/output operation performance bandwidth per second, 'mount\_path' defines the target mount point on os. Set 'configure\_nfs\_server' to false to ignore creating file storage share. | <pre>object({<br/>    size       = number<br/>    iops       = number<br/>    mount_path = string<br/>  })</pre> | <pre>{<br/>  "iops": 600,<br/>  "mount_path": "/nfs",<br/>  "size": 200<br/>}</pre> | no |
| <a name="input_powervs_backup_network"></a> [powervs\_backup\_network](#input\_powervs\_backup\_network) | Name of the IBM Cloud PowerVS backup network and CIDR to create. | <pre>object({<br/>    name = string<br/>    cidr = string<br/>  })</pre> | <pre>{<br/>  "cidr": "10.52.0.0/24",<br/>  "name": "bkp_net"<br/>}</pre> | no |
| <a name="input_powervs_management_network"></a> [powervs\_management\_network](#input\_powervs\_management\_network) | Name of the IBM Cloud PowerVS management subnet and CIDR to create. | <pre>object({<br/>    name = string<br/>    cidr = string<br/>  })</pre> | <pre>{<br/>  "cidr": "10.51.0.0/24",<br/>  "name": "mgmt_net"<br/>}</pre> | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | `"Default"` | no |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. Must contain only lowercase letters, numbers, and - characters. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters. | `string` | n/a | yes |
| <a name="input_sm_service_plan"></a> [sm\_service\_plan](#input\_sm\_service\_plan) | The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: `standard` and `trial`. Only used if `existing_sm_instance_guid` is set to null. | `string` | `"standard"` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) to login to Intel VSIs to configure network management services (SQUID, NTP, DNS and ansible). Should match to public SSH key referenced by 'ssh\_public\_key'. The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud PowerVS workspace | `list(string)` | `[]` | no |
| <a name="input_tshirt_size"></a> [tshirt\_size](#input\_tshirt\_size) | PowerVS instance profiles. These profiles can be overridden by specifying 'custom\_profile\_instance\_boot\_image' and 'custom\_profile' values in optional parameters. | <pre>object({<br/>    tshirt_size = string<br/>    image       = string<br/>  })</pre> | n/a | yes |
| <a name="input_vpc_intel_images"></a> [vpc\_intel\_images](#input\_vpc\_intel\_images) | Stock OS image names for creating VPC landing zone VSI instances: RHEL (management and network services) and SLES (monitoring). | <pre>object({<br/>    rhel_image = string<br/>    sles_image = string<br/>  })</pre> | <pre>{<br/>  "rhel_image": "ibm-redhat-9-4-amd64-sap-applications-5",<br/>  "sles_image": "ibm-sles-15-6-amd64-sap-applications-3"<br/>}</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Access host(jump/bastion) for created PowerVS infrastructure. |
| <a name="output_ansible_host_or_ip"></a> [ansible\_host\_or\_ip](#output\_ansible\_host\_or\_ip) | Central Ansible node private IP address. |
| <a name="output_application_load_balancer"></a> [application\_load\_balancer](#output\_application\_load\_balancer) | Details of application load balancer. |
| <a name="output_dns_host_or_ip"></a> [dns\_host\_or\_ip](#output\_dns\_host\_or\_ip) | DNS forwarder host for created PowerVS infrastructure. |
| <a name="output_kms_key_map"></a> [kms\_key\_map](#output\_kms\_key\_map) | Map of ids and keys for KMS keys created |
| <a name="output_monitoring_instance"></a> [monitoring\_instance](#output\_monitoring\_instance) | Details of the IBM Cloud Monitoring Instance: CRN, location, guid. |
| <a name="output_network_services_config"></a> [network\_services\_config](#output\_network\_services\_config) | Complete configuration of network management services. |
| <a name="output_nfs_host_or_ip_path"></a> [nfs\_host\_or\_ip\_path](#output\_nfs\_host\_or\_ip\_path) | NFS host for created PowerVS infrastructure. |
| <a name="output_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#output\_ntp\_host\_or\_ip) | NTP host for created PowerVS infrastructure. |
| <a name="output_powervs_backup_subnet"></a> [powervs\_backup\_subnet](#output\_powervs\_backup\_subnet) | Name, ID and CIDR of backup private network in created PowerVS infrastructure. |
| <a name="output_powervs_images"></a> [powervs\_images](#output\_powervs\_images) | Object containing imported PowerVS image names and image ids. |
| <a name="output_powervs_instance_management_ip"></a> [powervs\_instance\_management\_ip](#output\_powervs\_instance\_management\_ip) | IP address of the primary network interface of IBM PowerVS instance. |
| <a name="output_powervs_instance_private_ips"></a> [powervs\_instance\_private\_ips](#output\_powervs\_instance\_private\_ips) | All private IP addresses (as a list) of IBM PowerVS instance. |
| <a name="output_powervs_management_subnet"></a> [powervs\_management\_subnet](#output\_powervs\_management\_subnet) | Name, ID and CIDR of management private network in created PowerVS infrastructure. |
| <a name="output_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#output\_powervs\_resource\_group\_name) | IBM Cloud resource group where PowerVS infrastructure is created. |
| <a name="output_powervs_ssh_public_key"></a> [powervs\_ssh\_public\_key](#output\_powervs\_ssh\_public\_key) | SSH public key name and value in created PowerVS infrastructure. |
| <a name="output_powervs_storage_configuration"></a> [powervs\_storage\_configuration](#output\_powervs\_storage\_configuration) | Storage configuration of PowerVS instance. |
| <a name="output_powervs_workspace_guid"></a> [powervs\_workspace\_guid](#output\_powervs\_workspace\_guid) | PowerVS infrastructure workspace guid. The GUID of the resource instance. |
| <a name="output_powervs_workspace_id"></a> [powervs\_workspace\_id](#output\_powervs\_workspace\_id) | PowerVS infrastructure workspace id. The unique identifier of the new resource instance. |
| <a name="output_powervs_workspace_name"></a> [powervs\_workspace\_name](#output\_powervs\_workspace\_name) | PowerVS infrastructure workspace name. |
| <a name="output_powervs_zone"></a> [powervs\_zone](#output\_powervs\_zone) | Zone where PowerVS infrastructure is created. |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | The prefix that is associated with all resources. |
| <a name="output_proxy_host_or_ip_port"></a> [proxy\_host\_or\_ip\_port](#output\_proxy\_host\_or\_ip\_port) | Proxy host:port for created PowerVS infrastructure. |
| <a name="output_resource_group_data"></a> [resource\_group\_data](#output\_resource\_group\_data) | List of resource groups data used within landing zone. |
| <a name="output_scc_wp_instance"></a> [scc\_wp\_instance](#output\_scc\_wp\_instance) | Details of the Security and Compliance Center Workload Protection Instance: guid, access key, api\_endpoint, ingestion\_endpoint. |
| <a name="output_schematics_workspace_id"></a> [schematics\_workspace\_id](#output\_schematics\_workspace\_id) | ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics. |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key) | The string value of the ssh public key used when deploying VPC. |
| <a name="output_transit_gateway_id"></a> [transit\_gateway\_id](#output\_transit\_gateway\_id) | The ID of transit gateway. |
| <a name="output_transit_gateway_name"></a> [transit\_gateway\_name](#output\_transit\_gateway\_name) | The name of the transit gateway. |
| <a name="output_vpc_data"></a> [vpc\_data](#output\_vpc\_data) | List of VPC data. |
| <a name="output_vpc_names"></a> [vpc\_names](#output\_vpc\_names) | A list of the names of the VPC. |
| <a name="output_vsi_list"></a> [vsi\_list](#output\_vsi\_list) | A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP. |
| <a name="output_vsi_names"></a> [vsi\_names](#output\_vsi\_names) | A list of the vsis names provisioned within the VPCs. |
| <a name="output_vsi_ssh_key_data"></a> [vsi\_ssh\_key\_data](#output\_vsi\_ssh\_key\_data) | List of VSI SSH key data |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
