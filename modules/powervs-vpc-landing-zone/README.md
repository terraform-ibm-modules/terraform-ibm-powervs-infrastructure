# Module powervs-vpc-landing-zone

## IBM Power Virtual Server with VPC Landing Zone

This module provisions the following resources in IBM Cloud:
- A **VPC Infrastructure** with the following components:
    - One VSI for management (jump/bastion) VSI,
    - One VSI for network-services configured as squid proxy, NTP and DNS servers(using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/). This VSI also acts as central ansible execution node.
    - Optional VSI for Monitoring host
    - Optional [Client to site VPN server](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-client-to-site-overview)
    - Optional [File storage share](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create&interface=ui)
    - Optional [Application load balancer](https://cloud.ibm.com/docs/vpc?topic=vpc-load-balancers&interface=ui)
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
    - Attaches the PowerVS workspace to transit gateway
    - Creates an SSH key.
    - Optionally imports list of stock catalog images.
    - Optionally imports up to three custom images from Cloud Object Storage.

- Finally, interconnects both VPC and PowerVS infrastructure.

## Usage
```hcl
provider "ibm" {
  alias            = "ibm-pi"
  region           = ""
  zone             = ""
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

provider "ibm" {
  alias            = "ibm-is"
  region           = ""
  zone             = ""
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

module "powervs-vpc-landing-zone" {
  source  = "terraform-ibm-modules/powervs-infrastructure/ibm//modules//powervs-vpc-landing-zone"
  version = "x.x.x" # Replace "x.x.x" with a git release version to lock into a specific release

  providers = { ibm.ibm-is = ibm.ibm-is, ibm.ibm-pi = ibm.ibm-pi }

  powervs_zone                                 = var.powervs_zone
  prefix                                       = var.prefix
  external_access_ip                           = var.external_access_ip
  ssh_public_key                               = var.ssh_public_key
  ssh_private_key                              = var.ssh_private_key
  client_to_site_vpn                           = var.client_to_site_vpn                           #(optional.  default check vars)
  configure_dns_forwarder                      = var.configure_dns_forwarder                      #(optional,  default false)
  configure_ntp_forwarder                      = var.configure_ntp_forwarder                      #(optional,  default false)
  configure_nfs_server                         = var.configure_nfs_server                         #(optional.  default false)
  nfs_server_config                            = var.nfs_server_config                            #(optional.  default check vars)
  dns_forwarder_config                         = var.dns_forwarder_config                         #(optional.  default check vars)
  powervs_resource_group_name                  = var.powervs_resource_group_name                  #(optional.  default check vars)
  powervs_management_network                   = var.powervs_management_network                   #(optional.  default check vars)
  powervs_backup_network                       = var.powervs_backup_network                       #(optional.  default check vars)
  powervs_image_names                          = var.powervs_image_names                          #(optional.  default check vars)
  tags                                         = var.tags                                         #(optional.  default check vars)
  sm_service_plan                              = var.sm_service_plan
  powervs_custom_images                        = var.powervs_custom_images                        #(optional, default null)
  powervs_custom_image_cos_configuration       = var.powervs_custom_image_cos_configuration       #(optional, default null)
  powervs_custom_image_cos_service_credentials = var.powervs_custom_image_cos_service_credentials #(optional, default null)
  existing_sm_instance_guid                    = var.existing_sm_instance_guid                    #(optional.  default check vars)
  existing_sm_instance_region                  = var.existing_sm_instance_region                  #(optional.  default check vars)
  certificate_template_name                    = var.certificate_template_name                    #(optional.  default check vars)
  network_services_vsi_profile                 = var.network_services_vsi_profile                 #(optional.  default check vars)
  enable_monitoring                            = var.enable_monitoring                            #(optional.  default true)
  existing_monitoring_instance_crn             = var.existing_monitoring_instance_crn             #(optional.  default null)
}
```

### Notes:
Catalog image names to be imported into infrastructure can be found [here](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-workspace/blob/main/docs/catalog_images_list.md)

Creates VPC Landing Zone | Performs VPC VSI OS Config | Creates PowerVS Infrastructure | Creates PowerVS Instance | Performs PowerVS OS Config |
|  ------------- | ------------- | ------------- | ------------- | ------------- |
| :heavy_check_mark:  | :heavy_check_mark:  |  :heavy_check_mark: | N/A | N/A |


## Supported Reference architectures
1. [Standard variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/standard/deploy-arch-ibm-pvs-inf-standard.svg)
2. [Quickstart (Standard plus VSI) variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/standard-plus-vsi/deploy-arch-ibm-pvs-inf-standard-plus-vsi.svg)


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.65.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_client_to_site_vpn"></a> [client\_to\_site\_vpn](#module\_client\_to\_site\_vpn) | terraform-ibm-modules/client-to-site-vpn/ibm | 2.1.4 |
| <a name="module_configure_monitoring_host"></a> [configure\_monitoring\_host](#module\_configure\_monitoring\_host) | ./submodules/ansible | n/a |
| <a name="module_configure_network_services"></a> [configure\_network\_services](#module\_configure\_network\_services) | ./submodules/ansible | n/a |
| <a name="module_configure_scc_wp_agent"></a> [configure\_scc\_wp\_agent](#module\_configure\_scc\_wp\_agent) | ./submodules/ansible | n/a |
| <a name="module_landing_zone"></a> [landing\_zone](#module\_landing\_zone) | terraform-ibm-modules/landing-zone/ibm//patterns//vsi//module | 7.3.1 |
| <a name="module_powervs_workspace"></a> [powervs\_workspace](#module\_powervs\_workspace) | terraform-ibm-modules/powervs-workspace/ibm | 2.5.0 |
| <a name="module_private_secret_engine"></a> [private\_secret\_engine](#module\_private\_secret\_engine) | terraform-ibm-modules/secrets-manager-private-cert-engine/ibm | 1.3.5 |
| <a name="module_scc_wp_instance"></a> [scc\_wp\_instance](#module\_scc\_wp\_instance) | terraform-ibm-modules/scc-workload-protection/ibm | 1.4.3 |
| <a name="module_secrets_manager_group"></a> [secrets\_manager\_group](#module\_secrets\_manager\_group) | terraform-ibm-modules/secrets-manager-secret-group/ibm | 1.2.3 |
| <a name="module_secrets_manager_private_certificate"></a> [secrets\_manager\_private\_certificate](#module\_secrets\_manager\_private\_certificate) | terraform-ibm-modules/secrets-manager-private-cert/ibm | 1.3.2 |
| <a name="module_vpc_file_share_alb"></a> [vpc\_file\_share\_alb](#module\_vpc\_file\_share\_alb) | ./submodules/fileshare-alb | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_is_vpc_address_prefix.vpn_address_prefix](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpc_address_prefix) | resource |
| [ibm_is_vpc_routing_table.transit](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpc_routing_table) | resource |
| [ibm_resource_instance.monitoring_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_instance.secrets_manager](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_vault_password"></a> [ansible\_vault\_password](#input\_ansible\_vault\_password) | Vault password to encrypt ansible playbooks that contain sensitive information. Required when SCC workload Protection is enabled. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]\_{\|}~. | `string` | `null` | no |
| <a name="input_certificate_template_name"></a> [certificate\_template\_name](#input\_certificate\_template\_name) | The name of the Certificate Template to create for a private\_cert secret engine. When `var.existing_sm_instance_guid` is not null, then it has to be the existing template name that exists in the private cert engine. | `string` | `"my-template"` | no |
| <a name="input_client_to_site_vpn"></a> [client\_to\_site\_vpn](#input\_client\_to\_site\_vpn) | VPN configuration - the client ip pool and list of users email ids to access the environment. If enabled, then a Secret Manager instance is also provisioned with certificates generated. See optional parameters to reuse existing certificate from secrets manager instance. | <pre>object({<br/>    enable                        = bool<br/>    client_ip_pool                = string<br/>    vpn_client_access_group_users = list(string)<br/>  })</pre> | <pre>{<br/>  "client_ip_pool": "192.168.0.0/16",<br/>  "enable": true,<br/>  "vpn_client_access_group_users": []<br/>}</pre> | no |
| <a name="input_configure_dns_forwarder"></a> [configure\_dns\_forwarder](#input\_configure\_dns\_forwarder) | Specify if DNS forwarder will be configured. This will allow you to use central DNS servers (e.g. IBM Cloud DNS servers) sitting outside of the created IBM PowerVS infrastructure. If yes, ensure 'dns\_forwarder\_config' optional variable is set properly. DNS forwarder will be installed on the network-services vsi. | `bool` | `false` | no |
| <a name="input_configure_nfs_server"></a> [configure\_nfs\_server](#input\_configure\_nfs\_server) | Specify if NFS server will be configured. This will allow you easily to share files between PowerVS instances (e.g., SAP installation files). [File storage share and mount target](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create&interface=ui) in VPC will be created.. If yes, ensure 'nfs\_server\_config' optional variable is set properly below. Default value is '200GB' which will be mounted on specified directory in network-service vsi. | `bool` | `false` | no |
| <a name="input_configure_ntp_forwarder"></a> [configure\_ntp\_forwarder](#input\_configure\_ntp\_forwarder) | Specify if NTP forwarder will be configured. This will allow you to synchronize time between IBM PowerVS instances. NTP forwarder will be installed on the network-services vsi. | `bool` | `false` | no |
| <a name="input_dns_forwarder_config"></a> [dns\_forwarder\_config](#input\_dns\_forwarder\_config) | Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS. | <pre>object({<br/>    dns_servers = string<br/>  })</pre> | <pre>{<br/>  "dns_servers": "161.26.0.7; 161.26.0.8; 9.9.9.9;"<br/>}</pre> | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Specify whether Monitoring will be enabled. This includes the creation of an IBM Cloud Monitoring Instance and an Intel Monitoring Instance to host the services. If you already have an existing monitoring instance then specify in optional parameter 'existing\_monitoring\_instance\_crn'. | `bool` | `true` | no |
| <a name="input_enable_scc_wp"></a> [enable\_scc\_wp](#input\_enable\_scc\_wp) | Set to true to enable SCC Workload Protection and install and configure the Sysdig agent on all VSIs and PowerVS instances in this deployment. | `bool` | `false` | no |
| <a name="input_existing_monitoring_instance_crn"></a> [existing\_monitoring\_instance\_crn](#input\_existing\_monitoring\_instance\_crn) | Existing CRN of IBM Cloud Monitoring Instance. If value is null, then an IBM Cloud Monitoring Instance will not be created but an intel VSI instance will be created if 'enable\_monitoring' is true. | `string` | `null` | no |
| <a name="input_existing_sm_instance_guid"></a> [existing\_sm\_instance\_guid](#input\_existing\_sm\_instance\_guid) | An existing Secrets Manager GUID. The existing Secret Manager instance must have private certificate engine configured. If not provided an new instance will be provisioned. | `string` | `null` | no |
| <a name="input_existing_sm_instance_region"></a> [existing\_sm\_instance\_region](#input\_existing\_sm\_instance\_region) | Required if value is passed into `var.existing_sm_instance_guid`. | `string` | `null` | no |
| <a name="input_external_access_ip"></a> [external\_access\_ip](#input\_external\_access\_ip) | Specify the source IP address or CIDR for login through SSH to the environment after deployment. Access to the environment will be allowed only from this IP address. Can be set to 'null' if you choose to use client to site vpn. | `string` | n/a | yes |
| <a name="input_network_services_vsi_profile"></a> [network\_services\_vsi\_profile](#input\_network\_services\_vsi\_profile) | Compute profile configuration of the network services vsi (cpu and memory configuration). Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui). | `string` | `"cx2-2x4"` | no |
| <a name="input_nfs_server_config"></a> [nfs\_server\_config](#input\_nfs\_server\_config) | Configuration for the NFS server. 'size' is in GB, 'iops' is maximum input/output operation performance bandwidth per second, 'mount\_path' defines the target mount point on os. Set 'configure\_nfs\_server' to false to ignore creating file storage share. | <pre>object({<br/>    size       = number<br/>    iops       = number<br/>    mount_path = string<br/>  })</pre> | <pre>{<br/>  "iops": 600,<br/>  "mount_path": "/nfs",<br/>  "size": 200<br/>}</pre> | no |
| <a name="input_powervs_backup_network"></a> [powervs\_backup\_network](#input\_powervs\_backup\_network) | Name of the IBM Cloud PowerVS backup network and CIDR to create. | <pre>object({<br/>    name = string<br/>    cidr = string<br/>  })</pre> | <pre>{<br/>  "cidr": "10.52.0.0/24",<br/>  "name": "bkp_net"<br/>}</pre> | no |
| <a name="input_powervs_custom_image_cos_configuration"></a> [powervs\_custom\_image\_cos\_configuration](#input\_powervs\_custom\_image\_cos\_configuration) | Cloud Object Storage bucket containing custom PowerVS images. bucket\_name: string, name of the COS bucket. bucket\_access: string, possible values: public, private (private requires powervs\_custom\_image\_cos\_service\_credentials). bucket\_region: string, COS bucket region | <pre>object({<br/>    bucket_name   = string<br/>    bucket_access = string<br/>    bucket_region = string<br/>  })</pre> | <pre>{<br/>  "bucket_access": "",<br/>  "bucket_name": "",<br/>  "bucket_region": ""<br/>}</pre> | no |
| <a name="input_powervs_custom_image_cos_service_credentials"></a> [powervs\_custom\_image\_cos\_service\_credentials](#input\_powervs\_custom\_image\_cos\_service\_credentials) | Service credentials for the Cloud Object Storage bucket containing the custom PowerVS images. The bucket must have HMAC credentials enabled. Click [here](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials) for a json example of a service credential. | `string` | `null` | no |
| <a name="input_powervs_custom_images"></a> [powervs\_custom\_images](#input\_powervs\_custom\_images) | Optionally import up to three custom images from Cloud Object Storage into PowerVS workspace. Requires 'powervs\_custom\_image\_cos\_configuration' to be set. image\_name: string, must be unique. Name of image inside PowerVS workspace. file\_name: string, object key of image inside COS bucket. storage\_tier: string, storage tier which image will be stored in after import. Supported values: tier0, tier1, tier3, tier5k. sap\_type: optional string, Supported values: null, Hana, Netweaver, use null for non-SAP image. | <pre>object({<br/>    powervs_custom_image1 = object({<br/>      image_name   = string<br/>      file_name    = string<br/>      storage_tier = string<br/>      sap_type     = optional(string)<br/>    }),<br/>    powervs_custom_image2 = object({<br/>      image_name   = string<br/>      file_name    = string<br/>      storage_tier = string<br/>      sap_type     = optional(string)<br/>    }),<br/>    powervs_custom_image3 = object({<br/>      image_name   = string<br/>      file_name    = string<br/>      storage_tier = string<br/>      sap_type     = optional(string)<br/>    })<br/>  })</pre> | <pre>{<br/>  "powervs_custom_image1": {<br/>    "file_name": "",<br/>    "image_name": "",<br/>    "sap_type": null,<br/>    "storage_tier": ""<br/>  },<br/>  "powervs_custom_image2": {<br/>    "file_name": "",<br/>    "image_name": "",<br/>    "sap_type": null,<br/>    "storage_tier": ""<br/>  },<br/>  "powervs_custom_image3": {<br/>    "file_name": "",<br/>    "image_name": "",<br/>    "sap_type": null,<br/>    "storage_tier": ""<br/>  }<br/>}</pre> | no |
| <a name="input_powervs_image_names"></a> [powervs\_image\_names](#input\_powervs\_image\_names) | List of Images to be imported into cloud account from catalog images. Supported values can be found [here](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-workspace/blob/main/docs/catalog_images_list.md). For custom os image import configure the optional parameter 'powervs\_custom\_images'. | `list(string)` | <pre>[<br/>  "IBMi-75-04-2984-1",<br/>  "IBMi-74-10-2984-1",<br/>  "7200-05-08",<br/>  "7300-02-02",<br/>  "SLES15-SP5-SAP",<br/>  "SLES15-SP5-SAP-NETWEAVER",<br/>  "RHEL9-SP4-SAP",<br/>  "RHEL9-SP4-SAP-NETWEAVER"<br/>]</pre> | no |
| <a name="input_powervs_management_network"></a> [powervs\_management\_network](#input\_powervs\_management\_network) | Name of the IBM Cloud PowerVS management subnet and CIDR to create. | <pre>object({<br/>    name = string<br/>    cidr = string<br/>  })</pre> | <pre>{<br/>  "cidr": "10.51.0.0/24",<br/>  "name": "mgmt_net"<br/>}</pre> | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 10 or fewer characters. | `string` | n/a | yes |
| <a name="input_sm_service_plan"></a> [sm\_service\_plan](#input\_sm\_service\_plan) | The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: `standard` and `trial`. Only used if `existing_sm_instance_guid` is set to null. | `string` | `"standard"` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) to login to Intel VSIs to configure network management services (SQUID, NTP, DNS and ansible). Should match to public SSH key referenced by 'ssh\_public\_key'. The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud PowerVS workspace | `list(string)` | `[]` | no |
| <a name="input_transit_gateway_global"></a> [transit\_gateway\_global](#input\_transit\_gateway\_global) | Connect to the networks outside the associated region. | `bool` | `false` | no |
| <a name="input_vpc_intel_images"></a> [vpc\_intel\_images](#input\_vpc\_intel\_images) | Stock OS image names for creating VPC landing zone VSI instances: RHEL (management and network services) and SLES (monitoring). | <pre>object({<br/>    rhel_image = string<br/>    sles_image = string<br/>  })</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Access host(jump/bastion) for created PowerVS infrastructure. |
| <a name="output_ansible_host_or_ip"></a> [ansible\_host\_or\_ip](#output\_ansible\_host\_or\_ip) | Central Ansible node private IP address. |
| <a name="output_dns_host_or_ip"></a> [dns\_host\_or\_ip](#output\_dns\_host\_or\_ip) | DNS forwarder host for created PowerVS infrastructure. |
| <a name="output_monitoring_instance"></a> [monitoring\_instance](#output\_monitoring\_instance) | Details of the IBM Cloud Monitoring Instance: CRN, location, guid, monitoring\_host\_ip. |
| <a name="output_network_services_config"></a> [network\_services\_config](#output\_network\_services\_config) | Complete configuration of network management services. |
| <a name="output_nfs_host_or_ip_path"></a> [nfs\_host\_or\_ip\_path](#output\_nfs\_host\_or\_ip\_path) | NFS host for created PowerVS infrastructure. |
| <a name="output_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#output\_ntp\_host\_or\_ip) | NTP host for created PowerVS infrastructure. |
| <a name="output_powervs_backup_subnet"></a> [powervs\_backup\_subnet](#output\_powervs\_backup\_subnet) | Name, ID and CIDR of backup private network in created PowerVS infrastructure. |
| <a name="output_powervs_images"></a> [powervs\_images](#output\_powervs\_images) | Object containing imported PowerVS image names and image ids. |
| <a name="output_powervs_management_subnet"></a> [powervs\_management\_subnet](#output\_powervs\_management\_subnet) | Name, ID and CIDR of management private network in created PowerVS infrastructure. |
| <a name="output_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#output\_powervs\_resource\_group\_name) | IBM Cloud resource group where PowerVS infrastructure is created. |
| <a name="output_powervs_ssh_public_key"></a> [powervs\_ssh\_public\_key](#output\_powervs\_ssh\_public\_key) | SSH public key name and value in created PowerVS infrastructure. |
| <a name="output_powervs_workspace_guid"></a> [powervs\_workspace\_guid](#output\_powervs\_workspace\_guid) | PowerVS infrastructure workspace guid. The GUID of the resource instance. |
| <a name="output_powervs_workspace_id"></a> [powervs\_workspace\_id](#output\_powervs\_workspace\_id) | PowerVS infrastructure workspace id. The unique identifier of the new resource instance. |
| <a name="output_powervs_workspace_name"></a> [powervs\_workspace\_name](#output\_powervs\_workspace\_name) | PowerVS infrastructure workspace name. |
| <a name="output_powervs_zone"></a> [powervs\_zone](#output\_powervs\_zone) | Zone where PowerVS infrastructure is created. |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | The prefix that is associated with all resources. |
| <a name="output_proxy_host_or_ip_port"></a> [proxy\_host\_or\_ip\_port](#output\_proxy\_host\_or\_ip\_port) | Proxy host:port for created PowerVS infrastructure. |
| <a name="output_resource_group_data"></a> [resource\_group\_data](#output\_resource\_group\_data) | List of resource groups data used within landing zone. |
| <a name="output_scc_wp_instance"></a> [scc\_wp\_instance](#output\_scc\_wp\_instance) | Details of the Security and Compliance Center Workload Protection Instance: guid, access key, api\_endpoint, ingestion\_endpoint. |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key) | The string value of the ssh public key used when deploying VPC. |
| <a name="output_transit_gateway_global"></a> [transit\_gateway\_global](#output\_transit\_gateway\_global) | Connect to the networks outside the associated region. |
| <a name="output_transit_gateway_id"></a> [transit\_gateway\_id](#output\_transit\_gateway\_id) | The ID of transit gateway. |
| <a name="output_transit_gateway_name"></a> [transit\_gateway\_name](#output\_transit\_gateway\_name) | The name of the transit gateway. |
| <a name="output_vpc_data"></a> [vpc\_data](#output\_vpc\_data) | List of VPC data. |
| <a name="output_vpc_names"></a> [vpc\_names](#output\_vpc\_names) | A list of the names of the VPC. |
| <a name="output_vsi_list"></a> [vsi\_list](#output\_vsi\_list) | A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP. |
| <a name="output_vsi_names"></a> [vsi\_names](#output\_vsi\_names) | A list of the vsis names provisioned within the VPCs. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
