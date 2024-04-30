# Module powervs-vpc-landing-zone

## IBM Power Virtual Server with VPC Landing Zone

This module provisions the following resources in IBM Cloud:
- A **VPC Infrastructure** based on the value passed to 'var.landing_zone_configuration' with the following components:
    -  **landing_zone_configuration = 3VPC_RHEL or 3VPC_SLES**

        - Provisions three VPCs with one VSI in each VPC - one management (jump/bastion) VSI, one inet-svs VSI configured as a squid proxy server, and one private-svs VSI (configured as NFS, NTP, DNS server) using [this preset](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/modules/powervs-vpc-landing-zone/presets/3vpc.preset.json.tftpl).
        - Installs and configures the Squid Proxy, DNS Forwarder, NTP forwarder, and NFS on hosts, and sets the host as the server for the NTP, NFS, and DNS services by using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/).

    -  **landing_zone_configuration = 1VPC_RHEL**

        - One VPC with one VSI for management (jump/bastion) using [this preset](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/modules/powervs-vpc-landing-zone/presets/1vpc.preset.json.tftpl).
        - Installation and configuration of Squid Proxy, DNS Forwarder, NTP forwarder, and NFS on the bastion host, and sets the host as the server for the NTP, NFS, and DNS services using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/)

- **A Power Virtual Server workspace**  with the following network topology:
    - Creates two private networks: a management network and a backup network.
    - Creates one or two IBM Cloud connections in a non-PER environment.
    - Attaches the private networks to the IBM Cloud connections in a non-PER environment.
    - Attaches the IBM Cloud connections to a transit gateway in a non-PER environment.
    - Attaches the PowerVS workspace to Transit gateway in PER-enabled DC.
    - Creates an SSH key.

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

module "fullstack" {
  source  = "terraform-ibm-modules/powervs-infrastructure/ibm//modules//powervs-vpc-landing-zone"
  version = "x.x.x" # Replace "x.x.x" with a git release version to lock into a specific release

  providers = { ibm.ibm-is = ibm.ibm-is, ibm.ibm-pi = ibm.ibm-pi }

