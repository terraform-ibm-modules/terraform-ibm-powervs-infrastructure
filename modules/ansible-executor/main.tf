##############################################################################
# Ansible Executor Module - Simplified and Consolidated Implementation
##############################################################################

locals {
  dst_files_dir = "/root/terraform_files"

  # Template paths
  src_script_tftpl_path    = var.ansible_templates.script_template
  src_playbook_tftpl_path  = var.ansible_templates.playbook_template
  src_inventory_tftpl_path = var.ansible_templates.inventory_template

  # Destination file paths
  dst_script_file_path    = "${local.dst_files_dir}/${var.ansible_files.script_file}"
  dst_playbook_file_path  = "${local.dst_files_dir}/${var.ansible_files.playbook_file}"
  dst_inventory_file_path = "${local.dst_files_dir}/${var.ansible_files.inventory_file}"

  # IBM Cloud API key handling
  ibmcloud_api_key = var.ibmcloud_api_key == null ? "" : nonsensitive(var.ibmcloud_api_key)

  # Determine if vault encryption is enabled
  use_vault = var.ansible_vault_password != null && var.enable_playbook_encryption

  # Common SSH connection configuration
  ansible_connection = {
    type         = "ssh"
    user         = "root"
    bastion_host = var.bastion_host_ip
    host         = var.ansible_host_or_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "5m"
  }

  # Common provisioner commands
  setup_commands = [
    "mkdir -p ${local.dst_files_dir}",
    "chmod 777 ${local.dst_files_dir}"
  ]

  ssh_key_setup = [
    "mkdir -p /root/.ssh/",
    "chmod 700 /root/.ssh",
    "echo '${var.ssh_private_key}' > ${local.private_key_file}",
    "chmod 600 ${local.private_key_file}"
  ]

  ssh_key_cleanup = [
    "rm -rf ${local.private_key_file}"
  ]

  execute_playbook = [
    "chmod +x ${local.dst_script_file_path}",
    var.enable_api_key_redaction && var.ibmcloud_api_key != null ? "export IBMCLOUD_API_KEY=${local.ibmcloud_api_key} && ${local.dst_script_file_path}" : local.dst_script_file_path
  ]
}

resource "random_id" "filename" {
  byte_length = 2
}

locals {
  private_key_file = "/root/.ssh/id_rsa_${substr(random_id.filename.b64_url, 0, 4)}"
}

##############################################################################
# 1. Setup Ansible Host (Install packages and collections)
##############################################################################

resource "terraform_data" "setup_ansible_host" {
  count = var.configure_ansible_host ? 1 : 0

  connection {
    type         = local.ansible_connection.type
    user         = local.ansible_connection.user
    bastion_host = local.ansible_connection.bastion_host
    host         = local.ansible_connection.host
    private_key  = local.ansible_connection.private_key
    agent        = local.ansible_connection.agent
    timeout      = local.ansible_connection.timeout
  }

  # Add checksum to avoid re-running if packages haven't changed
  triggers_replace = {
    packages_hash = md5(file(var.ansible_node_config_script))
  }

  # Create terraform scripts directory
  provisioner "remote-exec" {
    inline = local.setup_commands
  }

  # Copy ansible_node_packages.sh shell file to ansible host
  provisioner "file" {
    source      = var.ansible_node_config_script
    destination = "${local.dst_files_dir}/ansible_node_packages.sh"
  }

  # Execute ansible_node_packages.sh shell script to configure ansible host
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_files_dir}/ansible_node_packages.sh",
      "${local.dst_files_dir}/ansible_node_packages.sh"
    ]
  }
}

##############################################################################
# 2. Execute Ansible Playbooks (Without Vault Encryption)
##############################################################################

resource "terraform_data" "trigger_ansible_vars" {
  input = [var.ansible_vars.playbook_vars, var.ansible_vars.inventory_vars]
}

