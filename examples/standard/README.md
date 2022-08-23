<!-- BEGIN_TF_DOCS -->

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



## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.43.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_powervs_infra"></a> [powervs\_infra](#module\_powervs\_infra) | ../../ | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pvs_zone"></a> [pvs\_zone](#input\_pvs\_zone) | IBM Cloud zone for PowerVS service. Valid values: sao01,osa21,tor01,us-south,dal12,us-east,tok04,lon04,lon06,eu-de-1,eu-de-2,syd04,syd05 | `string` | n/a | yes |
| <a name="input_pvs_resource_group_name"></a> [pvs\_resource\_group\_name](#input\_pvs\_resource\_group\_name) | Existing resource group name | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix for resources to be created. | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | SSH private key value to login to servers. It will not be uploaded / stored anywhere. | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key value to store in IBM PowerVS service. This key will be used to configure SSH login to IBM Cloud PowerVS instances. | `string` | n/a | yes |
| <a name="input_reuse_cloud_connections"></a> [reuse\_cloud\_connections](#input\_reuse\_cloud\_connections) | When the value is true, cloud connections will be reused (and is already attached to Transit gateway). Otherwise, transit gateway name  in optional parameters must be specified. | `bool` | `false` | no |
| <a name="input_configure_proxy"></a> [configure\_proxy](#input\_configure\_proxy) | Specify if SQUID proxy will be configured. If yes, ensure 'proxy\_config' optional variable is set properly. Proxy is mandatory for the landscape, so set this to 'false' only if proxy already exists. | `bool` | `true` | no |
| <a name="input_configure_ntp_forwarder"></a> [configure\_ntp\_forwarder](#input\_configure\_ntp\_forwarder) | Specify if DNS forwarder will be configured. If yes, ensure 'dns\_config' optional variable is set properly. | `bool` | `true` | no |
| <a name="input_configure_nfs_server"></a> [configure\_nfs\_server](#input\_configure\_nfs\_server) | Specify if DNS forwarder will be configured. If yes, ensure 'dns\_config' optional variable is set properly. | `bool` | `true` | no |
| <a name="input_configure_dns_forwarder"></a> [configure\_dns\_forwarder](#input\_configure\_dns\_forwarder) | Specify if DNS forwarder will be configured. If yes, ensure 'dns\_config' optional variable is set properly. | `bool` | `false` | no |
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | Jump/Access server public host name or IP address. This host name/IP is used to reach the landscape. | `string` | n/a | yes |
| <a name="input_internet_services_host_or_ip"></a> [internet\_services\_host\_or\_ip](#input\_internet\_services\_host\_or\_ip) | Host name or IP address of the virtual server instance where proxy server to public internet and to IBM Cloud services will be configured. | `string` | n/a | yes |
| <a name="input_private_services_host_or_ip"></a> [private\_services\_host\_or\_ip](#input\_private\_services\_host\_or\_ip) | Default private host name or IP address of the virtual server instance where private services should be configured (DNS forwarder, NTP forwarder, NFS server). Might be empty when no services will be installed. Might be overwritten in the optional service specific configurations (in order to install services on different hosts). | `string` | `null` | no |
| <a name="input_pvs_management_network"></a> [pvs\_management\_network](#input\_pvs\_management\_network) | PowerVS Management Subnet name and cidr which will be created. | `map(any)` | <pre>{<br>  "cidr": "10.51.0.0/24",<br>  "name": "mgmt_net"<br>}</pre> | no |
| <a name="input_pvs_backup_network"></a> [pvs\_backup\_network](#input\_pvs\_backup\_network) | PowerVS Backup Network name and cidr which will be created. | `map(any)` | <pre>{<br>  "cidr": "10.52.0.0/24",<br>  "name": "bkp_net"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tag names for PowerVS service | `list(string)` | `null` | no |
| <a name="input_transit_gateway_name"></a> [transit\_gateway\_name](#input\_transit\_gateway\_name) | Name of the existing transit gateway. Required when creating new cloud connections | `string` | `null` | no |
| <a name="input_cloud_connection_speed"></a> [cloud\_connection\_speed](#input\_cloud\_connection\_speed) | Speed in megabits per sec. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when creating new connection | `string` | `"5000"` | no |
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Required number of Cloud connections which will be created. Ignore when Transit gateway is empty. Maximum is 2 per location | `string` | `2` | no |
| <a name="input_cloud_connection_gr"></a> [cloud\_connection\_gr](#input\_cloud\_connection\_gr) | Enable global routing for this cloud connection. Can be specified when creating new connection | `bool` | `true` | no |
| <a name="input_cloud_connection_metered"></a> [cloud\_connection\_metered](#input\_cloud\_connection\_metered) | Enable metered for this cloud connection. Can be specified when creating new connection | `bool` | `false` | no |
| <a name="input_squid_proxy_config"></a> [squid\_proxy\_config](#input\_squid\_proxy\_config) | Configure SQUID proxy to use with IBM Cloud PowerVS instances. | `map(any)` | <pre>{<br>  "squid_proxy_host_or_ip": null<br>}</pre> | no |
| <a name="input_dns_forwarder_config"></a> [dns\_forwarder\_config](#input\_dns\_forwarder\_config) | Configure DNS forwarder to existing DNS service that is not reachable directly from PowerVS. | `map(any)` | <pre>{<br>  "dns_forwarder_host_or_ip": null,<br>  "dns_servers": "161.26.0.7; 161.26.0.8; 9.9.9.9;"<br>}</pre> | no |
| <a name="input_ntp_forwarder_config"></a> [ntp\_forwarder\_config](#input\_ntp\_forwarder\_config) | Configure NTP forwarder to existing NTP service that is not reachable directly from PowerVS. | `map(any)` | <pre>{<br>  "ntp_forwarder_host_or_ip": null<br>}</pre> | no |
| <a name="input_nfs_server_config"></a> [nfs\_server\_config](#input\_nfs\_server\_config) | Configure shared NFS file system (e.g., for installation media). | `map(any)` | <pre>{<br>  "nfs_directory": "/nfs",<br>  "nfs_server_host_or_ip": null<br>}</pre> | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud Api Key | `string` | `null` | no |
| <a name="input_ibm_pvs_zone_region_map"></a> [ibm\_pvs\_zone\_region\_map](#input\_ibm\_pvs\_zone\_region\_map) | Map of IBM Power VS zone to the region of PowerVS Infrastructure | `map(any)` | <pre>{<br>  "dal12": "us-south",<br>  "eu-de-1": "eu-de",<br>  "eu-de-2": "eu-de",<br>  "lon04": "lon",<br>  "lon06": "lon",<br>  "mon01": "mon",<br>  "osa21": "osa",<br>  "sao01": "sao",<br>  "syd04": "syd",<br>  "syd05": "syd",<br>  "tok04": "tok",<br>  "tor01": "tor",<br>  "us-east": "us-east",<br>  "us-south": "us-south"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_entered_data_non_sensitive"></a> [entered\_data\_non\_sensitive](#output\_entered\_data\_non\_sensitive) | User input (non sensitive) |

## Resources

No resources.


## Usage

terraform apply -var-file="input.tfvars"

## Note

For all optional fields, default values (Eg: `null`) are given in variable.tf file. User can configure the same by overwriting with appropriate values.
<!-- END_TF_DOCS -->
