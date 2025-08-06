# Module ansible

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.1 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [random_id.filename](https://registry.terraform.io/providers/hashicorp/random/3.6.1/docs/resources/id) | resource |
| [terraform_data.execute_playbooks](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.execute_playbooks_with_vault](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.setup_ansible_host](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.trigger_ansible_vars](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_host_or_ip"></a> [ansible\_host\_or\_ip](#input\_ansible\_host\_or\_ip) | Private IP of virtual server instance running RHEL OS on which ansible will be installed and configured to act as central ansible node. | `string` | n/a | yes |
| <a name="input_ansible_vault_password"></a> [ansible\_vault\_password](#input\_ansible\_vault\_password) | Vault password to encrypt ansible playbooks that contain sensitive information. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]\_{\|}~. | `string` | `null` | no |
| <a name="input_bastion_host_ip"></a> [bastion\_host\_ip](#input\_bastion\_host\_ip) | Jump/Bastion server public IP address to reach the ansible host which has private IP. | `string` | n/a | yes |
| <a name="input_configure_ansible_host"></a> [configure\_ansible\_host](#input\_configure\_ansible\_host) | If set to true, bash script will be executed to install and configure the collections and packages on ansible node. | `bool` | n/a | yes |
| <a name="input_dst_inventory_file_name"></a> [dst\_inventory\_file\_name](#input\_dst\_inventory\_file\_name) | Name for the inventory file to be generated on the Ansible host. | `string` | n/a | yes |
| <a name="input_dst_playbook_file_name"></a> [dst\_playbook\_file\_name](#input\_dst\_playbook\_file\_name) | Name for the playbook file to be generated on the Ansible host. | `string` | n/a | yes |
| <a name="input_dst_script_file_name"></a> [dst\_script\_file\_name](#input\_dst\_script\_file\_name) | Name for the bash file to be generated on the Ansible host. | `string` | n/a | yes |
| <a name="input_inventory_template_vars"></a> [inventory\_template\_vars](#input\_inventory\_template\_vars) | Map values for the inventory template. | `map(any)` | n/a | yes |
| <a name="input_playbook_template_vars"></a> [playbook\_template\_vars](#input\_playbook\_template\_vars) | Map values for the ansible playbook template. | `map(any)` | n/a | yes |
| <a name="input_src_inventory_template_name"></a> [src\_inventory\_template\_name](#input\_src\_inventory\_template\_name) | Name of the inventory template file located within the 'templates-ansible' directory. | `string` | n/a | yes |
| <a name="input_src_playbook_template_name"></a> [src\_playbook\_template\_name](#input\_src\_playbook\_template\_name) | Name of the playbook template file located within the 'templates-ansible' directory. | `string` | n/a | yes |
| <a name="input_src_script_template_name"></a> [src\_script\_template\_name](#input\_src\_script\_template\_name) | Name of the bash script template file located within the 'templates-ansible' directory. | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key used to login to jump/bastion server, also the ansible host and all the hosts on which tasks will be executed. This key will be written temporarily on ansible host and deleted after execution. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_playbook_output"></a> [playbook\_output](#output\_playbook\_output) | Output from execute\_playbooks. Only available after apply. Can be used to create an implicit dependency on the playbook execution. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
