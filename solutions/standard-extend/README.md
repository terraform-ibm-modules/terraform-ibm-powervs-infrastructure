# IBM Cloud Catalog Solution for Power Virtual Server with VPC Landing Zone Extend Standard Landscape Variation

This example extends an existing PowerVS infrastructure for deployable architectures deployed as Standard Landscape Variation with an additional PowerVS workspace.
It provisions the following infrastructure on top of the deployed Full Stack solution:

- A **Power Virtual Server workspace** with the following network topology:
    - Creates two private networks: a management network and a backup network
    - Attaches the PowerVS workspace to transit gateway
    - Creates an SSH key.
    - Optionally imports up to three custom images from Cloud Object Storage.

### Notes:
- Make sure that you select a PowerVS zone that is different from the one used for the prerequisite infrastructure.
- This solution requires a schematics workspace ID as input.
- The catalog image names to be imported into the infrastructure can be found [here](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-workspace/blob/main/docs/catalog_images_list.md)

### Before You Begin

If you do not have a PowerVS infrastructure that is the [Standard Landscape Variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/standard) create it first.


| Variation  | Available on IBM Catalog  |  Requires Schematics Workspace ID | Creates VPC Landing Zone | Performs VPC VSI OS Config | Creates PowerVS Infrastructure | Creates PowerVS Instance | Performs PowerVS OS Config |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [Extend Standard Landscape](./)    | :heavy_check_mark:  |  :heavy_check_mark: |  N/A | N/A | :heavy_check_mark:  | N/A | N/A |


## Reference architecture
[Extend Standard Landscape Variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/standard-extend/deploy-arch-ibm-pvs-inf-standard-extend.md)

