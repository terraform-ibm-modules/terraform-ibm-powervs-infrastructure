<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.82.1 |
| <a name="requirement_restapi"></a> [restapi](#requirement\_restapi) | 2.0.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ocp_cluster_deployment"></a> [ocp\_cluster\_deployment](#module\_ocp\_cluster\_deployment) | ../../modules/ansible | n/a |
| <a name="module_ocp_cluster_install_configuration"></a> [ocp\_cluster\_install\_configuration](#module\_ocp\_cluster\_install\_configuration) | ../../modules/ansible | n/a |
| <a name="module_ocp_cluster_manifest_creation"></a> [ocp\_cluster\_manifest\_creation](#module\_ocp\_cluster\_manifest\_creation) | ../../modules/ansible | n/a |
| <a name="module_standard"></a> [standard](#module\_standard) | ../../modules/powervs-vpc-landing-zone | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_auth_token.auth_token](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.82.1/docs/data-sources/iam_auth_token) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_IC_SCHEMATICS_WORKSPACE_ID"></a> [IC\_SCHEMATICS\_WORKSPACE\_ID](#input\_IC\_SCHEMATICS\_WORKSPACE\_ID) | leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace | `string` | `""` | no |
| <a name="input_ansible_vault_password"></a> [ansible\_vault\_password](#input\_ansible\_vault\_password) | Vault password to encrypt ansible playbooks that contain sensitive information. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]\_{\|}~. | `string` | n/a | yes |
| <a name="input_client_to_site_vpn"></a> [client\_to\_site\_vpn](#input\_client\_to\_site\_vpn) | VPN configuration - the client ip pool and list of users email ids to access the environment. If enabled, then a Secret Manager instance is also provisioned with certificates generated. See optional parameters to reuse an existing Secrets manager instance. | <pre>object({<br/>    enable                        = bool<br/>    client_ip_pool                = string<br/>    vpn_client_access_group_users = list(string)<br/>  })</pre> | <pre>{<br/>  "client_ip_pool": "192.168.0.0/16",<br/>  "enable": true,<br/>  "vpn_client_access_group_users": []<br/>}</pre> | no |
| <a name="input_cluster_base_domain"></a> [cluster\_base\_domain](#input\_cluster\_base\_domain) | The base domain name that will be used by the cluster. (ie: example.com) | `string` | n/a | yes |
| <a name="input_cluster_dir"></a> [cluster\_dir](#input\_cluster\_dir) | The directory that holds the artifacts of the OpenShift cluster creation. | `string` | `"ocp-powervs-deploy"` | no |
| <a name="input_cluster_master_node_config"></a> [cluster\_master\_node\_config](#input\_cluster\_master\_node\_config) | Configuration for the master nodes of the OpenShift cluster, including CPU, system type, processor type, and replica count. If system\_type is null, it's chosen based on whether it's supported in the region. This can be overwritten by passing a value, e.g. 's1022' or 's922'. Memory is in GB. | <pre>object({<br/>    processors  = number<br/>    system_type = string<br/>    proc_type   = string<br/>    memory      = number<br/>    replicas    = number<br/>  })</pre> | <pre>{<br/>  "memory": 32,<br/>  "proc_type": "Dedicated",<br/>  "processors": 4,<br/>  "replicas": 3,<br/>  "system_type": null<br/>}</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and a unique identifier used as prefix for resources. Must begin with a lowercase letter and end with a lowercase letter or number. Must contain only lowercase letters, numbers, and - characters. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters. | `string` | n/a | yes |
| <a name="input_cluster_network_config"></a> [cluster\_network\_config](#input\_cluster\_network\_config) | Configuration object for the OpenShift cluster and service network CIDRs. | <pre>object({<br/>    cluster_network_cidr         = string<br/>    cluster_service_network_cidr = string<br/>    cluster_machine_network_cidr = string<br/>  })</pre> | <pre>{<br/>  "cluster_machine_network_cidr": "10.72.0.0/24",<br/>  "cluster_network_cidr": "10.128.0.0/14",<br/>  "cluster_service_network_cidr": "10.67.0.0/16"<br/>}</pre> | no |
| <a name="input_cluster_worker_node_config"></a> [cluster\_worker\_node\_config](#input\_cluster\_worker\_node\_config) | Configuration for the worker nodes of the OpenShift cluster, including CPU, system type, processor type, and replica count. If system\_type is null, it's chosen based on whether it's supported in the region. This can be overwritten by passing a value, e.g. 's1022' or 's922'. Memory is in GB. | <pre>object({<br/>    processors  = number<br/>    system_type = string<br/>    proc_type   = string<br/>    memory      = number<br/>    replicas    = number<br/>  })</pre> | <pre>{<br/>  "memory": 32,<br/>  "proc_type": "Dedicated",<br/>  "processors": 4,<br/>  "replicas": 3,<br/>  "system_type": null<br/>}</pre> | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Specify whether Monitoring will be enabled. This includes the creation of an IBM Cloud Monitoring Instance and an Intel Monitoring Instance to host the services. If you already have an existing monitoring instance then specify in optional parameter 'existing\_monitoring\_instance\_crn' and setting this parameter to true. | `bool` | `false` | no |
| <a name="input_enable_scc_wp"></a> [enable\_scc\_wp](#input\_enable\_scc\_wp) | Enable SCC Workload Protection and install and configure the SCC Workload Protection agent on all intel VSIs in this deployment. If set to true, then value for 'ansible\_vault\_password' in optional parameter must be set. | `bool` | `true` | no |
| <a name="input_existing_monitoring_instance_crn"></a> [existing\_monitoring\_instance\_crn](#input\_existing\_monitoring\_instance\_crn) | Existing CRN of IBM Cloud Monitoring Instance. If value is null, then an IBM Cloud Monitoring Instance will not be created but an intel VSI instance will be created if 'enable\_monitoring' is true. | `string` | `null` | no |
| <a name="input_existing_sm_instance_guid"></a> [existing\_sm\_instance\_guid](#input\_existing\_sm\_instance\_guid) | An existing Secrets Manager GUID. If not provided a new instance will be provisioned. | `string` | `null` | no |
| <a name="input_existing_sm_instance_region"></a> [existing\_sm\_instance\_region](#input\_existing\_sm\_instance\_region) | Required if value is passed into `var.existing_sm_instance_guid`. | `string` | `null` | no |
| <a name="input_external_access_ip"></a> [external\_access\_ip](#input\_external\_access\_ip) | Specify the source IP address or CIDR for login through SSH to the environment after deployment. Access to the environment will be allowed only from this IP address. Can be set to 'null' if you choose to use client to site vpn. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_network_services_vsi_profile"></a> [network\_services\_vsi\_profile](#input\_network\_services\_vsi\_profile) | Compute profile configuration of the network services vsi (cpu and memory configuration). Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui). | `string` | `"cx2-2x4"` | no |
| <a name="input_openshift_pull_secret"></a> [openshift\_pull\_secret](#input\_openshift\_pull\_secret) | Pull secret from Red Hat OpenShift Cluster Manager for authenticating OpenShift image downloads from Red Hat container registries. | `map(any)` | n/a | yes |
| <a name="input_openshift_release"></a> [openshift\_release](#input\_openshift\_release) | The OpenShift IPI release version to deploy. | `string` | `"4.19.5"` | no |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. | `string` | n/a | yes |
| <a name="input_sm_service_plan"></a> [sm\_service\_plan](#input\_sm\_service\_plan) | The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: `standard` and `trial`. Only used if `existing_sm_instance_guid` is set to null. | `string` | `"standard"` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) to login to Intel VSIs to configure network management services (SQUID, NTP, DNS and ansible). Should match to public SSH key referenced by 'ssh\_public\_key'. The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud PowerVS workspace | `list(string)` | `[]` | no |
| <a name="input_user_id"></a> [user\_id](#input\_user\_id) | The IBM Cloud login user ID associated with the account where the cluster will be deployed. | `string` | n/a | yes |
| <a name="input_vpc_intel_images"></a> [vpc\_intel\_images](#input\_vpc\_intel\_images) | Stock OS image names for creating VPC landing zone VSI instances: RHEL (management and network services) and SLES (monitoring). | <pre>object({<br/>    rhel_image = string<br/>    sles_image = string<br/>  })</pre> | <pre>{<br/>  "rhel_image": "ibm-redhat-9-4-amd64-sap-applications-5",<br/>  "sles_image": "ibm-sles-15-6-amd64-sap-applications-3"<br/>}</pre> | no |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
