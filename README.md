<!-- BEGIN MODULE HOOK -->

# IBM Power Virtual Server with VPC landing zone module

[![Graduated (Supported)](https://img.shields.io/badge/status-Graduated%20(Supported)-brightgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-powervs-infrastructure?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

The Power Virtual Server with VPC landing zone module automates the following tasks:

- Creates an IBM® Power Virtual Server (PowerVS) workspace.
- Creates an SSH key.
- Creates two private networks: a management network and a backup network.
- Creates two [IBM Cloud connections](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-cloud-connections) with an option to reuse the connections.
- Attaches the IBM Cloud connections to a transit gateway.
- Attaches the private networks to the IBM Cloud connections.
- Installs and configures the Squid Proxy, DNS Forwarder, NTP Forwarder and NFS on specified host, and sets the host as server for these services by using Ansible roles.

The following limitations apply to the module:

- Only two IBM Cloud connections are supported.
- You cannot reuse IBM Cloud connections.
- Private networks in a PowerVS workspace must be in 10.0.0.0/8 range.
- Only the following operating systems are supported:
    - SUSE Linux Enterprise Server (SLES) version 15 SP3
    - Red Hat Enterprise Linux (RHEL) version 8.4

For more information about IBM Power Virtual Server see the [getting started](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-getting-started) IBM Cloud docs.

# Table of Contents
1. [Required IAM access policies](#required-iam-access-policies)
2. [Usage](#usage)
3. [Reference architectures](#reference-architectures)
4. [Solutions](#solutions)


## Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
    - IAM Services
        - **Workspace for Power Virtual Server** service
        - **Power Virtual Server** service
            - `Editor` platform access
        - **VPC Infrastructure Services** service
            - `Editor` platform access
        - **Transit Gateway** service
            - `Editor` platform access
        - **Direct Link** service
            - `Editor` platform access

## Usage
```hcl
provider "ibm" {
  region           = var.powervs_region
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

module "power-infrastructure" {
  source  = "terraform-ibm-modules/powervs-infrastructure/ibm"
  version = "latest" # Replace "latest" with a release version to lock into a specific release

  powervs_zone                 = var.powervs_zone
  powervs_resource_group_name  = var.powervs_resource_group_name
  powervs_workspace_name       = var.powervs_workspace_name
  tags                         = var.tags
  powervs_image_names          = var.powervs_image_names
  powervs_sshkey_name          = var.powervs_sshkey_name
  ssh_public_key               = var.ssh_public_key
  ssh_private_key              = var.ssh_private_key
  powervs_management_network   = var.powervs_management_network
  powervs_backup_network       = var.powervs_backup_network
  transit_gateway_name         = var.transit_gateway_name
  reuse_cloud_connections      = var.reuse_cloud_connections
  cloud_connection_name_prefix = var.cloud_connection_name_prefix
  cloud_connection_count       = var.cloud_connection_count
  cloud_connection_speed       = var.cloud_connection_speed
  cloud_connection_gr          = var.cloud_connection_gr
  cloud_connection_metered     = var.cloud_connection_metered
  access_host_or_ip            = var.access_host_or_ip
  squid_config                 = var.squid_config
  dns_forwarder_config         = var.dns_forwarder_config
  ntp_forwarder_config         = var.ntp_forwarder_config
  nfs_config                   = var.nfs_config
  perform_proxy_client_setup   = var.perform_proxy_client_setup
}
```

## Reference architectures

- Power Virtual Server with VPC landing zone - [PowerVS workspace full-stack variation](reference-architectures/full-stack/deploy-arch-ibm-pvs-inf-full-stack.md)
- Power Virtual Server with VPC landing zone - [PowerVS workspace extension variation](reference-architectures/extension/deploy-arch-ibm-pvs-inf-extension.md)

## Solutions
| Variation  | Available on IBM Catalog  |  Requires Schematics Workspace ID | Creates VPC Landing Zone | Performs VPC VSI OS Config | Creates PowerVS Infrastructure | Creates PowerVS Instance | Performs PowerVS OS Config |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [Full-Stack](solutions/full-stack)  | :heavy_check_mark:  | N/A  | :heavy_check_mark:  | :heavy_check_mark:  |  :heavy_check_mark: | N/A | N/A |
| [Extension](solutions/extension)    | :heavy_check_mark:  |  :heavy_check_mark: |  N/A | N/A | :heavy_check_mark:  | N/A | N/A |

<!-- END MODULE HOOK -->

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.49.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_configure_dns"></a> [configure\_dns](#module\_configure\_dns) | ./submodules/configure_network_services | n/a |
| <a name="module_configure_nfs"></a> [configure\_nfs](#module\_configure\_nfs) | ./submodules/configure_network_services | n/a |
| <a name="module_configure_ntp"></a> [configure\_ntp](#module\_configure\_ntp) | ./submodules/configure_network_services | n/a |
| <a name="module_configure_squid"></a> [configure\_squid](#module\_configure\_squid) | ./submodules/configure_network_services | n/a |
| <a name="module_initial_validation"></a> [initial\_validation](#module\_initial\_validation) | ./submodules/terraform_initial_validation | n/a |
| <a name="module_powervs_cloud_connection_attach"></a> [powervs\_cloud\_connection\_attach](#module\_powervs\_cloud\_connection\_attach) | ./submodules/powervs_cloudconnection_attach | n/a |
| <a name="module_powervs_cloud_connection_create"></a> [powervs\_cloud\_connection\_create](#module\_powervs\_cloud\_connection\_create) | ./submodules/powervs_cloudconnection_create | n/a |
| <a name="module_powervs_workspace"></a> [powervs\_workspace](#module\_powervs\_workspace) | ./submodules/powervs_workspace | n/a |

### Resources

| Name | Type |
|------|------|
| [time_sleep.wait_for_squid_setup_to_complete](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | The public IP address or hostname for the access host. The address is used to reach the target or server\_host IP address and to configure the DNS, NTP, NFS, and Squid proxy services. Set it to null if you do not want to configure any services. | `string` | `null` | no |
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Required number of Cloud connections to create or reuse. The maximum number of connections is two per location. | `number` | `2` | no |
| <a name="input_cloud_connection_gr"></a> [cloud\_connection\_gr](#input\_cloud\_connection\_gr) | Whether to enable global routing for this IBM Cloud connection. You can specify this value when you create a connection. | `bool` | `null` | no |
| <a name="input_cloud_connection_metered"></a> [cloud\_connection\_metered](#input\_cloud\_connection\_metered) | Whether to enable metering for this IBM Cloud connection. You can specify this value when you create a connection. | `bool` | `null` | no |
| <a name="input_cloud_connection_name_prefix"></a> [cloud\_connection\_name\_prefix](#input\_cloud\_connection\_name\_prefix) | If null or empty string, default cloud connection name will be <zone>-conn-1. | `string` | `null` | no |
| <a name="input_cloud_connection_speed"></a> [cloud\_connection\_speed](#input\_cloud\_connection\_speed) | Speed in megabits per second. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when you create a connection. | `number` | `5000` | no |
| <a name="input_dns_forwarder_config"></a> [dns\_forwarder\_config](#input\_dns\_forwarder\_config) | Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS. | <pre>object({<br>    dns_enable        = bool<br>    server_host_or_ip = string<br>    dns_servers       = string<br>  })</pre> | <pre>{<br>  "dns_enable": "false",<br>  "dns_servers": "161.26.0.7; 161.26.0.8; 9.9.9.9;",<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_nfs_config"></a> [nfs\_config](#input\_nfs\_config) | Configuration for the shared NFS file system (for example, for the installation media). Creates a filesystem of disk size specified, mounts and NFS exports it. | <pre>object({<br>    nfs_enable        = bool<br>    server_host_or_ip = string<br>    nfs_file_system = list(object({<br>      name       = string<br>      mount_path = string<br>      size       = number<br>    }))<br>  })</pre> | <pre>{<br>  "nfs_enable": "false",<br>  "nfs_file_system": [<br>    {<br>      "mount_path": "/nfs",<br>      "name": "nfs",<br>      "size": 1000<br>    }<br>  ],<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_ntp_forwarder_config"></a> [ntp\_forwarder\_config](#input\_ntp\_forwarder\_config) | Configuration for the NTP forwarder to an NTP service that is not reachable directly from PowerVS. | <pre>object({<br>    ntp_enable        = bool<br>    server_host_or_ip = string<br>  })</pre> | <pre>{<br>  "ntp_enable": "false",<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_perform_proxy_client_setup"></a> [perform\_proxy\_client\_setup](#input\_perform\_proxy\_client\_setup) | Proxy configuration to allow internet access for a VM or LPAR. | <pre>object(<br>    {<br>      squid_client_ips = list(string)<br>      squid_server_ip  = string<br>      squid_port       = string<br>      no_proxy_hosts   = string<br>    }<br>  )</pre> | `null` | no |
| <a name="input_powervs_backup_network"></a> [powervs\_backup\_network](#input\_powervs\_backup\_network) | Name of the IBM Cloud PowerVS backup network and CIDR to create. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.52.0.0/24",<br>  "name": "bkp_net"<br>}</pre> | no |
| <a name="input_powervs_image_names"></a> [powervs\_image\_names](#input\_powervs\_image\_names) | List of Images to be imported into cloud account from catalog images. | `list(string)` | <pre>[<br>  "SLES15-SP3-SAP",<br>  "SLES15-SP3-SAP-NETWEAVER",<br>  "RHEL8-SP4-SAP",<br>  "RHEL8-SP4-SAP-NETWEAVER"<br>]</pre> | no |
| <a name="input_powervs_management_network"></a> [powervs\_management\_network](#input\_powervs\_management\_network) | Name of the IBM Cloud PowerVS management subnet and CIDR to create. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.51.0.0/24",<br>  "name": "mgmt_net"<br>}</pre> | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_sshkey_name"></a> [powervs\_sshkey\_name](#input\_powervs\_sshkey\_name) | Name of the PowerVS SSH key to create. | `string` | `"ssh-key-pvs"` | no |
| <a name="input_powervs_workspace_name"></a> [powervs\_workspace\_name](#input\_powervs\_workspace\_name) | Name of the PowerVS workspace to create. | `string` | `"power-workspace"` | no |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud PowerVS zone. | `string` | n/a | yes |
| <a name="input_reuse_cloud_connections"></a> [reuse\_cloud\_connections](#input\_reuse\_cloud\_connections) | When true, IBM Cloud connections are reused (if attached to the transit gateway). | `bool` | `false` | no |
| <a name="input_squid_config"></a> [squid\_config](#input\_squid\_config) | Configuration for the Squid proxy setup. | <pre>object({<br>    squid_enable      = bool<br>    server_host_or_ip = string<br>    squid_port        = string<br>  })</pre> | <pre>{<br>  "server_host_or_ip": "",<br>  "squid_enable": "false",<br>  "squid_port": "3128"<br>}</pre> | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh\_public\_key'. Entered data must be in heredoc strings format (https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for the PowerVM to create. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud PowerVS Workspace. | `list(string)` | `null` | no |
| <a name="input_transit_gateway_name"></a> [transit\_gateway\_name](#input\_transit\_gateway\_name) | Name of the existing transit gateway. Required when you create new IBM Cloud connections. Set it to null if reusing cloud connections | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Access host for created PowerVS infrastructure. |
| <a name="output_cloud_connection_count"></a> [cloud\_connection\_count](#output\_cloud\_connection\_count) | Number of cloud connections configured in created PowerVS infrastructure. |
| <a name="output_dns_host_or_ip"></a> [dns\_host\_or\_ip](#output\_dns\_host\_or\_ip) | DNS forwarder host for created PowerVS infrastructure. |
| <a name="output_nfs_host_or_ip_path"></a> [nfs\_host\_or\_ip\_path](#output\_nfs\_host\_or\_ip\_path) | NFS host for created PowerVS infrastructure. |
| <a name="output_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#output\_ntp\_host\_or\_ip) | NTP host for created PowerVS infrastructure. |
| <a name="output_powervs_backup_network_name"></a> [powervs\_backup\_network\_name](#output\_powervs\_backup\_network\_name) | Name of backup network in created PowerVS infrastructure. |
| <a name="output_powervs_management_network_name"></a> [powervs\_management\_network\_name](#output\_powervs\_management\_network\_name) | Name of management network in created PowerVS infrastructure. |
| <a name="output_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#output\_powervs\_resource\_group\_name) | IBM Cloud resource group where PowerVS infrastructure is created. |
| <a name="output_powervs_sshkey_name"></a> [powervs\_sshkey\_name](#output\_powervs\_sshkey\_name) | SSH public key name in created PowerVS infrastructure. |
| <a name="output_powervs_workspace_crn"></a> [powervs\_workspace\_crn](#output\_powervs\_workspace\_crn) | PowerVS infrastructure workspace CRN. |
| <a name="output_powervs_workspace_name"></a> [powervs\_workspace\_name](#output\_powervs\_workspace\_name) | PowerVS infrastructure workspace name. |
| <a name="output_powervs_zone"></a> [powervs\_zone](#output\_powervs\_zone) | Zone where PowerVS infrastructure is created. |
| <a name="output_proxy_host_or_ip_port"></a> [proxy\_host\_or\_ip\_port](#output\_proxy\_host\_or\_ip\_port) | Proxy host for created PowerVS infrastructure. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- BEGIN CONTRIBUTING HOOK -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- END CONTRIBUTING HOOK -->