## Architecture diagram
![Extend Standard Landscape](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/standard-extend/deploy-arch-ibm-pvs-inf-standard-extend.svg)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.81.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_powervs_workspace"></a> [powervs\_workspace](#module\_powervs\_workspace) | terraform-ibm-modules/powervs-workspace/ibm | 3.2.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_schematics_output.schematics_output](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.81.0/docs/data-sources/schematics_output) | data source |
| [ibm_schematics_workspace.schematics_workspace](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.81.0/docs/data-sources/schematics_workspace) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_IC_SCHEMATICS_WORKSPACE_ID"></a> [IC\_SCHEMATICS\_WORKSPACE\_ID](#input\_IC\_SCHEMATICS\_WORKSPACE\_ID) | leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace | `string` | `""` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_powervs_backup_network"></a> [powervs\_backup\_network](#input\_powervs\_backup\_network) | Name of the IBM Cloud PowerVS backup network and CIDR to create. | <pre>object({<br/>    name = string<br/>    cidr = string<br/>  })</pre> | <pre>{<br/>  "cidr": "10.62.0.0/24",<br/>  "name": "bkp_net"<br/>}</pre> | no |
| <a name="input_powervs_custom_image_cos_configuration"></a> [powervs\_custom\_image\_cos\_configuration](#input\_powervs\_custom\_image\_cos\_configuration) | Cloud Object Storage bucket containing custom PowerVS images. bucket\_name: string, name of the COS bucket. bucket\_access: string, possible values: public, private (private requires powervs\_custom\_image\_cos\_service\_credentials). bucket\_region: string, COS bucket region | <pre>object({<br/>    bucket_name   = string<br/>    bucket_access = string<br/>    bucket_region = string<br/>  })</pre> | <pre>{<br/>  "bucket_access": "",<br/>  "bucket_name": "",<br/>  "bucket_region": ""<br/>}</pre> | no |
| <a name="input_powervs_custom_image_cos_service_credentials"></a> [powervs\_custom\_image\_cos\_service\_credentials](#input\_powervs\_custom\_image\_cos\_service\_credentials) | Service credentials for the Cloud Object Storage bucket containing the custom PowerVS images. The bucket must have HMAC credentials enabled. Click [here](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials) for a json example of a service credential. | `string` | `null` | no |
| <a name="input_powervs_custom_images"></a> [powervs\_custom\_images](#input\_powervs\_custom\_images) | Optionally import up to three custom images from Cloud Object Storage into PowerVS workspace. Requires 'powervs\_custom\_image\_cos\_configuration' to be set. image\_name: string, must be unique. Name of image inside PowerVS workspace. file\_name: string, object key of image inside COS bucket. storage\_tier: string, storage tier which image will be stored in after import. Supported values: tier0, tier1, tier3, tier5k. sap\_type: optional string, Supported values: null, Hana, Netweaver, use null for non-SAP image. | <pre>object({<br/>    powervs_custom_image1 = object({<br/>      image_name   = string<br/>      file_name    = string<br/>      storage_tier = string<br/>      sap_type     = optional(string)<br/>    }),<br/>    powervs_custom_image2 = object({<br/>      image_name   = string<br/>      file_name    = string<br/>      storage_tier = string<br/>      sap_type     = optional(string)<br/>    }),<br/>    powervs_custom_image3 = object({<br/>      image_name   = string<br/>      file_name    = string<br/>      storage_tier = string<br/>      sap_type     = optional(string)<br/>    })<br/>  })</pre> | <pre>{<br/>  "powervs_custom_image1": {<br/>    "file_name": "",<br/>    "image_name": "",<br/>    "sap_type": null,<br/>    "storage_tier": ""<br/>  },<br/>  "powervs_custom_image2": {<br/>    "file_name": "",<br/>    "image_name": "",<br/>    "sap_type": null,<br/>    "storage_tier": ""<br/>  },<br/>  "powervs_custom_image3": {<br/>    "file_name": "",<br/>    "image_name": "",<br/>    "sap_type": null,<br/>    "storage_tier": ""<br/>  }<br/>}</pre> | no |
| <a name="input_powervs_management_network"></a> [powervs\_management\_network](#input\_powervs\_management\_network) | Name of the IBM Cloud PowerVS management subnet and CIDR to create. | <pre>object({<br/>    name = string<br/>    cidr = string<br/>  })</pre> | <pre>{<br/>  "cidr": "10.61.0.0/24",<br/>  "name": "mgmt_net"<br/>}</pre> | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. | `string` | n/a | yes |
| <a name="input_prerequisite_workspace_id"></a> [prerequisite\_workspace\_id](#input\_prerequisite\_workspace\_id) | IBM Cloud Schematics workspace ID of the prerequisite infrastructure. If you do not have an existing deployment yet, create a new architecture using the same catalog tile. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud PowerVS workspace | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Access host for created PowerVS infrastructure. |
| <a name="output_ansible_host_or_ip"></a> [ansible\_host\_or\_ip](#output\_ansible\_host\_or\_ip) | Central Ansible node private IP address. |
| <a name="output_dns_host_or_ip"></a> [dns\_host\_or\_ip](#output\_dns\_host\_or\_ip) | DNS forwarder host for created PowerVS infrastructure. |
| <a name="output_kms_key_map"></a> [kms\_key\_map](#output\_kms\_key\_map) | Map of ids and keys for KMS keys created |
| <a name="output_monitoring_instance"></a> [monitoring\_instance](#output\_monitoring\_instance) | Details of the IBM Cloud Monitoring Instance: CRN, location, guid. |
| <a name="output_network_load_balancer"></a> [network\_load\_balancer](#output\_network\_load\_balancer) | Details of network load balancer. |
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
| <a name="output_scc_wp_instance"></a> [scc\_wp\_instance](#output\_scc\_wp\_instance) | Details of the Security and Compliance Center Workload Protection Instance: guid, access key, api\_endpoint, ingestion\_endpoint. |
| <a name="output_schematics_workspace_id"></a> [schematics\_workspace\_id](#output\_schematics\_workspace\_id) | ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key) | The string value of the ssh public key used when deploying VPC |
| <a name="output_transit_gateway_id"></a> [transit\_gateway\_id](#output\_transit\_gateway\_id) | The ID of transit gateway. |
| <a name="output_transit_gateway_name"></a> [transit\_gateway\_name](#output\_transit\_gateway\_name) | The name of the transit gateway. |
| <a name="output_vpc_data"></a> [vpc\_data](#output\_vpc\_data) | List of VPC data. |
| <a name="output_vpc_names"></a> [vpc\_names](#output\_vpc\_names) | A list of the names of the VPC. |
| <a name="output_vsi_list"></a> [vsi\_list](#output\_vsi\_list) | A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP. |
| <a name="output_vsi_names"></a> [vsi\_names](#output\_vsi\_names) | A list of the vsis names provisioned within the VPCs. |
| <a name="output_vsi_ssh_key_data"></a> [vsi\_ssh\_key\_data](#output\_vsi\_ssh\_key\_data) | List of VSI SSH key data |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