  powervs_zone                = var.powervs_zone
  landing_zone_configuration  = var.landing_zone_configuration
  prefix                      = var.prefix
  external_access_ip          = var.external_access_ip
  ssh_public_key              = var.ssh_public_key
  ssh_private_key             = var.ssh_private_key
  configure_dns_forwarder     = var.configure_dns_forwarder      #(optional,  default false)
  configure_ntp_forwarder     = var.configure_ntp_forwarder      #(optional,  default false)
  configure_nfs_server        = var.configure_nfs_server         #(optional.  default false)
  nfs_server_config           = var.nfs_server_config            #(optional.  default check vars)
  dns_forwarder_config        = var.dns_forwarder_config         #(optional.  default check vars)
  powervs_resource_group_name = var.powervs_resource_group_name  #(optional.  default check vars)
  powervs_management_network  = var.powervs_management_network   #(optional.  default check vars)
  powervs_backup_network      = var.powervs_backup_network       #(optional.  default check vars)
  cloud_connection            = var.cloud_connection             #(optional.  default check vars)
  powervs_image_names         = var.powervs_image_names          #(optional.  default check vars)
  tags                        = var.tags                         #(optional.  default check vars)
}
```

### Notes:
Catalog image names to be imported into infrastructure can be found [here](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/solutions/full-stack/docs/catalog_image_names.md)

Creates VPC Landing Zone | Performs VPC VSI OS Config | Creates PowerVS Infrastructure | Creates PowerVS Instance | Performs PowerVS OS Config |
|  ------------- | ------------- | ------------- | ------------- | ------------- |
| :heavy_check_mark:  | :heavy_check_mark:  |  :heavy_check_mark: | N/A | N/A |


## Supported Reference architectures
1. [PowerVS workspace full-stack variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/full-stack/deploy-arch-ibm-pvs-inf-full-stack.svg)
2. [PowerVS quickstart variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/quickstart/deploy-arch-ibm-pvs-inf-quickstart.svg)


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.62.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_landing_zone"></a> [landing\_zone](#module\_landing\_zone) | terraform-ibm-modules/landing-zone/ibm//patterns//vsi//module | 5.21.0 |
| <a name="module_landing_zone_configure_network_services"></a> [landing\_zone\_configure\_network\_services](#module\_landing\_zone\_configure\_network\_services) | ../ansible-configure-network-services | n/a |
| <a name="module_landing_zone_configure_proxy_server"></a> [landing\_zone\_configure\_proxy\_server](#module\_landing\_zone\_configure\_proxy\_server) | ../ansible-configure-network-services | n/a |
| <a name="module_powervs_infra"></a> [powervs\_infra](#module\_powervs\_infra) | terraform-ibm-modules/powervs-workspace/ibm | 1.12.0 |

### Resources

| Name | Type |
|------|------|
| [time_sleep.wait_for_squid_setup_to_complete](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_connection"></a> [cloud\_connection](#input\_cloud\_connection) | Cloud connection configuration: speed (50, 100, 200, 500, 1000, 2000, 5000, 10000 Mb/s), count (1 or 2 connections), global\_routing (true or false), metered (true or false). Not applicable for DCs where PER is enabled. | <pre>object({<br>    count          = number<br>    speed          = number<br>    global_routing = bool<br>    metered        = bool<br>  })</pre> | <pre>{<br>  "count": 2,<br>  "global_routing": true,<br>  "metered": true,<br>  "speed": 5000<br>}</pre> | no |
| <a name="input_configure_dns_forwarder"></a> [configure\_dns\_forwarder](#input\_configure\_dns\_forwarder) | Specify if DNS forwarder will be configured. This will allow you to use central DNS servers (e.g. IBM Cloud DNS servers) sitting outside of the created IBM PowerVS infrastructure. If yes, ensure 'dns\_forwarder\_config' optional variable is set properly. DNS forwarder will be installed on the private-svs-1 vsi if exists else on inet-svs-1 vsi. | `bool` | `false` | no |
| <a name="input_configure_nfs_server"></a> [configure\_nfs\_server](#input\_configure\_nfs\_server) | Specify if NFS server will be configured. This will allow you easily to share files between PowerVS instances (e.g., SAP installation files). NFS server will be installed on the private-svs vsi. If yes, ensure 'nfs\_server\_config' optional variable is set properly below. Default value is '1TB' which will be mounted on '/nfs'. | `bool` | `false` | no |
| <a name="input_configure_ntp_forwarder"></a> [configure\_ntp\_forwarder](#input\_configure\_ntp\_forwarder) | Specify if NTP forwarder will be configured. This will allow you to synchronize time between IBM PowerVS instances. NTP forwarder will be installed on the private-svs-1 vsi if exists else on inet-svs-1 vsi. | `bool` | `false` | no |
| <a name="input_dns_forwarder_config"></a> [dns\_forwarder\_config](#input\_dns\_forwarder\_config) | Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS. | <pre>object({<br>    dns_servers = string<br>  })</pre> | <pre>{<br>  "dns_servers": "161.26.0.7; 161.26.0.8; 9.9.9.9;"<br>}</pre> | no |
| <a name="input_external_access_ip"></a> [external\_access\_ip](#input\_external\_access\_ip) | Specify the source IP address or CIDR for login through SSH to the environment after deployment. Access to the environment will be allowed only from this IP address. | `string` | n/a | yes |
| <a name="input_landing_zone_configuration"></a> [landing\_zone\_configuration](#input\_landing\_zone\_configuration) | VPC landing zone configuration. Provided value must be one of ['3VPC\_RHEL', '3VPC\_SLES', '1VPC\_RHEL'] only. | `string` | n/a | yes |
| <a name="input_nfs_server_config"></a> [nfs\_server\_config](#input\_nfs\_server\_config) | Configuration for the NFS server. 'size' is in GB, 'mount\_path' defines the mount point on os. Set 'configure\_nfs\_server' to false to ignore creating volume. | <pre>object({<br>    size       = number<br>    mount_path = string<br>  })</pre> | <pre>{<br>  "mount_path": "/nfs",<br>  "size": 1000<br>}</pre> | no |
| <a name="input_powervs_backup_network"></a> [powervs\_backup\_network](#input\_powervs\_backup\_network) | Name of the IBM Cloud PowerVS backup network and CIDR to create. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.52.0.0/24",<br>  "name": "bkp_net"<br>}</pre> | no |
| <a name="input_powervs_image_names"></a> [powervs\_image\_names](#input\_powervs\_image\_names) | List of Images to be imported into cloud account from catalog images. Supported values can be found [here](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/solutions/full-stack/docs/catalog_image_names.md) | `list(string)` | <pre>[<br>  "IBMi-75-03-2924-1",<br>  "IBMi-74-09-2984-1",<br>  "7300-00-01",<br>  "7200-05-07",<br>  "SLES15-SP4-SAP",<br>  "SLES15-SP4-SAP-NETWEAVER",<br>  "RHEL8-SP6-SAP",<br>  "RHEL8-SP6-SAP-NETWEAVER"<br>]</pre> | no |
| <a name="input_powervs_management_network"></a> [powervs\_management\_network](#input\_powervs\_management\_network) | Name of the IBM Cloud PowerVS management subnet and CIDR to create. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.51.0.0/24",<br>  "name": "mgmt_net"<br>}</pre> | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters. | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to public SSH key referenced by 'ssh\_public\_key'. Entered data must be in [heredoc strings format](https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud PowerVS workspace | `list(string)` | `[]` | no |

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
| <a name="output_powervs_workspace_id"></a> [powervs\_workspace\_id](#output\_powervs\_workspace\_id) | PowerVS infrastructure workspace id. The unique identifier of the new resource instance. |
| <a name="output_powervs_workspace_name"></a> [powervs\_workspace\_name](#output\_powervs\_workspace\_name) | PowerVS infrastructure workspace name. |
| <a name="output_powervs_zone"></a> [powervs\_zone](#output\_powervs\_zone) | Zone where PowerVS infrastructure is created. |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | The prefix that is associated with all resources |
| <a name="output_proxy_host_or_ip_port"></a> [proxy\_host\_or\_ip\_port](#output\_proxy\_host\_or\_ip\_port) | Proxy host:port for created PowerVS infrastructure. |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key) | The string value of the ssh public key used when deploying VPC |
| <a name="output_transit_gateway_id"></a> [transit\_gateway\_id](#output\_transit\_gateway\_id) | The ID of transit gateway. |
| <a name="output_transit_gateway_name"></a> [transit\_gateway\_name](#output\_transit\_gateway\_name) | The name of the transit gateway. |
| <a name="output_vpc_names"></a> [vpc\_names](#output\_vpc\_names) | A list of the names of the VPC. |
| <a name="output_vsi_list"></a> [vsi\_list](#output\_vsi\_list) | A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP. |
| <a name="output_vsi_names"></a> [vsi\_names](#output\_vsi\_names) | A list of the vsis names provisioned within the VPCs. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
