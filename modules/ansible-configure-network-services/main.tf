locals {
  src_shell_templates_dir   = "${path.module}/templates-shell/"
  src_ansible_templates_dir = "${path.module}/templates-ansible/"
  dst_files_dir             = "/root/terraform_files"
}

locals {
  src_install_ansible_tpl_path = "${local.src_shell_templates_dir}/install_ansible.sh"
  dst_install_ansible_path     = "${local.dst_files_dir}/install_ansible.sh"
}

########################################################################################
# 1. Execute shell script to install ansible packages
########################################################################################

resource "terraform_data" "ansible_host" {

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
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
    source      = local.src_install_ansible_tpl_path
    destination = local.dst_install_ansible_path
  }

  # Execute install_ansible.sh shell script to configure ansible host
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_install_ansible_path}",
      local.dst_install_ansible_path,
    ]
  }
}

########################################################################################
# 2. Execute Ansible galaxy roles to configure network services (NTP, NFS, DNS, Squid)
########################################################################################

locals {
  src_configure_network_services_tpl_path            = "${local.src_ansible_templates_dir}/ansible_exec.sh.tftpl"
  dst_configure_network_services_file_path           = "${local.dst_files_dir}/configure_network_services.sh"
  src_inventory_configure_network_services_tpl_path  = "${local.src_ansible_templates_dir}/inventory.tftpl"
  dst_inventory_configure_network_services_file_path = "${local.dst_files_dir}/inventory_configure_network_services"
  src_playbook_configure_network_services_tpl_path   = "${local.src_ansible_templates_dir}/playbook_configure_network_services.yml.tftpl"
  dst_playbook_configure_network_services_file_path  = "${local.dst_files_dir}/playbook_configure_network_services.yml"
}

resource "terraform_data" "trigger_ansible" {
  input = var.network_services_config
}

resource "terraform_data" "execute_ansible_role" {
  depends_on = [terraform_data.ansible_host]

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.ansible_host_or_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "5m"
  }

  triggers_replace = terraform_data.trigger_ansible

  # Creates terraform scripts directory
  provisioner "remote-exec" {
    inline = ["mkdir -p ${local.dst_files_dir}", "chmod 777 ${local.dst_files_dir}", ]
  }

  # Copy inventory template file to ansible host
  provisioner "file" {
    content = templatefile(local.src_inventory_configure_network_services_tpl_path,
      { "squid_host" : var.network_services_config.squid.server_host_or_ip,
        "proxy_client_host" : var.network_services_config.proxy_client.server_host_or_ip,
        "dns_host" : var.network_services_config.dns.server_host_or_ip,
        "ntp_host" : var.network_services_config.ntp.server_host_or_ip,
        "nfs_host" : var.network_services_config.nfs.server_host_or_ip,
    })
    destination = local.dst_inventory_configure_network_services_file_path
  }

  # Copy playbook template file to ansible host
  provisioner "file" {
    content = templatefile(local.src_playbook_configure_network_services_tpl_path,
      { "squid_config" : jsonencode({ "squid" : var.network_services_config.squid }),
        "proxy_client_config" : jsonencode({ "squid" : var.network_services_config.proxy_client }),
        "dns_config" : jsonencode({ "dns" : var.network_services_config.dns }),
        "ntp_config" : jsonencode({ "ntp" : var.network_services_config.ntp }),
        "nfs_config" : jsonencode({ "nfs" : var.network_services_config.nfs }),
    })
    destination = local.dst_playbook_configure_network_services_file_path
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

  # Copy ansible exec template file to ansible host
  provisioner "file" {
    content = templatefile(local.src_configure_network_services_tpl_path,
      { "ansible_inventory" : local.dst_inventory_configure_network_services_file_path,
        "ansible_playbook_file" : local.dst_playbook_configure_network_services_file_path,
        "ansible_log_path" : local.dst_files_dir
        "ssh_private_key" : var.ssh_private_key
    })
    destination = local.dst_configure_network_services_file_path
  }

  # Execute script: configure_network_services.sh
  provisioner "remote-exec" {
    inline = ["chmod +x ${local.dst_configure_network_services_file_path}", local.dst_configure_network_services_file_path]
  }
}
