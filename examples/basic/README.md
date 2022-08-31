# Basic PowerVS Infrastructure Module Example

This example illustrates how to use the `power-infrastructure` module.
It provisions the following infrastructure:
- Creates a [PowerVS service instance](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-getting-started) with 2 private networks (management network and backup network) <br/>
- Creates a ssh key

:warning: For experimentation purposes only.
For ease of use, this quick start example generates a private/public ssh key pair. The private key generated in this example will be stored unencrypted in your Terraform state file.
Use of this resource for production deployments is not recommended. Instead, generate a ssh key pair outside of Terraform and pass the public key via the [ssh_public_key input](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/v0.1#input_ssh_public_key)



<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.43.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_existing_resource_group"></a> [existing\_resource\_group](#module\_existing\_resource\_group) | git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git | v1.0.0 |
| <a name="module_powervs_infra"></a> [powervs\_infra](#module\_powervs\_infra) | ../../ | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [ibm_is_ssh_key.ssh_key](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_ssh_key) | resource |
| [tls_private_key.tls_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.1/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Required number of Cloud connections to create or reuse. The maximum number of connections is two per location. | `number` | `0` | no |
| <a name="input_cloud_connection_gr"></a> [cloud\_connection\_gr](#input\_cloud\_connection\_gr) | Whether to enable global routing for this IBM Cloud connection. You can specify thia value when you create a connection. | `bool` | `true` | no |
| <a name="input_cloud_connection_metered"></a> [cloud\_connection\_metered](#input\_cloud\_connection\_metered) | Whether to enable metering for this IBM Cloud connection. You can specify thia value when you create a connection. | `bool` | `false` | no |
| <a name="input_cloud_connection_speed"></a> [cloud\_connection\_speed](#input\_cloud\_connection\_speed) | Speed in megabits per second. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when you create a connection. | `number` | `5000` | no |
| <a name="input_dns_forwarder_config"></a> [dns\_forwarder\_config](#input\_dns\_forwarder\_config) | Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS | <pre>object({<br>    dns_enable        = bool<br>    server_host_or_ip = string<br>    dns_servers       = string<br>  })</pre> | <pre>{<br>  "dns_enable": "false",<br>  "dns_servers": "161.26.0.7; 161.26.0.8; 9.9.9.9;",<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | Existing resource group name to use for this example. If null, a new resource group will be created. | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud Api Key | `string` | n/a | yes |
| <a name="input_nfs_config"></a> [nfs\_config](#input\_nfs\_config) | Configuration for the shared NFS file system (for example, for the installation media). | <pre>object({<br>    nfs_enable        = bool<br>    server_host_or_ip = string<br>    nfs_directory     = string<br>  })</pre> | <pre>{<br>  "nfs_directory": "/nfs",<br>  "nfs_enable": "false",<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_ntp_forwarder_config"></a> [ntp\_forwarder\_config](#input\_ntp\_forwarder\_config) | Configuration for the NTP forwarder to an NTP service that is not reachable directly from PowerVS | <pre>object({<br>    ntp_enable        = bool<br>    server_host_or_ip = string<br>  })</pre> | <pre>{<br>  "ntp_enable": "false",<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_perform_proxy_client_setup"></a> [perform\_proxy\_client\_setup](#input\_perform\_proxy\_client\_setup) | Proxy configuration to allow internet access for a VM or LPAR. | <pre>object(<br>    {<br>      squid_client_ips = list(string)<br>      squid_server_ip  = string<br>      no_proxy_env     = string<br>    }<br>  )</pre> | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resources which will be created. | `string` | `"pvs"` | no |
| <a name="input_pvs_backup_network"></a> [pvs\_backup\_network](#input\_pvs\_backup\_network) | Name of the IBM Cloud PowerVS backup network and CIDR to create | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.52.0.0/24",<br>  "name": "bkp_net"<br>}</pre> | no |
| <a name="input_pvs_image_names"></a> [pvs\_image\_names](#input\_pvs\_image\_names) | List of Images to be imported into cloud account from catalog images | `list(string)` | <pre>[<br>  "SLES15-SP3-SAP",<br>  "SLES15-SP3-SAP-NETWEAVER",<br>  "RHEL8-SP4-SAP",<br>  "RHEL8-SP4-SAP-NETWEAVER"<br>]</pre> | no |
| <a name="input_pvs_management_network"></a> [pvs\_management\_network](#input\_pvs\_management\_network) | Name of the IBM Cloud PowerVS management subnet and CIDR to create | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.51.0.0/24",<br>  "name": "mgmt_net"<br>}</pre> | no |
| <a name="input_pvs_service_name"></a> [pvs\_service\_name](#input\_pvs\_service\_name) | Name of the PowerVS service to create | `string` | `"power-service"` | no |
| <a name="input_pvs_sshkey_name"></a> [pvs\_sshkey\_name](#input\_pvs\_sshkey\_name) | Name of the PowerVS SSH key to create | `string` | `"ssh-key-pvs"` | no |
| <a name="input_pvs_zone"></a> [pvs\_zone](#input\_pvs\_zone) | IBM Cloud PowerVS Zone. Valid values: IBM Cloud PVS Zone. Valid values: syd04,syd05,eu-de-1,eu-de-2,lon04,lon06,wdc04,us-east,us-south,dal12,dal13,tor01,tok04,osa21,sao01,mon01 | `string` | `"syd04"` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional List of tag names for the IBM Cloud PowerVS service | `list(string)` | `[]` | no |
| <a name="input_reuse_cloud_connections"></a> [reuse\_cloud\_connections](#input\_reuse\_cloud\_connections) | When true, IBM Cloud connections are reused (if attached to the transit gateway). | `bool` | `true` | no |
| <a name="input_squid_config"></a> [squid\_config](#input\_squid\_config) | Configuration for the Squid proxy to a DNS service that is not reachable directly from PowerVS | <pre>object({<br>    squid_enable      = bool<br>    server_host_or_ip = string<br>  })</pre> | <pre>{<br>  "server_host_or_ip": "",<br>  "squid_enable": "false"<br>}</pre> | no |
| <a name="input_transit_gateway_name"></a> [transit\_gateway\_name](#input\_transit\_gateway\_name) | Name of the existing transit gateway. Required when you create new IBM Cloud connections. | `string` | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Note

For all optional fields, default values (Eg: `null`) are given in variable.tf file. User can configure the same by overwriting with appropriate values.