resource "terraform_data" "execute_playbooks" {
  depends_on = [terraform_data.setup_ansible_host]
  count      = local.use_vault ? 0 : 1

  connection {
    type         = local.ansible_connection.type
    user         = local.ansible_connection.user
    bastion_host = local.ansible_connection.bastion_host
    host         = local.ansible_connection.host
    private_key  = local.ansible_connection.private_key
    agent        = local.ansible_connection.agent
    timeout      = local.ansible_connection.timeout
  }

  triggers_replace = terraform_data.trigger_ansible_vars

  # Create terraform scripts directory
  provisioner "remote-exec" {
    inline = local.setup_commands
  }

  # Write all files using heredoc for atomic operation
  provisioner "remote-exec" {
    inline = [
      <<-EOT
        cat > ${local.dst_playbook_file_path} <<'PLAYBOOK'
        ${templatefile(local.src_playbook_tftpl_path, var.ansible_vars.playbook_vars)}
        PLAYBOOK

        cat > ${local.dst_inventory_file_path} <<'INVENTORY'
        ${templatefile(local.src_inventory_tftpl_path, var.ansible_vars.inventory_vars)}
        INVENTORY

        cat > ${local.dst_script_file_path} <<'SCRIPT'
        ${templatefile(local.src_script_tftpl_path, {
      ansible_playbook_file    = local.dst_playbook_file_path,
      ansible_log_path         = local.dst_files_dir,
      ansible_inventory        = local.dst_inventory_file_path,
      ansible_private_key_file = local.private_key_file
})}
        SCRIPT
      EOT
]
}

# Write ssh user's ssh private key
provisioner "remote-exec" {
  inline = local.ssh_key_setup
}

# Create vault password file if needed for OCP config encryption
provisioner "remote-exec" {
  inline = var.enable_ocp_config_encryption && var.ansible_vault_password != null ? [
    "echo ${var.ansible_vault_password} > password_file"
  ] : ["echo 'No vault password needed'"]
}

# Decrypt OCP config if it exists and encryption is enabled
provisioner "remote-exec" {
  inline = var.enable_ocp_config_encryption ? [
    "if [ -f /root/.powervs/config.json ]; then",
    "  if head -n 1 /root/.powervs/config.json | grep -q '^$ANSIBLE_VAULT'; then",
    "    ansible-vault decrypt /root/.powervs/config.json --vault-password-file password_file",
    "  fi",
    "fi"
  ] : ["echo 'OCP config encryption not enabled'"]
}

# Execute bash shell script to run ansible playbooks
provisioner "remote-exec" {
  inline = local.execute_playbook
}

# Clean up vault password file
provisioner "remote-exec" {
  inline = var.enable_ocp_config_encryption && var.ansible_vault_password != null ? [
    "rm -f password_file"
  ] : ["echo 'No password file to clean'"]
}

# Clean up SSH key
provisioner "remote-exec" {
  inline = local.ssh_key_cleanup
}

# Encrypt OCP config if it exists and encryption is enabled
provisioner "remote-exec" {
  inline = var.enable_ocp_config_encryption && var.ansible_vault_password != null ? [
    "if [ -f /root/.powervs/config.json ]; then",
    "  if ! ( head -n 1 /root/.powervs/config.json | grep -q '^$ANSIBLE_VAULT' ); then",
    "    echo ${var.ansible_vault_password} > password_file",
    "    ansible-vault encrypt /root/.powervs/config.json --vault-password-file password_file",
    "  fi",
    "fi",
    "rm -f password_file"
  ] : ["echo 'OCP config encryption not enabled'"]
}

# Redact API key from logs if enabled
provisioner "remote-exec" {
  inline = var.enable_api_key_redaction && var.ibmcloud_api_key != null ? [
    "if [ ! -z $IBMCLOUD_API_KEY ]; then",
    "  IBMCLOUD_API_KEY=\"${local.ibmcloud_api_key}\"",
    "  grep -RIl --devices=skip --exclude-dir='.ansible/' -- \"$IBMCLOUD_API_KEY\" \"/root\" | while IFS= read -r file; do",
    "    sed -i 's/'\"$IBMCLOUD_API_KEY\"'/***redacted***/g' \"$file\"",
    "  done",
    "fi"
  ] : ["echo 'API key redaction not enabled'"]
}

# Print OpenShift installation log if applicable
provisioner "remote-exec" {
  inline = [
    "if [ -f ${var.ocp_cluster_dir}/.openshift_install.log ]; then cat ${var.ocp_cluster_dir}/.openshift_install.log; fi"
  ]
  on_failure = continue
}
}

##############################################################################
# 3. Execute Ansible Playbooks (With Vault Encryption)
##############################################################################

