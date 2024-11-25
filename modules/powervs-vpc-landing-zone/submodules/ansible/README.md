# Module ansible

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [terraform_data.execute_network_playbooks](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.execute_playbooks_3](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.setup_ansible_host](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.trigger_ansible_vars](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_host_or_ip"></a> [ansible\_host\_or\_ip](#input\_ansible\_host\_or\_ip) | Private IP of virtual server instance running RHEL OS on which ansible will be installed and configured to act as central ansible node. | `string` | n/a | yes |
| <a name="input_bastion_host_ip"></a> [bastion\_host\_ip](#input\_bastion\_host\_ip) | Jump/Bastion server public IP address to reach the ansible host which has private IP. | `string` | n/a | yes |
| <a name="input_dst_playbook_file_monitoring_name"></a> [dst\_playbook\_file\_monitoring\_name](#input\_dst\_playbook\_file\_monitoring\_name) | Name for the playbook monitoring file to be generated on the Ansible host. | `string` | n/a | yes |
| <a name="input_dst_playbook_file_name"></a> [dst\_playbook\_file\_name](#input\_dst\_playbook\_file\_name) | Name for the playbook file to be generated on the Ansible host. | `string` | n/a | yes |
| <a name="input_dst_script_file_monitoring_name"></a> [dst\_script\_file\_monitoring\_name](#input\_dst\_script\_file\_monitoring\_name) | Name for the bash monitoring file to be generated on the Ansible host. | `string` | n/a | yes |
| <a name="input_dst_script_file_name"></a> [dst\_script\_file\_name](#input\_dst\_script\_file\_name) | Name for the bash file to be generated on the Ansible host. | `string` | n/a | yes |
| <a name="input_monitoring_host_ip"></a> [monitoring\_host\_ip](#input\_monitoring\_host\_ip) | Private IP of virtual server instance running SLES OS for monitoring services . | `string` | n/a | yes |
| <a name="input_playbook_template_vars"></a> [playbook\_template\_vars](#input\_playbook\_template\_vars) | Map values for the ansible playbook template. | `map(any)` | n/a | yes |
| <a name="input_src_playbook_template_monitoring_name"></a> [src\_playbook\_template\_monitoring\_name](#input\_src\_playbook\_template\_monitoring\_name) | Name of the playbook template monitoring file located within the 'templates-ansible' directory. | `string` | n/a | yes |
| <a name="input_src_playbook_template_name"></a> [src\_playbook\_template\_name](#input\_src\_playbook\_template\_name) | Name of the playbook template file located within the 'templates-ansible' directory. | `string` | n/a | yes |
| <a name="input_src_script_template_monitoring_name"></a> [src\_script\_template\_monitoring\_name](#input\_src\_script\_template\_monitoring\_name) | Name for the bash monitoring file to be generated on the Ansible host. | `string` | n/a | yes |
| <a name="input_src_script_template_name"></a> [src\_script\_template\_name](#input\_src\_script\_template\_name) | Name of the bash script template file located within the 'templates-ansible' directory. | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key used to login to jump/bastion server, also the ansible host and all the hosts on which tasks will be executed. Entered data must be in heredoc strings format (https://www.terraform.io/language/expressions/strings#heredoc-strings). | `string` | n/a | yes |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
