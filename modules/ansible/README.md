# Module ansible-configure-network-services

This module installs and configures the Squid Proxy, DNS Forwarder, NTP Forwarder, NFS on specified host and sets the host as server for these services using ansible galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/).

## Usage
```hcl
provider "ibm" {
region           = "sao"
zone             = "sao01"
ibmcloud_api_key = "your api key" != null ? "your api key" : null
}

module "configure_squid" {

source     = "./submodules/configure_network_services"
access_host_or_ip          = var.access_host_or_ip
target_server_ip           = var.target_server_ip
ssh_private_key            = var.ssh_private_key
service_config             = var.service_config
perform_proxy_client_setup = var.perform_proxy_client_setup
}

```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [terraform_data.execute_playbooks](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.setup_ansible_host](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.trigger_ansible_vars](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_host_or_ip"></a> [ansible\_host\_or\_ip](#input\_ansible\_host\_or\_ip) | Private IP of virtual server instance on which ansible will be installed and configured to act as central ansible node. | `string` | n/a | yes |
| <a name="input_bastion_host_ip"></a> [bastion\_host\_ip](#input\_bastion\_host\_ip) | Jump/Bastion server public IP address to reach the ansible host which has private IP. | `string` | n/a | yes |
| <a name="input_dst_inventory_file_name"></a> [dst\_inventory\_file\_name](#input\_dst\_inventory\_file\_name) | Name for the inventory file to be generated on the Ansible host. | `string` | n/a | yes |
| <a name="input_dst_playbook_file_name"></a> [dst\_playbook\_file\_name](#input\_dst\_playbook\_file\_name) | Name for the playbook file to be generated on the Ansible host. | `string` | n/a | yes |
| <a name="input_dst_script_file_name"></a> [dst\_script\_file\_name](#input\_dst\_script\_file\_name) | Name for the bash file to be generated on the Ansible host. | `string` | n/a | yes |
| <a name="input_inventory_template_vars"></a> [inventory\_template\_vars](#input\_inventory\_template\_vars) | Map values for the inventory template. | `map(any)` | n/a | yes |
| <a name="input_playbook_template_vars"></a> [playbook\_template\_vars](#input\_playbook\_template\_vars) | Map values for the ansible playbook template. | `map(any)` | n/a | yes |
| <a name="input_src_inventory_template_name"></a> [src\_inventory\_template\_name](#input\_src\_inventory\_template\_name) | Name of the inventory template file located within the 'templates-ansible' directory. | `string` | n/a | yes |
| <a name="input_src_playbook_template_name"></a> [src\_playbook\_template\_name](#input\_src\_playbook\_template\_name) | Name of the playbook template file located within the 'templates-ansible' directory. | `string` | n/a | yes |
| <a name="input_src_script_template_name"></a> [src\_script\_template\_name](#input\_src\_script\_template\_name) | Name of the bash script template file located within the 'templates-ansible' directory. | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key used to login to jump/bastion server, also the ansible host and all the hosts on which tasks will be executed. Entered data must be in heredoc strings format (https://www.terraform.io/language/expressions/strings#heredoc-strings). This key will be written temprarily on ansible host and deleted after execution. | `string` | n/a | yes |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
