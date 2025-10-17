# IBM Cloud Solution for Power Virtual Server with VPC Landing Zone Quickstart OpenShift Variation

This example sets up an OpenShift Cluster on PowerVS following infrastructure:
- A **VPC Infrastructure** with the following components:
    - One VSI for management (jump/bastion)
    - One VSI for network-services configured as squid proxy (using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/). This VSI also acts as central ansible execution node.
    - Optional VSI for Monitoring host
    - Optional [Client to site VPN server](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-client-to-site-overview)
    - Optional [IBM Cloud Security and Compliance Center Workload Protection](https://cloud.ibm.com/docs/workload-protection) and SCC Workload Protection agent configuration on the VSIs in the deployment
    - IBM Cloud Object storage(COS) Virtual Private endpoint gateway(VPE)
    - IBM Cloud Object storage(COS) Instance and buckets
    - VPC flow logs
    - KMS keys
    - Activity tracker
    - Optional Secrets Manager Instance Instance with private certificate.
    - Three application load balancers for internal OpenShift API, public OpenShift API, and OpenShift applications

- A local **transit gateway**
- An IBM Cloud DNS Service Instance
- An optional IBM Cloud Monitoring Instance

- A **Power Virtual Server** workspace with the following features:
    - A DHCP machine subnet to which all nodes are assigned.
    - Attaches the PowerVS workspace to transit gateway.
    - Creates an SSH key.

- A configurable number of **PowerVS Instances**:
    - 1 or 3 master nodes
    - 2 or more worker nodes
    - Custom profile (cores, memory, machine type, core type)

Due to technical limitations, the cost estimate Projects gives does not include the PowerVS resources deployed. The cost estimate given on the catalog page is accurate for a deployment using default values. This only applies to the Quickstart OpenShift variation.
{: important}

## Solutions

| Variation  | Available on IBM Catalog  |  Requires Schematics Workspace ID | Creates VPC Landing Zone | Performs VPC VSI OS Config | Creates PowerVS Infrastructure | Creates PowerVS Instance | Creates OpenShift Cluster on PowerVS |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [Quickstart OpenShift](./)    | :heavy_check_mark:  |   N/A  | :heavy_check_mark:| :heavy_check_mark: | :heavy_check_mark:  | :heavy_check_mark: | :heavy_check_mark: |

## Reference architecture
[Quickstart OpenShift](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/standard-openshift/deploy-arch-ibm-pvs-inf-standard-openshift.md)

## Architecture diagram
![Quickstart OpenShift](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/standard-openshift/deploy-arch-ibm-pvs-inf-standard-openshift.svg)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.83.3 |
| <a name="requirement_restapi"></a> [restapi](#requirement\_restapi) | 2.0.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ocp_cluster_deployment"></a> [ocp\_cluster\_deployment](#module\_ocp\_cluster\_deployment) | ./ansible | n/a |
| <a name="module_ocp_cluster_install_configuration"></a> [ocp\_cluster\_install\_configuration](#module\_ocp\_cluster\_install\_configuration) | ./ansible | n/a |
| <a name="module_ocp_cluster_manifest_creation"></a> [ocp\_cluster\_manifest\_creation](#module\_ocp\_cluster\_manifest\_creation) | ./ansible | n/a |
| <a name="module_standard"></a> [standard](#module\_standard) | ../../modules/powervs-vpc-landing-zone | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_auth_token.auth_token](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.83.3/docs/data-sources/iam_auth_token) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_IC_SCHEMATICS_WORKSPACE_ID"></a> [IC\_SCHEMATICS\_WORKSPACE\_ID](#input\_IC\_SCHEMATICS\_WORKSPACE\_ID) | leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace | `string` | `""` | no |
| <a name="input_ansible_vault_password"></a> [ansible\_vault\_password](#input\_ansible\_vault\_password) | Vault password to encrypt ansible playbooks that contain sensitive information. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]\_{\|}~. | `string` | n/a | yes |
| <a name="input_client_to_site_vpn"></a> [client\_to\_site\_vpn](#input\_client\_to\_site\_vpn) | VPN configuration - the client ip pool and list of users email ids to access the environment. If enabled, then a Secret Manager instance is also provisioned with certificates generated. See optional parameters to reuse an existing Secrets manager instance. | <pre>object({<br/>    enable                        = bool<br/>    client_ip_pool                = string<br/>    vpn_client_access_group_users = list(string)<br/>  })</pre> | <pre>{<br/>  "client_ip_pool": "192.168.0.0/16",<br/>  "enable": true,<br/>  "vpn_client_access_group_users": []<br/>}</pre> | no |
| <a name="input_cluster_base_domain"></a> [cluster\_base\_domain](#input\_cluster\_base\_domain) | The base domain name that will be used by the cluster. Only .test, .example, and .invalid domains are supported (ie: domain.example). | `string` | n/a | yes |
| <a name="input_cluster_master_node_config"></a> [cluster\_master\_node\_config](#input\_cluster\_master\_node\_config) | Configuration for the master nodes of the OpenShift cluster, including CPU, system type, processor type, and replica count. If system\_type is null, it's chosen based on whether it's supported in the region. This can be overwritten by passing a value, e.g. 's1022' or 's922'. Memory is in GB. | <pre>object({<br/>    processors  = number<br/>    memory      = number<br/>    system_type = string<br/>    proc_type   = string<br/>    replicas    = number<br/>  })</pre> | <pre>{<br/>  "memory": "32",<br/>  "proc_type": "Shared",<br/>  "processors": "4",<br/>  "replicas": "3",<br/>  "system_type": null<br/>}</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and a unique identifier used as prefix for resources. Must begin with a lowercase letter and end with a lowercase letter or number. Must contain only lowercase letters, numbers, and - characters. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters. | `string` | n/a | yes |
| <a name="input_cluster_network_config"></a> [cluster\_network\_config](#input\_cluster\_network\_config) | Configuration object for the OpenShift cluster and service network CIDRs. | <pre>object({<br/>    cluster_network_cidr         = string<br/>    cluster_service_network_cidr = string<br/>    cluster_machine_network_cidr = string<br/>  })</pre> | <pre>{<br/>  "cluster_machine_network_cidr": "10.72.0.0/24",<br/>  "cluster_network_cidr": "10.128.0.0/14",<br/>  "cluster_service_network_cidr": "10.67.0.0/16"<br/>}</pre> | no |
| <a name="input_cluster_worker_node_config"></a> [cluster\_worker\_node\_config](#input\_cluster\_worker\_node\_config) | Configuration for the worker nodes of the OpenShift cluster, including CPU, system type, processor type, and replica count. If system\_type is null, it's chosen based on whether it's supported in the region. This can be overwritten by passing a value, e.g. 's1022' or 's922'. Memory is in GB. | <pre>object({<br/>    processors  = number<br/>    memory      = number<br/>    system_type = string<br/>    proc_type   = string<br/>    replicas    = number<br/>  })</pre> | <pre>{<br/>  "memory": "32",<br/>  "proc_type": "Shared",<br/>  "processors": "4",<br/>  "replicas": "3",<br/>  "system_type": null<br/>}</pre> | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Specify whether Monitoring will be enabled. This includes the creation of an IBM Cloud Monitoring Instance. If you already have an existing monitoring instance, set this to true and specify in optional parameter 'existing\_monitoring\_instance\_crn'. | `bool` | `false` | no |
| <a name="input_enable_scc_wp"></a> [enable\_scc\_wp](#input\_enable\_scc\_wp) | Enable SCC Workload Protection and install and configure the SCC Workload Protection agent on all intel VSIs in this deployment. | `bool` | `true` | no |
| <a name="input_existing_sm_instance_guid"></a> [existing\_sm\_instance\_guid](#input\_existing\_sm\_instance\_guid) | An existing Secrets Manager GUID. If not provided a new instance will be provisioned. | `string` | `null` | no |
| <a name="input_existing_sm_instance_region"></a> [existing\_sm\_instance\_region](#input\_existing\_sm\_instance\_region) | Required if value is passed into `var.existing_sm_instance_guid`. | `string` | `null` | no |
| <a name="input_external_access_ip"></a> [external\_access\_ip](#input\_external\_access\_ip) | Specify the source IP address or CIDR for login through SSH to the environment after deployment. Access to the environment will be allowed only from this IP address. Can be set to 'null' if you choose to use client to site vpn. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_intel_user_data"></a> [intel\_user\_data](#input\_intel\_user\_data) | User data that automatically performs common configuration tasks or runs scripts only on the intel VSIs. For more information, see https://cloud.ibm.com/docs/vpc?topic=vpc-user-data. For information on using the user\_data variable, please refer: https://cloud.ibm.com/docs/secure-infrastructure-vpc?topic=secure-infrastructure-vpc-user-data | `string` | `null` | no |
| <a name="input_network_services_vsi_profile"></a> [network\_services\_vsi\_profile](#input\_network\_services\_vsi\_profile) | Compute profile configuration of the network services vsi (cpu and memory configuration). Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui). | `string` | `"cx2-2x4"` | no |
| <a name="input_openshift_pull_secret"></a> [openshift\_pull\_secret](#input\_openshift\_pull\_secret) | Pull secret from Red Hat OpenShift Cluster Manager for authenticating OpenShift image downloads from Red Hat container registries. A RedHat account is required. It can be obtained on https://console.redhat.com/openshift/install/pull-secret. | `string` | n/a | yes |
| <a name="input_openshift_release"></a> [openshift\_release](#input\_openshift\_release) | The OpenShift IPI release version to deploy. | `string` | `"4.19.13"` | no |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. Supported regions are: dal10, dal12, eu-de-1, eu-de-2, lon04, lon06, mad02, mad04, osa21, sao01, sao04, syd04, syd05, us-east, us-south, wdc06, wdc07. | `string` | n/a | yes |
| <a name="input_sm_service_plan"></a> [sm\_service\_plan](#input\_sm\_service\_plan) | The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: `standard` and `trial`. Only used if `existing_sm_instance_guid` is set to null. | `string` | `"standard"` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) to login to Intel VSIs to configure network management services (SQUID, NTP, DNS and ansible). Should match to public SSH key referenced by 'ssh\_public\_key'. The key is not uploaded or stored. If you're unsure how to create one, check [Generate a SSH Key Pair](https://cloud.ibm.com/docs/powervs-vpc?topic=powervs-vpc-powervs-automation-prereqs#powervs-automation-ssh-key) in our docs. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) in the VPC docs. | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. If you're unsure how to create one, check [Generate a SSH Key Pair](https://cloud.ibm.com/docs/powervs-vpc?topic=powervs-vpc-powervs-automation-prereqs#powervs-automation-ssh-key) in our docs. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) in the VPC docs. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud PowerVS workspace | `list(string)` | `[]` | no |
| <a name="input_user_id"></a> [user\_id](#input\_user\_id) | The IBM Cloud login user ID associated with the account where the cluster will be deployed. | `string` | n/a | yes |
| <a name="input_vpc_intel_images"></a> [vpc\_intel\_images](#input\_vpc\_intel\_images) | Stock OS image names for creating VPC landing zone VSI instances: RHEL (management and network services) and SLES (monitoring). | <pre>object({<br/>    rhel_image = string<br/>    sles_image = string<br/>  })</pre> | <pre>{<br/>  "rhel_image": "ibm-redhat-9-4-amd64-sap-applications-7",<br/>  "sles_image": "ibm-sles-15-7-amd64-sap-applications-1"<br/>}</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Access host(jump/bastion) for created PowerVS infrastructure. |
| <a name="output_ansible_host_or_ip"></a> [ansible\_host\_or\_ip](#output\_ansible\_host\_or\_ip) | Central Ansible node private IP address. |
| <a name="output_cluster_base_domain"></a> [cluster\_base\_domain](#output\_cluster\_base\_domain) | The base domain the cluster is using. |
| <a name="output_cluster_dir"></a> [cluster\_dir](#output\_cluster\_dir) | The directory on the network services VSI that holds the artifacts of the OpenShift cluster creation. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the cluster and the prefix that is associated with all resources. |
| <a name="output_cluster_resource_group"></a> [cluster\_resource\_group](#output\_cluster\_resource\_group) | The resource group where all cluster resources, Transit Gateway, VPC, and PowerVS resources reside. |
| <a name="output_kms_key_map"></a> [kms\_key\_map](#output\_kms\_key\_map) | Map of ids and keys for KMS keys created |
| <a name="output_monitoring_instance"></a> [monitoring\_instance](#output\_monitoring\_instance) | Details of the IBM Cloud Monitoring Instance: CRN, location, guid, monitoring\_host\_ip. monitoring\_host\_ip is an empty string since no additional host is needed for this variation. |
| <a name="output_network_load_balancer"></a> [network\_load\_balancer](#output\_network\_load\_balancer) | Details of network load balancer. |
| <a name="output_network_services_config"></a> [network\_services\_config](#output\_network\_services\_config) | Complete configuration of network management services. |
| <a name="output_powervs_ssh_public_key"></a> [powervs\_ssh\_public\_key](#output\_powervs\_ssh\_public\_key) | SSH public key name and value in created PowerVS infrastructure. |
| <a name="output_powervs_workspace_guid"></a> [powervs\_workspace\_guid](#output\_powervs\_workspace\_guid) | PowerVS infrastructure workspace guid. The GUID of the resource instance. |
| <a name="output_powervs_workspace_id"></a> [powervs\_workspace\_id](#output\_powervs\_workspace\_id) | PowerVS infrastructure workspace id. The unique identifier of the new resource instance. |
| <a name="output_powervs_workspace_name"></a> [powervs\_workspace\_name](#output\_powervs\_workspace\_name) | PowerVS infrastructure workspace name. |
| <a name="output_powervs_zone"></a> [powervs\_zone](#output\_powervs\_zone) | Zone where PowerVS infrastructure is created. |
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
