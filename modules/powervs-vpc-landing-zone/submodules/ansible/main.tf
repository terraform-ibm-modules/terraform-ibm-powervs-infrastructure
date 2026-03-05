##############################################################################
# PowerVS Ansible Module - Simplified Wrapper
# This module now uses the shared ansible-executor base module
##############################################################################

locals {
  src_ansible_templates_dir = "${path.module}/templates-ansible"
}

module "ansible_executor" {
  source = "../../../../ansible-executor"

  # Connection details
  bastion_host_ip    = var.bastion_host_ip
  ansible_host_or_ip = var.ansible_host_or_ip
  ssh_private_key    = var.ssh_private_key

  # Ansible host configuration
  configure_ansible_host     = var.configure_ansible_host
  ansible_node_config_script = "${path.module}/ansible_node_packages.sh"

  # Template configuration
  ansible_templates = {
    script_template    = "${local.src_ansible_templates_dir}/${var.src_script_template_name}"
    playbook_template  = "${local.src_ansible_templates_dir}/${var.src_playbook_template_name}"
    inventory_template = "${local.src_ansible_templates_dir}/${var.src_inventory_template_name}"
  }

  # Destination file names
  ansible_files = {
    script_file    = var.dst_script_file_name
    playbook_file  = var.dst_playbook_file_name
    inventory_file = var.dst_inventory_file_name
  }

  # Template variables
  ansible_vars = {
    playbook_vars  = var.playbook_template_vars
    inventory_vars = var.inventory_template_vars
  }

  # Vault configuration
  ansible_vault_password     = var.ansible_vault_password
  enable_playbook_encryption = var.ansible_vault_password != null

  # PowerVS-specific features (disabled for this module)
  enable_ocp_config_encryption = false
  enable_api_key_redaction     = false
}
