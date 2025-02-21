locals {
  src_ansible_templates_dir  = "${path.module}/templates-ansible"
  ansible_node_config_script = "${path.module}/ansible_node_packages.sh"
  dst_files_dir              = "/root/terraform_files"

  src_script_tftpl_path    = "${local.src_ansible_templates_dir}/${var.src_script_template_name}"
  dst_script_file_path     = "${local.dst_files_dir}/${var.dst_script_file_name}"
  src_playbook_tftpl_path  = "${local.src_ansible_templates_dir}/${var.src_playbook_template_name}"
  dst_playbook_file_path   = "${local.dst_files_dir}/${var.dst_playbook_file_name}"
  src_inventory_tftpl_path = "${local.src_ansible_templates_dir}/${var.src_inventory_template_name}"
  dst_inventory_file_path  = "${local.dst_files_dir}/${var.dst_inventory_file_name}"

}

resource "random_id" "filename" {
  byte_length = 2 # 4 characters when encoded in base32, which will give you a lowercase alphabetic string
}

locals {
  private_key_file = "/root/.ssh/id_rsa_${substr(random_id.filename.b64_url, 0, 4)}"
}
##############################################################
# 1. Execute shell script to install ansible roles/collections
##############################################################

resource "terraform_data" "setup_ansible_host" {
  count = var.configure_ansible_host ? 1 : 0

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.bastion_host_ip
    host         = var.ansible_host_or_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "5m"
  }

  # Create terraform scripts directory
  provisioner "remote-exec" {
    inline = ["mkdir -p ${local.dst_files_dir}", "chmod 777 ${local.dst_files_dir}", ]
  }

  # Copy ansible_node_packages.sh shell file to ansible host
  provisioner "file" {
    source      = local.ansible_node_config_script
    destination = "${local.dst_files_dir}/ansible_node_packages.sh"
  }

  # Execute ansible_node_packages.sh shell script to configure ansible host
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_files_dir}/ansible_node_packages.sh",
      "${local.dst_files_dir}/ansible_node_packages.sh",
    ]
  }
}

##############################################################
# 2. Execute ansible playbooks
##############################################################

resource "terraform_data" "trigger_ansible_vars" {
  input = [var.playbook_template_vars, var.inventory_template_vars]
}

resource "terraform_data" "execute_playbooks" {
  depends_on = [terraform_data.setup_ansible_host]
  count      = var.ansible_vault_password != null ? 0 : 1

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.bastion_host_ip
    host         = var.ansible_host_or_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "5m"
  }

  triggers_replace = terraform_data.trigger_ansible_vars

  # Create terraform scripts directory
  provisioner "remote-exec" {
    inline = ["mkdir -p ${local.dst_files_dir}", "chmod 777 ${local.dst_files_dir}", ]
  }

  # Copy and create ansible playbook template file on ansible host
  provisioner "file" {
    content     = templatefile(local.src_playbook_tftpl_path, var.playbook_template_vars)
    destination = local.dst_playbook_file_path
  }

  # Copy and create ansible inventory template file on ansible host
  provisioner "file" {
    content     = templatefile(local.src_inventory_tftpl_path, var.inventory_template_vars)
    destination = local.dst_inventory_file_path
  }

  # Copy and create ansible shell template file which will trigger the playbook on ansible host
  provisioner "file" {
    content = templatefile(local.src_script_tftpl_path,
      {
        "ansible_playbook_file" : local.dst_playbook_file_path,
        "ansible_log_path" : local.dst_files_dir,
        "ansible_inventory" : local.dst_inventory_file_path,
        "ansible_private_key_file" : local.private_key_file
    })
    destination = local.dst_script_file_path
  }

  # Write ssh user's ssh private key
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /root/.ssh/",
      "chmod 700 /root/.ssh",
      "echo '${var.ssh_private_key}' > ${local.private_key_file}",
      "chmod 600 ${local.private_key_file}",
    ]
  }

  # Execute bash shell script to run ansible playbooks
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_script_file_path}",
      local.dst_script_file_path,
    ]
  }

  # Again delete private ssh key
  provisioner "remote-exec" {
    inline = [
      "rm -rf ${local.private_key_file}"
    ]
  }
}

resource "terraform_data" "execute_playbooks_with_vault" {
  depends_on = [terraform_data.setup_ansible_host]
  count      = var.ansible_vault_password != null ? 1 : 0

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.bastion_host_ip
    host         = var.ansible_host_or_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "5m"
  }

  triggers_replace = terraform_data.trigger_ansible_vars

  # Create terraform scripts directory
  provisioner "remote-exec" {
    inline = ["mkdir -p ${local.dst_files_dir}", "chmod 777 ${local.dst_files_dir}", ]
  }

  # Copy and create ansible playbook template file on ansible host
  provisioner "file" {
    content     = templatefile(local.src_playbook_tftpl_path, var.playbook_template_vars)
    destination = local.dst_playbook_file_path
  }

  #########  Encrypting the ansible playbook file with sensitive information using ansible vault  #########
  provisioner "remote-exec" {
    inline = [
      "echo ${var.ansible_vault_password} > password_file",
      "ansible-vault encrypt ${local.dst_playbook_file_path} --vault-password-file password_file"
    ]
  }

  # Copy and create ansible inventory template file on ansible host
  provisioner "file" {
    content     = templatefile(local.src_inventory_tftpl_path, var.inventory_template_vars)
    destination = local.dst_inventory_file_path
  }

  # Copy and create ansible shell template file which will trigger the playbook on ansible host
  provisioner "file" {
    content = templatefile(local.src_script_tftpl_path,
      {
        "ansible_playbook_file" : local.dst_playbook_file_path,
        "ansible_log_path" : local.dst_files_dir,
        "ansible_inventory" : local.dst_inventory_file_path,
        "ansible_private_key_file" : local.private_key_file
    })
    destination = local.dst_script_file_path
  }

  # Write ssh user's ssh private key
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /root/.ssh/",
      "chmod 700 /root/.ssh",
      "echo '${var.ssh_private_key}' > ${local.private_key_file}",
      "chmod 600 ${local.private_key_file}",
    ]
  }

  # Execute bash shell script to run ansible playbooks
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_script_file_path}",
      local.dst_script_file_path,
    ]
  }

  # Again delete Ansible Vault password used to encrypt the var
  # files with sensitive information and private ssh key
  provisioner "remote-exec" {
    inline = [
      "rm -rf password_file",
      "rm -rf ${local.private_key_file}"
    ]
  }
}


moved {
  from = terraform_data.setup_ansible_host
  to   = terraform_data.setup_ansible_host[0]
}