resource "terraform_data" "execute_playbooks_with_vault" {
  depends_on = [terraform_data.setup_ansible_host]
  count      = local.use_vault ? 1 : 0

  connection {
    type         = local.ansible_connection.type
    user         = local.ansible_connection.user
    bastion_host = local.ansible_connection.bastion_host
    host         = local.ansible_connection.host
    private_key  = local.ansible_connection.private_key
    agent        = local.ansible_connection.agent
    timeout      = local.ansible_connection.timeout
  }

  triggers_replace = terraform_data.trigger_ansible_vars

  # Create terraform scripts directory
  provisioner "remote-exec" {
    inline = local.setup_commands
  }

  # Write playbook file
  provisioner "remote-exec" {
    inline = [
      <<-EOT
        cat > ${local.dst_playbook_file_path} <<'PLAYBOOK'
        ${templatefile(local.src_playbook_tftpl_path, var.ansible_vars.playbook_vars)}
        PLAYBOOK
      EOT
    ]
  }

  # Encrypt the ansible playbook file with sensitive information using ansible vault
  provisioner "remote-exec" {
    inline = [
      "echo ${var.ansible_vault_password} > password_file",
      "ansible-vault encrypt ${local.dst_playbook_file_path} --vault-password-file password_file"
    ]
  }

  # Write inventory and script files
  provisioner "remote-exec" {
    inline = [
      <<-EOT
        cat > ${local.dst_inventory_file_path} <<'INVENTORY'
        ${templatefile(local.src_inventory_tftpl_path, var.ansible_vars.inventory_vars)}
        INVENTORY

        cat > ${local.dst_script_file_path} <<'SCRIPT'
        ${templatefile(local.src_script_tftpl_path, {
      ansible_playbook_file    = local.dst_playbook_file_path,
      ansible_log_path         = local.dst_files_dir,
      ansible_inventory        = local.dst_inventory_file_path,
      ansible_private_key_file = local.private_key_file
})}
        SCRIPT
      EOT
]
}

# Write ssh user's ssh private key
provisioner "remote-exec" {
  inline = local.ssh_key_setup
}

# Decrypt OCP config if it exists and encryption is enabled
provisioner "remote-exec" {
  inline = var.enable_ocp_config_encryption ? [
    "if [ -f /root/.powervs/config.json ]; then",
    "  if head -n 1 /root/.powervs/config.json | grep -q '^$ANSIBLE_VAULT'; then",
    "    ansible-vault decrypt /root/.powervs/config.json --vault-password-file password_file",
    "  fi",
    "fi"
  ] : ["echo 'OCP config encryption not enabled'"]
}

# Execute bash shell script to run ansible playbooks
provisioner "remote-exec" {
  inline = local.execute_playbook
}

# Encrypt OCP config if it exists and encryption is enabled
provisioner "remote-exec" {
  inline = var.enable_ocp_config_encryption ? [
    "if [ -f /root/.powervs/config.json ]; then",
    "  if ! ( head -n 1 /root/.powervs/config.json | grep -q '^$ANSIBLE_VAULT' ); then",
    "    echo ${var.ansible_vault_password} > password_file",
    "    ansible-vault encrypt /root/.powervs/config.json --vault-password-file password_file",
    "  fi",
    "fi",
    "rm -f password_file"
  ] : ["echo 'OCP config encryption not enabled'"]
}

# Redact API key from logs if enabled
provisioner "remote-exec" {
  inline = var.enable_api_key_redaction && var.ibmcloud_api_key != null ? [
    "if [ ! -z $IBMCLOUD_API_KEY ]; then",
    "  IBMCLOUD_API_KEY=\"${local.ibmcloud_api_key}\"",
    "  grep -RIl --devices=skip --exclude-dir='.ansible/' -- \"$IBMCLOUD_API_KEY\" \"/root\" | while IFS= read -r file; do",
    "    sed -i 's/'\"$IBMCLOUD_API_KEY\"'/***redacted***/g' \"$file\"",
    "  done",
    "fi"
  ] : ["echo 'API key redaction not enabled'"]
}

# Clean up vault password and SSH key
provisioner "remote-exec" {
  inline = concat(
    ["rm -rf password_file"],
    local.ssh_key_cleanup
  )
}
}

##############################################################################
# Backward compatibility for moved resources
##############################################################################

moved {
  from = terraform_data.setup_ansible_host
  to   = terraform_data.setup_ansible_host[0]
}
