locals {
  src_ansible_templates_dir = "${path.module}/templates-ansible"
  src_shell_templates_dir   = "${path.module}/templates-shell"
  dst_files_dir             = "/root/terraform_files"

  src_script_tftpl_path    = "${local.src_shell_templates_dir}/${var.src_script_template_name}"
  dst_script_file_path     = "${local.dst_files_dir}/${var.dst_script_file_name}"
  src_playbook_tftpl_path  = "${local.src_ansible_templates_dir}/${var.src_playbook_template_name}"
  dst_playbook_file_path   = "${local.dst_files_dir}/${var.dst_playbook_file_name}"
  src_inventory_tftpl_path = "${local.src_ansible_templates_dir}/${var.src_inventory_template_name}"
  dst_inventory_file_path  = "${local.dst_files_dir}/${var.dst_inventory_file_name}"

}

##############################################################
# 1. Execute shell script to install and setup ansible node
##############################################################

resource "terraform_data" "setup_ansible_host" {

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

  # Copy install_ansible.sh shell file to ansible host
  provisioner "file" {
    source      = "${local.src_shell_templates_dir}/install_ansible.sh"
    destination = "${local.dst_files_dir}/install_ansible.sh"
  }

  # Execute install_ansible.sh shell script to configure ansible host
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_files_dir}/install_ansible.sh",
      "${local.dst_files_dir}/install_ansible.sh",
    ]
  }
}


##############################################################
# 2. Execute ansible playbooks
##############################################################

resource "terraform_data" "trigger_ansible_vars" {
  input = var.playbook_template_vars
}

resource "terraform_data" "execute_playbooks" {

  depends_on = [terraform_data.setup_ansible_host]
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
        "ssh_private_key" : var.ssh_private_key,
        "ansible_inventory" : local.dst_inventory_file_path
    })
    destination = local.dst_script_file_path
  }

  # Write ssh üser's ssh private key
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /root/.ssh/",
      "chmod 700 /root/.ssh",
      "echo '${var.ssh_private_key}' >/root/.ssh/id_rsa",
      "chmod 600 /root/.ssh/id_rsa",
    ]
  }

  # Execute bash shell script to run ansible playbooks
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_script_file_path}",
      local.dst_script_file_path,
    ]
  }
}
