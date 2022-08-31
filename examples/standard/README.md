# Standard PowerVS Infrastructure Module Example

This example illustrates how to use the `power-infrastructure` module.
It provisions the following infrastructure
- Creates a [PowerVS service instance](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-getting-started) with the following network topology <br/>
(1) 2 private networks, management network and backup network <br/>
(2) 1 or 2 [IBM Cloud connection](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-cloud-connections), with the option to reuse existing IBM Cloud connections.
If reusing cloud connections make sure cloud connection is already attached to transit gateway <br/>
(3) Attaches the IBM Cloud connections to a [transit gateway](https://cloud.ibm.com/docs/transit-gateway?topic=transit-gateway-getting-started) <br/>
(4) Attaches the PowerVS service instance private networks to the IBM Cloud connections <br/>
- Creates a ssh key
- Option to Install and Configure Squid proxy, NFS, NTP forwarder, DNS forwarder on specified hosts.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.2 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.44.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_powervs_infra"></a> [powervs\_infra](#module\_powervs\_infra) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | The public IP address for the jump or Bastion server. The address is used to reach the target or server\_host IP address and to configure the DNS, NTP, NFS, and Squid proxy services. | `string` | n/a | yes |
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Required number of Cloud connections to create or reuse. The maximum number of connections is two per location. | `number` | `2` | no |
| <a name="input_cloud_connection_gr"></a> [cloud\_connection\_gr](#input\_cloud\_connection\_gr) | Whether to enable global routing for this IBM Cloud connection. You can specify thia value when you create a connection. | `bool` | `true` | no |
| <a name="input_cloud_connection_metered"></a> [cloud\_connection\_metered](#input\_cloud\_connection\_metered) | Whether to enable metering for this IBM Cloud connection. You can specify thia value when you create a connection. | `bool` | `false` | no |
| <a name="input_cloud_connection_speed"></a> [cloud\_connection\_speed](#input\_cloud\_connection\_speed) | Speed in megabits per second. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when you create a connection. | `number` | `5000` | no |
| <a name="input_configure_dns_forwarder"></a> [configure\_dns\_forwarder](#input\_configure\_dns\_forwarder) | Specify if DNS forwarder will be configured. If yes, ensure 'dns\_forwarder\_config' optional variable is set properly. | `bool` | `true` | no |
| <a name="input_configure_nfs_server"></a> [configure\_nfs\_server](#input\_configure\_nfs\_server) | Specify if NFS will be configured. If yes, ensure 'nfs\_config' optional variable is set properly. | `bool` | `true` | no |
| <a name="input_configure_ntp_forwarder"></a> [configure\_ntp\_forwarder](#input\_configure\_ntp\_forwarder) | Specify if NTP forwarder will be configured. If yes, ensure 'ntp\_forwarder\_config' optional variable is set properly. | `bool` | `true` | no |
| <a name="input_configure_proxy"></a> [configure\_proxy](#input\_configure\_proxy) | Specify if SQUID proxy will be configured. Proxy is mandatory for the landscape, so set this to 'false' only if proxy already exists. | `bool` | `true` | no |
| <a name="input_dns_forwarder_config"></a> [dns\_forwarder\_config](#input\_dns\_forwarder\_config) | Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS | <pre>object({<br>    server_host_or_ip = string<br>    dns_servers       = string<br>  })</pre> | <pre>{<br>  "dns_servers": "161.26.0.7; 161.26.0.8; 9.9.9.9;",<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud Api Key | `string` | `null` | no |
| <a name="input_internet_services_host_or_ip"></a> [internet\_services\_host\_or\_ip](#input\_internet\_services\_host\_or\_ip) | Host name or IP address of the virtual server instance where proxy server to public internet and to IBM Cloud services will be configured. | `string` | `null` | no |
| <a name="input_nfs_config"></a> [nfs\_config](#input\_nfs\_config) | Configuration for the shared NFS file system (for example, for the installation media). | <pre>object({<br>    server_host_or_ip = string<br>    nfs_directory     = string<br>  })</pre> | <pre>{<br>  "nfs_directory": "/nfs",<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_ntp_forwarder_config"></a> [ntp\_forwarder\_config](#input\_ntp\_forwarder\_config) | Configuration for the NTP forwarder to an NTP service that is not reachable directly from PowerVS | <pre>object({<br>    server_host_or_ip = string<br>  })</pre> | <pre>{<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix for resources to be created. | `string` | n/a | yes |
| <a name="input_private_services_host_or_ip"></a> [private\_services\_host\_or\_ip](#input\_private\_services\_host\_or\_ip) | Default private host name or IP address of the virtual server instance where private services should be configured (DNS forwarder, NTP forwarder, NFS server). Might be empty when no services will be installed. Might be overwritten in the optional service specific configurations (in order to install services on different hosts). | `string` | `null` | no |
| <a name="input_pvs_backup_network"></a> [pvs\_backup\_network](#input\_pvs\_backup\_network) | Name of the IBM Cloud PowerVS backup network and CIDR to create | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.52.0.0/24",<br>  "name": "bkp_net"<br>}</pre> | no |
| <a name="input_pvs_image_names"></a> [pvs\_image\_names](#input\_pvs\_image\_names) | List of Images to be imported into cloud account from catalog images | `list(string)` | <pre>[<br>  "SLES15-SP3-SAP",<br>  "SLES15-SP3-SAP-NETWEAVER",<br>  "RHEL8-SP4-SAP",<br>  "RHEL8-SP4-SAP-NETWEAVER"<br>]</pre> | no |
| <a name="input_pvs_management_network"></a> [pvs\_management\_network](#input\_pvs\_management\_network) | Name of the IBM Cloud PowerVS management subnet and CIDR to create | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.51.0.0/24",<br>  "name": "mgmt_net"<br>}</pre> | no |
| <a name="input_pvs_resource_group_name"></a> [pvs\_resource\_group\_name](#input\_pvs\_resource\_group\_name) | Existing resource group name | `string` | n/a | yes |
| <a name="input_pvs_zone"></a> [pvs\_zone](#input\_pvs\_zone) | IBM Cloud zone for PowerVS service. Valid values: IBM Cloud PVS Zone. Valid values: syd04,syd05,eu-de-1,eu-de-2,lon04,lon06,wdc04,us-east,us-south,dal12,dal13,tor01,tok04,osa21,sao01,mon01 | `string` | n/a | yes |
| <a name="input_reuse_cloud_connections"></a> [reuse\_cloud\_connections](#input\_reuse\_cloud\_connections) | When true, IBM Cloud connections are reused (if attached to the transit gateway). | `bool` | `false` | no |
| <a name="input_squid_config"></a> [squid\_config](#input\_squid\_config) | Configuration for the Squid proxy setup | <pre>object({<br>    server_host_or_ip = string<br>  })</pre> | <pre>{<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | SSH private key value to login to servers. It will not be uploaded / stored anywhere. | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for the PowerVM to create | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tag names for PowerVS service | `list(string)` | `null` | no |
| <a name="input_transit_gateway_name"></a> [transit\_gateway\_name](#input\_transit\_gateway\_name) | Name of the existing transit gateway. Required when creating new cloud connections | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_entered_data_non_sensitive"></a> [entered\_data\_non\_sensitive](#output\_entered\_data\_non\_sensitive) | User input (non sensitive) |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Usage

terraform apply -var-file="input.tfvars"

## Note

For all optional fields, default values (Eg: `null`) are given in variable.tf file. User can configure the same by overwriting with appropriate values.
