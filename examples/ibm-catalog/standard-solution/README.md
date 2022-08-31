# Catalog PowerVS Infrastructure Module Example

This example illustrates how to use the `power-infrastructure` module.
It provisions the following infrastructure
- Creates a [PowerVS service instance](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-getting-started) with the following network topology <br/>
(1) 2 private networks, management network and backup network <br/>
(2) 1 or 2 [IBM Cloud connection](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-cloud-connections), with the option to reuse existing IBM Cloud connections <br/>
(3) The IBM Cloud connections are attached to a [transit gateway](https://cloud.ibm.com/docs/transit-gateway?topic=transit-gateway-getting-started) <br/>
(4) Attaches the PowerVS service instance private networks to the IBM Cloud connections <br/>
- Creates a ssh key

:warning: For experimentation purposes only.
For ease of use, this quick start example generates a private/public ssh key pair. The private key generated in this example will be stored unencrypted in your Terraform state file.
Use of this resource for production deployments is not recommended. Instead, generate a ssh key pair outside of Terraform and pass the public key via the [ssh_public_key input](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/v0.1#input_ssh_public_key)


## Prerequisites
Make sure you installed the Power flavor of version 0.0.19 or higher of Secure Landing Zone VPC with VSIs.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.43.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_powervs_infra"></a> [powervs\_infra](#module\_powervs\_infra) | ../../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_schematics_output.schematics_output](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/schematics_output) | data source |
| [ibm_schematics_workspace.schematics_workspace](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/schematics_workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Required number of Cloud connections which will be created/Reused. Maximum is 2 per location | `number` | `2` | no |
| <a name="input_cloud_connection_gr"></a> [cloud\_connection\_gr](#input\_cloud\_connection\_gr) | Enable global routing for this cloud connection.Can be specified when creating new connection | `bool` | `true` | no |
| <a name="input_cloud_connection_metered"></a> [cloud\_connection\_metered](#input\_cloud\_connection\_metered) | Enable metered for this cloud connection. Can be specified when creating new connection | `bool` | `false` | no |
| <a name="input_cloud_connection_speed"></a> [cloud\_connection\_speed](#input\_cloud\_connection\_speed) | Speed in megabits per sec. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when creating new connection | `number` | `5000` | no |
| <a name="input_configure_dns_forwarder"></a> [configure\_dns\_forwarder](#input\_configure\_dns\_forwarder) | Specify if DNS forwarder will be configured. If yes, ensure 'dns\_config' optional variable is set properly. | `bool` | `true` | no |
| <a name="input_configure_nfs_server"></a> [configure\_nfs\_server](#input\_configure\_nfs\_server) | Specify if NFS will be configured. If yes, ensure 'nfs\_config' optional variable is set properly. | `bool` | `true` | no |
| <a name="input_configure_ntp_forwarder"></a> [configure\_ntp\_forwarder](#input\_configure\_ntp\_forwarder) | Specify if NTP forwarder will be configured. | `bool` | `true` | no |
| <a name="input_configure_proxy"></a> [configure\_proxy](#input\_configure\_proxy) | Specify if SQUID proxy will be configured. Proxy is mandatory for the landscape, so set this to 'false' only if proxy already exists. | `bool` | `true` | no |
| <a name="input_dns_config"></a> [dns\_config](#input\_dns\_config) | Configure DNS forwarder to existing DNS service that is not reachable directly from PowerVS | `map(any)` | <pre>{<br>  "dns_servers": "161.26.0.7; 161.26.0.8; 9.9.9.9;",<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud Api Key | `string` | `null` | no |
| <a name="input_nfs_config"></a> [nfs\_config](#input\_nfs\_config) | Configure shared NFS file system (e.g., for installation media). Semicolon separated values. | `map(any)` | <pre>{<br>  "nfs_directory": "/nfs",<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_ntp_config"></a> [ntp\_config](#input\_ntp\_config) | Ntp configuration on server | `map(any)` | <pre>{<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_pvs_backup_network"></a> [pvs\_backup\_network](#input\_pvs\_backup\_network) | PowerVS Backup Network name and cidr which will be created. | `map(any)` | <pre>{<br>  "cidr": "10.52.0.0/24",<br>  "name": "bkp_net"<br>}</pre> | no |
| <a name="input_pvs_image_names"></a> [pvs\_image\_names](#input\_pvs\_image\_names) | List of Images to be imported into cloud account from catalog images | `list(string)` | <pre>[<br>  "SLES15-SP3-SAP",<br>  "SLES15-SP3-SAP-NETWEAVER",<br>  "RHEL8-SP4-SAP",<br>  "RHEL8-SP4-SAP-NETWEAVER"<br>]</pre> | no |
| <a name="input_pvs_management_network"></a> [pvs\_management\_network](#input\_pvs\_management\_network) | PowerVS Management Subnet name and cidr which will be created. | `map(any)` | <pre>{<br>  "cidr": "10.51.0.0/24",<br>  "name": "mgmt_net"<br>}</pre> | no |
| <a name="input_pvs_resource_group_name"></a> [pvs\_resource\_group\_name](#input\_pvs\_resource\_group\_name) | Existing Resource Group Name | `string` | n/a | yes |
| <a name="input_pvs_zone"></a> [pvs\_zone](#input\_pvs\_zone) | IBM Cloud PVS Zone. Valid values: sao01,osa21,tor01,us-south,dal12,us-east,tok04,lon04,lon06,eu-de-1,eu-de-2,syd04,syd05 | `string` | n/a | yes |
| <a name="input_reuse_cloud_connections"></a> [reuse\_cloud\_connections](#input\_reuse\_cloud\_connections) | When the value is true, cloud connections will be reused (and is already attached to Transit gateway) | `bool` | `false` | no |
| <a name="input_slz_workspace_id"></a> [slz\_workspace\_id](#input\_slz\_workspace\_id) | IBM Cloud Schematics workspace ID of an existing Secure Landing Zone with VSIs deployment.If you do not yet have an existing deployment, click [here](https://cloud.ibm.com/catalog/content/slz-vpc-with-vsis-a87ed9a5-d130-47a3-980b-5ceb1d4f9280-global#create) to create one. Please note: a specific  configuration is needed for the deployment. You may find it [here](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/examples/ibm-catalog/standard-solution/slz_json_configs_for_powervs/vpc_landscape_config.json). Copy and paste that configuration into the `override_json_string` deployment value. | `string` | `null` | no |
| <a name="input_squid_config"></a> [squid\_config](#input\_squid\_config) | Squid Configuration on server | `map(any)` | <pre>{<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh\_public\_key' in VPC services. Entered data must be in heredoc strings format (https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tag names for PowerVS service | `list(string)` | <pre>[<br>  "sap"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_powervs_infra"></a> [powervs\_infra](#output\_powervs\_infra) | Standard-catalog PowerVS Infrastructure outputs for next solution consumption |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Note

For all optional fields, default values (Eg: `null`) are given in variable.tf file. User can configure the same by overwriting with appropriate values.
